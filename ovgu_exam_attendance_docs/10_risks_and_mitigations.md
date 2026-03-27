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

Invigilators may confirm the wrong student, miss a duplicate warning, or use the wrong exam session.

Impact:

- inaccurate attendance records
- administrative correction effort

Mitigations:

- show clear confirmation screen
- make duplicate warnings prominent
- provide active exam context on every operational screen
- support correction with audit trail

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

Malformed or inconsistent roster files may break lookup reliability before the exam even begins.

Impact:

- wrong or missing matches
- operational confusion at exam start

Mitigations:

- strict CSV validation
- import error summary
- pre-exam readiness check
- optional roster checksum or version display

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

- exact match only for confirmation-ready flow
- no attendance marking from fuzzy OCR guesses
- human confirmation before final persistence
