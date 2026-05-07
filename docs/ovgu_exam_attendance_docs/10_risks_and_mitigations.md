# 10. Risks & Mitigations

## Risk 1: OCR Failure on Real Student Cards

Description:

Printed card text may not be captured reliably due to font size, print quality, glare, or camera limitations.

Impact:

- Slower throughput
- increased fallback to manual search
- lower user confidence

Mitigations:

- focus OCR on matriculation number only
- use guided scan framing
- calibrate with real OVGU cards
- keep manual fallback immediately available
- approve device models with adequate camera quality

## Risk 2: Poor Lighting or Reflective Glare

Description:

Exam halls and entry corridors may create strong reflections or uneven lighting that degrade OCR quality.

Impact:

- increased scan failures
- slower queues

Mitigations:

- include torch control
- optimize UI for fast rescan
- define basic device-handling guidance for invigilators
- test in representative lighting conditions

## Risk 3: User Error Under Time Pressure

Description:

Invigilators may confirm the wrong student, miss a duplicate warning, or **import the wrong CSV** (MVP: no named session guardrail).

Impact:

- inaccurate attendance records
- administrative correction effort

Mitigations:

- show clear confirmation screen (name + matriculation)
- make duplicate warnings prominent
- after import, verbal cross-check that the **expected exam** matches the CSV (MVP keeps UI minimal)
- **Post-MVP:** named sessions, checksum hints, correction with audit trail

## Risk 4: Device Performance Limitations

Description:

Low-end or aging devices may produce slow camera startup, laggy OCR, or poor responsiveness.

Impact:

- degraded user experience
- reduced scan reliability

Mitigations:

- define an approved hardware profile
- optimize OCR invocation frequency
- persist immediately and keep workflows lightweight
- allow manual flow to remain fast even when scanning is weak

## Risk 5: Import Data Quality Problems

Description:

Malformed or inconsistent CSV **participant lists** may break lookup reliability before the exam even begins.

Impact:

- wrong or missing matches
- operational confusion at exam start

Mitigations:

- strict CSV validation
- clear error when import fails
- pre-exam readiness check (organizer verifies correct file)
- **Post-MVP:** optional import checksum or version display

## Risk 6: Privacy Incident Through Device Loss or Export Misuse

Description:

The device or exported files may expose personal data if mishandled.

Impact:

- GDPR compliance risk
- reputational and operational consequences

Mitigations:

- encrypted local database
- short retention period
- institution-controlled devices
- clear export policy and authorized handling only

## Risk 7: Over-Automation Leading to False Matches

Description:

Aggressive fuzzy matching could appear efficient but create wrong attendance marks.

Impact:

- integrity failure in the attendance record

Mitigations:

- exact match only for the scan/OCR confirmation-ready flow
- fuzzy matching used only in manual search (where the invigilator selects from a visible result list)
- human confirmation before final persistence

## Risk 8: CSV Character Encoding Issues

Description:

The exam registration system may export CSVs with encoding that corrupts special characters (e.g. "Göpfert" becomes "G?pfert"). This is a known issue with the upstream system.

Impact:

- Student names may display incorrectly in the app and in the export.
- Search by name may fail for affected students (matriculation number search remains unaffected).

Mitigations:

- The invigilator can use matriculation number lookup instead of name search in affected cases.
- The app must not crash on malformed encoding — read the file with a fallback character replacement.
- Note in import result if encoding anomalies are detected (best-effort detection only).
- This is a known upstream limitation; fixing it requires the registration system to export correct UTF-8, which is outside the app's control.
