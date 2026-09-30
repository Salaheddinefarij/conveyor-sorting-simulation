PROGRAM PLC_PRG
VAR
    (* Simulation only; configure cyclic task at exactly 20 ms. *)
    StartCmd, StopCmd, ResetCmd : BOOL;
    ManualMode, JogCmd, DivertCmd : BOOL;
    JamInjection, SensorFailure, SimEStop : BOOL;
    Motor, Diverter, InspectionSensor : BOOL;
    State : INT := 0; (* 0 stopped, 10 idle, 20 feed, 30 inspect, 40 sort, 90 fault *)
    AlarmCode : INT := 0; (* 1 simulated e-stop; 2 inspection timeout; 3 exit timeout *)
    GoodCount, RejectCount, ItemNumber : UDINT := 0;
    Position : LREAL := -1.0; (* -1 means no simulated item *)
    BadItem : BOOL;
    Elapsed : LREAL := 0.0;
    SimulationSeconds : LREAL := 0.0;
    StartEdge, StopEdge, ResetEdge : R_TRIG;
    ActiveManual : BOOL := FALSE;
    dt : LREAL := 0.02;
END_VAR
