(* Call once per 20 ms task. All plant values are simulated, with no physical I/O. *)
StartEdge(CLK := StartCmd);
StopEdge(CLK := StopCmd);
ResetEdge(CLK := ResetCmd);
SimulationSeconds := SimulationSeconds + dt;
Motor := FALSE;
Diverter := FALSE;

(* Highest-priority latched simulated fault. This is NOT a safety PLC function. *)
IF SimEStop AND (State <> 90) THEN
    AlarmCode := 1;
    State := 90;
    Elapsed := 0.0;
END_IF;

IF State = 90 THEN
    IF ResetEdge.Q AND NOT SimEStop AND NOT JamInjection AND NOT SensorFailure THEN
        AlarmCode := 0;
        Position := -1.0;
        State := 0;
        Elapsed := 0.0;
    END_IF;
    (* Even a simultaneous reset + start cannot restart this scan. *)
ELSIF StopEdge.Q THEN
    State := 0;
    Elapsed := 0.0;
    Position := -1.0;
ELSE
    IF State = 0 THEN
        ActiveManual := ManualMode;
    ELSE
        (* Ignore HMI mode changes during automatic operation. *)
        ManualMode := ActiveManual;
    END_IF;
    Elapsed := Elapsed + dt;
    CASE State OF
        0:
            IF ActiveManual THEN
                Motor := JogCmd;
                Diverter := DivertCmd;
            ELSIF StartEdge.Q THEN
                State := 10;
                Elapsed := 0.0;
            END_IF;
        10:
            IF Elapsed >= 0.8 THEN
                ItemNumber := ItemNumber + 1;
                BadItem := (ItemNumber MOD 3) = 0;
                Position := 0.0;
                State := 20;
                Elapsed := 0.0;
            END_IF;
        20:
            Motor := TRUE;
            IF NOT JamInjection THEN
                Position := MIN(0.5, Position + 0.25 * dt);
            END_IF;
            IF (Position >= 0.5) AND NOT SensorFailure THEN
                Motor := FALSE;
                State := 30;
                Elapsed := 0.0;
            ELSIF Elapsed >= 4.0 THEN
                AlarmCode := 2;
                State := 90;
                Motor := FALSE;
                Elapsed := 0.0;
            END_IF;
        30:
            IF Elapsed >= 0.6 THEN
                State := 40;
                Elapsed := 0.0;
            END_IF;
        40:
            Motor := TRUE;
            Diverter := BadItem;
            IF NOT JamInjection THEN
                Position := MIN(1.0, Position + 0.25 * dt);
            END_IF;
            IF Position >= 1.0 THEN
                IF BadItem THEN
                    RejectCount := RejectCount + 1;
                ELSE
                    GoodCount := GoodCount + 1;
                END_IF;
                Position := -1.0;
                State := 10;
                Elapsed := 0.0;
                Motor := FALSE;
                Diverter := FALSE;
            ELSIF Elapsed >= 4.0 THEN
                AlarmCode := 3;
                State := 90;
                Motor := FALSE;
                Diverter := FALSE;
                Elapsed := 0.0;
            END_IF;
    ELSE
        State := 0;
        Position := -1.0;
        Elapsed := 0.0;
    END_CASE;
END_IF;
InspectionSensor := (Position >= 0.5) AND (Position < 0.56) AND NOT SensorFailure;
(* Clear held manual requests outside manual idle so they cannot cause restart. *)
IF (State <> 0) OR NOT ActiveManual OR SimEStop OR StopEdge.Q OR ResetEdge.Q THEN
    JogCmd := FALSE;
    DivertCmd := FALSE;
END_IF;
