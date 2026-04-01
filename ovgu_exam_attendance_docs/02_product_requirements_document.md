# 2. Product Requirements Document (PRD)

## MVP definition (this release)

The **MVP** is an offline mobile app for exam invigilators that supports:

| Step | Requirement |
|------|-------------|
| Load list | User imports a **CSV from the local device** with at least **matriculation number** and **student name** per row. |
| Check-in | User starts scanning; **on-device OCR** reads the card, extracts a matriculation candidate, **exact-matches** the **participant list**; user **confirms** present. **Manual search** (by name and/or matriculation) marks present the same way. |
| Progress | At any time, UI shows **count present** and **count not yet marked** (total participants minus present). The app does **not** show “absent” in the live UI. |
| Finish | User taps **Export**; app writes a **CSV** where each **row from the imported list** has **`present`** or **`absent`**. **`absent` is computed only at export**: anyone without a confirmed present record is exported as absent. |

**Out of scope for MVP** (may be added later; see [11_future_improvements.md](11_future_improvements.md)): named exam sessions with rich metadata, full browse/filter screens for all participants, formal audit trail, attendance reversal, encryption-at-rest (unless mandated), duplicate matriculation handling beyond simple reject, and other administrative features.

## Product Vision (full product direction)

The product is a mobile attendance application for OVGU exam invigilators. It enables local scanning of student ID cards, extracts the matriculation number through on-device OCR, matches that number against the **participant list** loaded from CSV, and records attendance without internet connectivity or external services. The MVP realizes the core loop above; the vision allows gradual addition of compliance, operations, and UX depth.

The system is an operational tool, not a generic campus app. Success means speed, reliability offline, and acceptable privacy posture for the institution.

## Product Goals

- Accelerate attendance verification at exam entry.
- Reduce operational errors compared with paper-based workflows.
- Ensure complete offline usability for import, scanning, lookup, marking, counts, and export.
- Keep a simple, low-training experience for invigilators.
- Keep personal data on the device for MVP; strengthen safeguards in later releases as needed.

## Stakeholders

- Invigilators who use the app during the exam.
- Exam organizers who prepare CSVs and collect exports.
- OVGU faculty or administrative units responsible for exam operations.
- OVGU data protection and IT governance stakeholders.

## User Personas

### Persona A: Invigilator Works under time pressure, needs few taps, must trust offline operation and clear fallback when scanning fails.

### Persona B: Exam Organizer Prepares the CSV, loads it on the device, needs a predictable export file for administration.

## Functional Requirements

### FR-MVP-1 CSV import

- The app shall import a **local CSV** containing the list of **participants** (students) for the exam.
- Required fields: **matriculation number**, **student name** (exact column names fixed in implementation).
- The app shall validate the file with **minimal** behavior for MVP (e.g. reject unusable imports with a simple message); **no** separate post-import summary screen.
- Importing again may **replace** the current participant list; advanced policies are post-MVP.

### FR-MVP-2 Scanning

- The app shall provide a **camera-based** scanning flow after the user chooses to start scanning.
- The app shall run **OCR on-device** only; no network.
- The app shall extract a **matriculation number candidate**, normalize it, and **exact-match** against the **loaded participant list**.
- No automatic present mark without **explicit user confirmation** after a unique match.

### FR-MVP-3 Matching

- **Exact match** on normalized matriculation number only for the confirmation path.
- If zero or multiple matches, the app shall **not** mark present automatically; user may rescan or use manual search.

### FR-MVP-4 Attendance marking

- On confirm, the app shall persist **one present record per student** with **method** only (`scan` or `manual`). **MVP:** no stored **timestamps** (no `created_at`, `marked_at`, etc.).
- **Duplicate** attempt: warn; **do not** create a second present record.

### FR-MVP-5 Manual fallback

- Search by **name** and by **matriculation**; select student and confirm present.
- Available even if OCR or camera fails to initialize.

### FR-MVP-6 Live progress

- Display **present count** and **not-yet-marked count** (or equivalent: present + remaining).
- MVP does not require a full scrollable list of all participants; **counts are mandatory**. A simple list view may be added without changing export rules.

### FR-MVP-7 Export

- **Explicit Export** action generates a **CSV** saved or shared via local file flows.
- For **every** row from the imported participant list, output at least: identity fields (matriculation, name), **`status`** = `present` | `absent`, and for present rows **`method`** (`scan` | `manual`) if the app stores it. **MVP:** no **time** columns in the export.
- **`absent` definition:** at export time, any student **without** a stored present confirmation is written as **`absent`**.
- UI shall warn that **unmarked students will appear as absent** in the export (clear copy before or on confirm).

### Post-MVP functional items (reference)

The following are **not required for MVP** but remain valid product direction:

- **FR-X1** Explicit exam session entity with title, date, exam id, draft/active/closed.
- **FR-X2** Full attendance list with search, filters, and optional correction/undo with audit.
- **FR-X3** Structured audit trail for import, mark, duplicate, revert, export.
- **FR-X4** Encryption at rest and extended retention policy controls.

## Non-Functional Requirements

### Performance (targets)

- Scan-to-confirm should feel responsive on approved hardware; manual search usable for **up to ~2,000 participants**.

### Reliability

- Core MVP flows work **fully offline**.
- Confirmed present records **survive** app restart (persistence required for MVP realism).
- OCR failure must **not** block marking (manual path).

### Usability

- Few steps on the happy path; large tap targets; readable in bright rooms.
- Errors always suggest a **next action** (rescan, manual search).

### Privacy and Security (MVP vs later)

- **MVP:** no cloud APIs; data in **app-private** storage; minimize retained data; do not store card images by default.
- **Post-MVP:** encrypted DB at rest, formal audit export, stricter retention—see [07_security_and_privacy_design.md](07_security_and_privacy_design.md).

### Maintainability

- OCR behind a **replaceable interface**; domain logic testable without camera.

## Constraints

- ID cards: **printed text**; no QR/NFC/barcode assumption; no physical card changes.
- No reliance on internet during exam.
- One device per exam for MVP scope.
- No cloud OCR or external attendance APIs.

## Assumptions

- Matriculation numbers are unique within one imported CSV.
- Organizers can supply a correct CSV before or at exam start.
- Device camera is adequate for near-range capture on supported hardware.

## User Flow: MVP exam scenario

1. User opens app and **imports** the participant CSV from the device.
2. User taps **Start scanning** (or equivalent).
3. For each student: scan card → unique match → **Confirm present**; or open **Manual search** → select → confirm.
4. As needed, user checks **present / not yet marked** counts.
5. When finished, user taps **Export**; confirms if prompted; **CSV** contains **present** and **absent** per rules above.

## Export semantics (normative for MVP)

| Stored state at export | CSV `status` |
|------------------------|--------------|
| Present confirmed      | `present`    |
| No present record      | `absent`     |

Second export recomputes from current data; behavior is deterministic from **participant list + present records**.
