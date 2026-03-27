# 7. Security & Privacy Design

## Security and Privacy Objectives

- Keep all personal data local to the device.
- Ensure that the app remains usable without any internet dependency.
- Reduce exposure in the event of device loss or mishandling.
- Satisfy privacy-by-design expectations for a university attendance tool.
- Minimize retained data and avoid storing unnecessary artifacts.

## Data Storage Approach

- Store roster, attendance, and audit data in app-private local storage only.
- Encrypt the local database at rest.
- Store encryption material in the platform keystore or keychain where feasible.
- Do not store raw card images by default.
- Avoid retaining full OCR text unless there is a clear operational need and approved retention policy.

## No-Network Guarantees

### Architectural Controls

- No external APIs shall be used.
- No cloud OCR shall be used.
- No analytics, advertising, crash-reporting, or telemetry SDKs shall be included by default.
- Networking code should be excluded from the production scope.

### Android-Specific Control

- The production build should not request the `INTERNET` permission.
- Release verification should include a manifest review to confirm that no dependency reintroduces network capability unexpectedly.

### iOS Consideration

- iOS does not provide a comparable user-visible network permission model for normal outbound traffic.
- Assurance must therefore come from dependency control, architecture review, and institutional deployment policy.

## GDPR Considerations

Relevant personal data includes:

- student full name
- matriculation number
- attendance status
- timestamp of attendance marking

Required privacy positions:

- define the lawful basis with OVGU governance and data protection stakeholders
- document purpose limitation for exam attendance only
- collect only fields necessary for attendance administration
- retain data only for the approved administrative period
- restrict export access to authorized staff
- define procedures for lost devices and post-exam deletion

## Data Minimization

- The scan workflow should target matriculation number extraction only.
- The app should not capture or retain more data than necessary to confirm attendance.
- Optional fields such as study program or seat number should be included only when operationally justified.

## Data Retention Policy

Recommended policy baseline:

- Keep active exam data locally until attendance has been exported and administratively transferred.
- Prompt for deletion or secure archival after a defined short retention period, such as 7 to 30 days depending on institutional policy.
- Remove diagnostic OCR artifacts immediately or by session end if stored at all.
- Avoid indefinite retention on the device.

## Threat Model

### Threat 1: Lost or Stolen Device

Potential impact:

- Unauthorized access to student roster and attendance data.

Mitigations:

- device PIN or biometric protection
- encrypted database
- app-private storage
- operational guidance for rapid device reporting and data deletion

### Threat 2: Unauthorized Export Handling

Potential impact:

- CSV files shared through insecure channels.

Mitigations:

- explicit export action only
- clear warning during export
- institutional file-handling policy
- optional protected export packaging if needed

### Threat 3: Hidden Data Transmission

Potential impact:

- accidental leakage of personal data to third parties.

Mitigations:

- no-network architecture
- manifest and dependency review
- release checklist confirming absence of telemetry libraries

### Threat 4: Accidental Attendance Misuse

Potential impact:

- false attendance records or untraceable corrections.

Mitigations:

- confirmation step before marking
- duplicate prevention
- local audit trail
- reversible correction with traceability

### Threat 5: Device Crash During Exam

Potential impact:

- interruption and possible data loss.

Mitigations:

- immediate persistence after each confirmation
- restart into active session state
- append-only audit event recording

## Security Design Principles

- secure by default
- least privilege
- explicit user action for import and export
- minimize stored data
- make operational failure safer than silent success
