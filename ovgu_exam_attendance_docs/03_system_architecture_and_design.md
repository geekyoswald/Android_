# 3. System Architecture & Design

## MVP vs full architecture

**MVP presentation layer** maps to a small number of flows:

- **Import:** pick CSV, minimal validation; **participant list** becomes the active working set (conceptually one implicit “session”). **No** separate import summary screen for MVP.
- **Main / scan:** camera + OCR pipeline, confirmation, duplicate handling; entry to manual search.
- **Manual search:** find student, confirm present (shared rules with scan path).
- **Progress:** present count and not-yet-marked count always derivable from **participant list + present records**.
- **Export:** compute `present` | `absent` per row at export time; write CSV locally.

Optional components in this document (audit service, exam session controller with full lifecycle, secure key management) apply to **post-MVP** hardening unless explicitly pulled into MVP by governance.

## Architectural Style

The recommended architecture is an offline-first mobile application with layered separation between presentation, application logic, domain logic, and infrastructure. The system should treat scanning as a local assistive input mechanism rather than a source of truth. Final **present** state is controlled by explicit user confirmation; **absent** in the export file is **derived** when exporting (any participant row without a present record).

## High-Level Architecture Diagram

```text
+------------------------------------------------------------------+
|                         Flutter Mobile App                       |
|------------------------------------------------------------------|
| Presentation Layer                                               |
| - Import / CSV Screen (MVP entry)                                |
| - Scan Screen + live counts                                      |
| - Match Confirmation Screen                                      |
| - Manual Search Screen                                           |
| - Export action (MVP; absent derived here)                      |
| - Attendance List Screen (post-MVP / optional)                  |
|------------------------------------------------------------------|
| Application Layer                                                |
| - Session Coordinator (MVP: implicit single participant list)     |
| - Scan Workflow Controller                                       |
| - Attendance Service                                             |
| - Import/Export Service                                          |
| - Audit Logging Service (post-MVP unless required)                |
|------------------------------------------------------------------|
| Domain Layer                                                     |
| - Student Entity                                                 |
| - Exam Session Entity (MVP: optional minimal row or implicit)    |
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
- Query the local **participant list** for exact matches.
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

- Persist student records (**participant list**), attendance records, and optionally a minimal session key; **audit events post-MVP** unless mandated.
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
4. The application layer checks the local database for a unique exact match on the **participant list**.
5. The UI presents one of four outcomes:
   - confirmation ready
   - duplicate warning
   - no match
   - manual fallback recommendation
6. On confirmation, the attendance service writes the attendance event to the local database (and an audit entry **if** audit is implemented).
7. The UI updates **present / not-yet-marked** counters and returns to scan mode.

**Export path:** export service loads the **participant list** and all present records; for each student outputs `present` or `absent` (absent = no present record at export time); no separate stored “absent” row required.

## State Management Approach

Recommended approach: `Riverpod`.

Justification:

- It supports clear separation between UI and business logic.
- It makes dependency injection and testing straightforward.
- It handles asynchronous state transitions cleanly for camera, OCR, import, and persistence flows.
- It avoids tightly coupling scan workflow state to widget lifecycle.

Suggested state domains:

- active participant list / implicit session state
- scan workflow state
- OCR processing state
- manual search state
- attendance progress state (counts, export readiness)
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
- Suitable for structured export; audit logging optional for MVP.

### Encrypted Local Storage

Why it fits:

- Student data and attendance are personal data.
- Encryption at rest reduces exposure if a device is lost or temporarily accessed by an unauthorized person.
- **MVP:** may ship without DB encryption if timelines require it; plan encryption before broader rollout ([07_security_and_privacy_design.md](07_security_and_privacy_design.md)).

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
