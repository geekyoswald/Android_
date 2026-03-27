# 2. Product Requirements Document (PRD)

## Product Vision

The product is a mobile attendance application for OVGU exam invigilators. It enables local scanning of student ID cards, extracts the matriculation number through on-device OCR, matches that number against a preloaded exam roster, and records attendance without internet connectivity or external services.

The system is designed as a practical operational tool rather than a generic campus app. The primary success criteria are speed, reliability, offline capability, and privacy compliance in real exam situations.

## Product Goals

- Accelerate attendance verification at exam entry.
- Reduce operational errors compared with paper-based workflows.
- Ensure complete offline usability for scanning, lookup, attendance marking, and export.
- Maintain a simple and low-training user experience for invigilators.
- Preserve personal data locally with strong privacy safeguards.

## Stakeholders

- Invigilators who use the app during the exam.
- Exam organizers who prepare imports and receive exports.
- OVGU faculty or administrative units responsible for exam operations.
- OVGU data protection and IT governance stakeholders.

## User Personas

### Persona A: Invigilator

- Works at the exam venue under strict time pressure.
- Needs a fast, low-friction process with minimal typing.
- May not be technically specialized.
- Requires confidence that the system works fully offline.
- Values clear warnings and simple fallback paths when scanning fails.

### Persona B: Exam Organizer

- Prepares participant lists before the exam.
- Imports the student roster into the device.
- Needs clean exports and predictable behavior.
- Wants minimal setup overhead and minimal failure risk on exam day.

## Functional Requirements

### FR-1 Exam Session Setup

- The app shall allow creation of a local exam session.
- The app shall store exam metadata including title, date, and exam identifier.
- The app shall support one active exam session per device at a time.

### FR-2 CSV Import

- The app shall import a local CSV file containing the student roster.
- The app shall validate required fields before saving the roster.
- Required fields shall include matriculation number and student name.
- The import flow shall display a summary containing successful rows, rejected rows, and reasons for rejection.
- The app shall reject duplicate matriculation numbers within the same exam session unless the user explicitly replaces the roster.

### FR-3 Card Scanning

- The app shall provide a camera-based scanning interface.
- The app shall perform OCR locally on-device.
- The app shall attempt to extract a matriculation number from the recognized text.
- The app shall not require internet access for scanning or OCR.

### FR-4 Student Matching

- The app shall match the extracted matriculation number against the locally stored roster.
- The primary matching rule shall be exact matching on normalized matriculation number.
- The app shall prevent automatic attendance marking when no unique match exists.

### FR-5 Attendance Marking

- The app shall allow the invigilator to confirm attendance after a successful match.
- The app shall store timestamp, exam session reference, and marking method.
- The app shall persist each confirmed attendance event immediately.

### FR-6 Duplicate Prevention

- The app shall detect when a student has already been marked present.
- The app shall display a duplicate warning and shall not create a second valid attendance record.
- The app shall preserve the original attendance timestamp.

### FR-7 Manual Fallback

- The app shall support manual student lookup by matriculation number.
- The app shall support manual student lookup by name.
- The app shall allow attendance marking from search results.
- The manual fallback path shall remain available even if OCR initialization fails.

### FR-8 Attendance Overview

- The app shall display a list of all students in the active session.
- The list shall show current attendance status.
- The list shall support search and filtering.
- The list shall show total counts for present and not-yet-marked students.

### FR-9 Export

- The app shall export attendance data to a local CSV file.
- The export shall include exam metadata, student identity fields needed for administration, attendance status, timestamp, and marking method.
- Export shall require explicit user action.

### FR-10 Auditability

- The app shall store a minimal local audit trail for important actions.
- The audit trail shall include import, attendance confirmation, duplicate detection, attendance reversal, and export actions.

## Non-Functional Requirements

### Performance

- Median scan-to-result time should be below 2 seconds on approved devices.
- Manual search should feel immediate for typical exam rosters up to at least 2,000 students.
- App startup should be fast enough for operational use before and during exams.

### Reliability

- Core features shall work fully offline.
- A crash or forced restart shall not lose already confirmed attendance records.
- OCR failure shall not block attendance marking because manual fallback is mandatory.

### Usability

- The primary attendance workflow should require as few interactions as possible.
- Error states shall always present a clear next action.
- The interface shall be readable in bright indoor environments and stressful, high-throughput situations.

### Privacy and Security

- No cloud APIs or external OCR services shall be used.
- Student data shall remain in local device storage.
- The database should be encrypted at rest.
- The app shall request only necessary permissions.

### Maintainability

- OCR integration shall be abstracted behind a replaceable interface.
- Business logic shall be testable without camera or platform dependencies.
- Import, OCR parsing, matching, and export should be modular.

## Constraints

- The student ID card contains printed text only.
- No QR, NFC, or barcode assumptions may be made.
- No changes may be made to the physical ID cards.
- Internet access cannot be assumed during exams.
- One mobile device per exam is sufficient for the initial scope.
- External APIs, especially cloud OCR services, are not allowed.

## Assumptions

- The matriculation number is unique within an exam roster.
- Exam rosters can be prepared and imported before the exam starts.
- The university can provide approved mobile devices for exam operations.
- Device cameras are of sufficient quality for near-range text capture.
- Institutional policy permits local digital attendance records for exam administration.

## User Flow: Standard Exam Scenario

1. Before the exam, the organizer creates the exam session and imports the roster.
2. The invigilator opens the app and starts the active exam session.
3. The student presents an ID card at entry.
4. The invigilator scans the card using the camera view.
5. The app extracts a candidate matriculation number and checks the local roster.
6. If a unique match is found, the app shows a confirmation screen.
7. The invigilator confirms attendance.
8. The app stores the record and returns to scan mode.
9. If scanning fails or the match is uncertain, the invigilator switches to manual search.
10. After the exam, the organizer exports the attendance list as CSV.
