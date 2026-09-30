# Conveyor Lab

A personal educational conveyor sorting simulation by Salah Eddine Farij. It connects automation sequencing, an operator interface and software testing. It is an independent portfolio project, not work performed for INIPRESS, Ferrero, OCP or RenewMinder.

## Open the demonstration

Download the repository ZIP, extract it, then double-click **index.html**. It works offline in a modern desktop browser; no account, installation, server or package download is required. Press **Start**. In approximately 17 simulation seconds, two products are accepted and one is rejected.

The HTML embeds the JavaScript controller. `controller.js` is the corresponding standalone source for tests. If you edit the controller, update the embedded copy as well before sharing the demo.

## What is delivered

- Standalone animated operator dashboard with automatic and manual modes.
- Deterministic one-item-at-a-time simulated plant; every third product is defective.
- Inspection delay, sensor and movement timeout alarms, latched faults and reset/restart sequence.
- Hold-to-operate manual motor/diverter controls, fault injection and CSV event-log export.
- CODESYS V3.5 Structured Text declaration and implementation files.
- 12 automated JavaScript controller tests.
- I/O list, setup instructions and recorded controller test results.

## Status and limitations

The JavaScript model has passed the 12 included automated tests. A separate DOM-based interface smoke check also passed (start, sorting, jam/reset/restart, manual hold/release and event rendering). Visual browser layout has not been verified in this environment. The Structured Text is a separately implemented reference using the same process concept; it has **not been compiled or run in CODESYS** in this environment. This is not a native `.project` file and is not a verified PLC deployment. The browser dashboard is not a CODESYS HMI and is not connected to a PLC. There is no backend, live industrial data or industrial communication link in version 1.

The simulated emergency stop is a training input only. Do not use this software for real machine control or as a functional-safety implementation.

## Behaviour

STOPPED → IDLE (0.8 s) → FEED (up to 4 s) → INSPECT (0.6 s) → SORT (up to 4 s) → IDLE.

Normal travel takes approximately 2 s per movement stage. A jam freezes product position. A missing sensor prevents the inspection transition. The corresponding timeout latches FAULT and deactivates outputs. Clearing an injection alone does not restart. Clear all injected faults → Reset fault → Start.

Stop clears an in-flight simulated item without increasing counters. Reset does the same after a fault. These are explicit simulation simplifications; real product tracking and safe machine recovery require a separate design. Counters persist through Stop and Reset but reset on page reload. Manual mode drives outputs only, without simulated product generation. Mode changes require STOPPED. Export contains only the latest 120 events. Simulation time uses fixed 20 ms steps and pauses when the browser tab is hidden; under load it can run slower than wall time.

## Run tests

With Node.js installed, from this folder:

```sh
node --test tests/controller.test.js
```

See `docs/TEST-RESULTS.txt` for the recorded output and `docs/CODESYS-SETUP.md` for the separate PLC validation procedure.

## Scope

A personal portfolio simulation exploring industrial automation and software development. No physical PLC, industrial network, live production data or factory equipment is connected.
