# Run the Structured Text in CODESYS V3.5

Status: source prepared; CODESYS compilation and simulation pending. Allow time for this validation before claiming a working CODESYS project.

1. Create a Standard Project in CODESYS V3.5 with a supported controller target and Structured Text for PLC_PRG. Use simulation, with no connection to machinery.
2. In PLC_PRG, replace the declaration pane with `plc/PLC_PRG.declaration.st` and the implementation pane with `plc/PLC_PRG.implementation.st`. These are text source files, not files to open as a native CODESYS project. Do not paste the PROGRAM/VAR declaration into the implementation pane.
3. Ensure the Standard library is referenced; it provides R_TRIG. Build the application and resolve any target/version-specific errors. The provided source has not been compiled here.
4. In Task Configuration, set the cyclic task calling PLC_PRG to **20 ms**. Call the program exactly once per cycle. The simulated timing depends on this setting; dt is 0.02 seconds.
5. Enable Online → Simulation, log in, and start the application. Use a watch list for the variables below. Exact menu names can vary by UI language/version.
6. For a command, write TRUE for at least one scan and then FALSE (do not force it permanently). StartCmd, StopCmd and ResetCmd use rising edges. A new command requires a fresh FALSE → TRUE transition.
7. Pulse StartCmd. Watch State, Position, Motor, Diverter, GoodCount and RejectCount. After three completed products, expect 2 accepted and 1 rejected.
8. Set JamInjection TRUE during FEED; expect AlarmCode 2 and State 90 after the 4 s stage timeout. Clear the injection: State must remain 90. Pulse ResetCmd, verify State 0 with outputs off, then separately pulse StartCmd.
9. Repeat with SensorFailure TRUE (inspection timeout), JamInjection during SORT (exit timeout), and SimEStop TRUE (fault on next scan). Confirm reset is blocked while any injected fault is active.
10. Pulse StopCmd; set ManualMode TRUE while stopped. Write JogCmd TRUE then FALSE; observe Motor. Repeat DivertCmd. Set both FALSE before leaving manual mode. If you build a CODESYS visualization, configure these as momentary controls and commands as pulses.
11. Save the native project only after a clean build and successful scenarios. Record CODESYS version, target, task interval and actual results in a validation note.

## I/O and HMI binding list

All variables below are under `PLC_PRG`. They are internal simulation variables, not mapped physical I/O.

| Variable | Type | Purpose |
|---|---|---|
| StartCmd / StopCmd / ResetCmd | BOOL | Rising-edge operator commands |
| ManualMode | BOOL | FALSE automatic, TRUE manual; accepted while stopped |
| JogCmd / DivertCmd | BOOL | Momentary manual output requests |
| JamInjection | BOOL | Freeze movement in the automatic plant model |
| SensorFailure | BOOL | Suppress inspection sensor |
| SimEStop | BOOL | Educational simulated stop input |
| Motor / Diverter | BOOL | Simulated outputs |
| InspectionSensor | BOOL | Simulated product sensor |
| State | INT | 0 stopped, 10 idle, 20 feed, 30 inspect, 40 sort, 90 fault |
| AlarmCode | INT | 0 none, 1 simulated stop, 2 inspection timeout, 3 exit timeout |
| Position | LREAL | -1 absent; 0–1 normalized conveyor position |
| GoodCount / RejectCount | UDINT | Completed product counts |
| ItemNumber | UDINT | Released product number |
| SimulationSeconds | LREAL | Fixed-step simulation time |

## Optional CODESYS visualization

Add a Visualization object with Start/Stop/Reset buttons, a ManualMode selector, momentary jog/diverter buttons and three injection switches. Add indicators for outputs and the sensor, numeric displays for State/AlarmCode/counters and a rectangle whose horizontal position is derived from Position. This visualization is a next step; no native CODESYS visualization file is included.

## Official references

- CODESYS development environment: https://www.codesys.com/products/engineering/development-system/
- Structured Text tutorial: https://content.helpme-codesys.com/en/CODESYS%20Development%20System/_cds_tutorial_refrigerator_program.html
- Standard-library R_TRIG: https://content.helpme-codesys.com/en/libs/Standard/Current/Trigger/R_TRIG.html

The browser model uses button-event commands while the ST program uses scan-based rising-edge commands. Do not assume scan-for-scan equivalence; validate each implementation independently.
