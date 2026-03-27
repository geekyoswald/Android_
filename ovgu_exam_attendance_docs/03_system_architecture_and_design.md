# 3. System Architecture & Design

## Architectural Style

The recommended architecture is an offline-first mobile application with layered separation between presentation, application logic, domain logic, and infrastructure. The system should treat scanning as a local assistive input mechanism rather than a source of truth. Final attendance state must be controlled by deterministic business rules and explicit user confirmation.

## High-Level Architecture Diagram

```text
+------------------------------------------------------------------+
|                         Flutter Mobile App                       |
|------------------------------------------------------------------|
| Presentation Layer                                               |
| - Scan Screen                                                    |
| - Match Confirmation Screen                                      |
| - Manual Search Screen                                           |
| - Attendance List Screen                                         |
| - Import/Export Screens                                          |
|------------------------------------------------------------------|
| Application Layer                                                |
| - Exam Session Controller                                        |
| - Scan Workflow Controller                                       |
| - Attendance Service                                             |
| - Import/Export Service                                          |
| - Audit Logging Service                                          |
|------------------------------------------------------------------|
| Domain Layer                                                     |
| - Student Entity                                                 |
| - Exam Session Entity                                            |
| - Attendance Entity                                              |
| - Matching Rules                                                 |
| - Duplicate Prevention Rules                                     |
|------------------------------------------------------------------|
| Infrastructure Layer                                             |
| - Camera Adapter                                                 |
| - OCR Adapter                                                    |
| - SQLite Repository                                              |
| - Secure Storage / Key Management                                |
| - Local File Import/Export                                       |
+------------------------------------------------------------------+
```

## Component Breakdown

### Camera Module

Responsibilities:

- Manage camera permissions and lifecycle.
- Provide a stable preview for near-field card scanning.
- Capture frames or still images for OCR.
- Support focus assistance and flash control where available.

Design considerations:

- The module should prioritize stable image capture over continuous high-frequency scanning.
- A guided framing overlay should help the invigilator position the card consistently.
- Camera logic should be isolated from OCR and business rules.

### OCR Module

Responsibilities:

- Accept image input from the camera layer.
- Run on-device text recognition only.
- Return recognized text blocks and confidence metadata where available.
- Expose a consistent interface to the application layer.

Design considerations:

- OCR must be replaceable because field testing may show different performance on different engines or platforms.
- The OCR module should not contain attendance rules.
- The module should support throttling to reduce battery usage and UI lag.

### Matching Engine

Responsibilities:

- Normalize OCR text.
- Identify candidate matriculation numbers.
- Query the local roster for exact matches.
- identify duplicates and ambiguous states.
- Return clear result states to the UI layer.

Result states should include:

- exact match available
- already marked present
- no match found
- ambiguous or low-confidence result
- OCR failed

### Local Database Module

Responsibilities:

- Persist exam sessions, student records, attendance records, and audit events.
- Support exact lookup by matriculation number.
- Support fast search by normalized name.
- Persist attendance immediately after confirmation.

### UI Layer

Responsibilities:

- Present a scan-first user experience.
- Surface status changes clearly and quickly.
- Provide obvious fallback paths.
- Minimize interaction count during high-volume exam entry.

## Data Flow

1. The camera module captures an image or frame.
2. The OCR module extracts raw text from the image.
3. The matching engine normalizes the OCR text and detects likely matriculation candidates.
4. The application layer checks the local database for a unique exact roster match.
5. The UI presents one of four outcomes:
   - confirmation ready
   - duplicate warning
   - no match
   - manual fallback recommendation
6. On confirmation, the attendance service writes the attendance event and audit entry to the local database.
7. The UI updates counters and returns to scan mode.

## State Management Approach

Recommended approach: `Riverpod`.

Justification:

- It supports clear separation between UI and business logic.
- It makes dependency injection and testing straightforward.
- It handles asynchronous state transitions cleanly for camera, OCR, import, and persistence flows.
- It avoids tightly coupling scan workflow state to widget lifecycle.

Suggested state domains:

- active exam session state
- scan workflow state
- OCR processing state
- manual search state
- attendance summary state
- import/export status state

## Technology Choices

### Flutter

Why it fits:

- Android-first delivery with a future path to iOS.
- Mature support for camera, local database, file access, and state management.
- Good balance between academic deliverable quality and production viability.

### SQLite

Why it fits:

- Embedded and offline by design.
- Strong support for indexed exact lookups and transactional persistence.
- Suitable for audit logging and structured export.

### Encrypted Local Storage

Why it fits:

- Student data and attendance are personal data.
- Encryption at rest reduces exposure if a device is lost or temporarily accessed by an unauthorized person.

### Pluggable OCR Adapter

Why it fits:

- OCR quality is one of the main technical risks and may require tuning.
- A pluggable adapter allows replacement without changing the core domain logic.
- The university may later prefer a different OCR engine after legal or operational review.

## Architectural Decisions

### Decision 1: Exact Match Only for Automatic Candidate Resolution

Rationale:

- Fuzzy matching can save time but increases the risk of wrong attendance marks.
- In exam administration, a false positive is more harmful than a rescan or manual lookup.

### Decision 2: No Multi-Device Synchronization

Rationale:

- Single-device operation matches the stated constraint.
- Removing synchronization simplifies offline behavior, privacy analysis, and failure handling.

### Decision 3: Immediate Persistence After Confirmation

Rationale:

- Exam operations cannot tolerate data loss after a device restart or battery failure.
- Small transactional writes are more important than batching for this use case.
