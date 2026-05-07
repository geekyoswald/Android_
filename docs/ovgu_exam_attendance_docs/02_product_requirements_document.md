# 2. Product Requirements Document (PRD)

## MVP definition (this release)

The **MVP** is an offline mobile app for exam invigilators that supports:

| Step | Requirement |
|------|-------------|
| Load list | User imports a **CSV from the local device** with at least **matriculation number**, **student name**, and optional **exam_group** per row. Delimiter is auto-detected (comma, semicolon, or tab). |
| Check-in | User starts scanning; **on-device OCR** reads the card, extracts a matriculation candidate, **exact-matches** the **participant list**; user **confirms** present with a single large tap. **Manual search** (unified field: name or matriculation) marks present the same way. |
| Progress | At any time, UI shows **count present** and **count not yet marked** (total participants minus present). If `exam_group` is present, live counts are shown **per exam group** (e.g. EinfInf 144/164, AuD 10/16). The app does **not** label students “absent” in the live UI. |
| Finish | User taps **Export**; app writes a **CSV** where each **row from the imported list** has **`present`**, **`absent`**, **`excused`**, or **`marked`**. **`absent` is computed only at export**: anyone without a confirmed status is exported as absent. |

**Out of scope for MVP** (may be added later; see [11_future_improvements.md](11_future_improvements.md)): named exam sessions with rich metadata, formal audit trail, encryption-at-rest (unless mandated), and other administrative features.

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
- Required fields: **matriculation_number**, **full_name**. Optional field: **exam_group** (used for live per-exam counts and export grouping).
- Delimiter shall be **auto-detected** (try comma, then semicolon, then tab) — no user setting required.
- The app shall show an **inline import result card** (not a separate screen) after import:
  - On success: student count (e.g. "Imported 154 students"; if exam_group present, broken down by exam).
  - On error: **all** failing rows listed at once with line numbers (e.g. "Line 14: missing matriculation number"). User can dismiss and fix the CSV before re-importing.
  - On duplicate matriculation within the same exam group: flagged with line numbers.
- Rows with missing matriculation number are **skipped** with a hint in the import result (e.g. "1 entry not imported — line 122: missing matriculation number"). This covers guest students.
- Importing again **replaces** the current participant list (transaction: clear + insert).

### FR-MVP-2 Scanning

- The app shall provide a **camera-based** scanning flow after the user chooses to start scanning.
- The app shall run **OCR on-device** only; no network.
- The app shall extract a **matriculation number candidate**, normalize it, and **exact-match** against the **loaded participant list**.
- No automatic present mark without **explicit user confirmation** after a unique match — confirmation is a **single large tap target** (e.g. a large checkmark button), not a dialog.
- A **short haptic vibration** shall be triggered on successful confirmation. No audio signals.
- If a student is already marked, rescanning shows "Already marked [status]" with a **[Change status]** option. User may change to: present, excused, marked, or not_marked.
- If OCR finds no match: show the extracted matric, a "Not found" message, and two clear actions: **[Rescan]** and **[Manual search]**. No blocking dialogs.

### FR-MVP-3 Matching

- **Exact match** on normalized matriculation number only for the confirmation path.
- If zero or multiple matches, the app shall **not** mark present automatically; user may rescan or use manual search.

### FR-MVP-4 Attendance marking

- Status is stored as an **integer** in the database: `0` = not_marked, `1` = present, `2` = excused, `3` = marked.
- On confirm, the app shall update the row's **status** and **method** (`scan` or `manual`). **MVP:** no stored **timestamps** (`created_at`, `marked_at`, etc.).
- **Duplicate / rescan:** if a student's status is already non-zero, show the current status and offer **[Change status]** — do not silently overwrite.
- Status can be corrected at any time (e.g. to undo a fraud case: set from `present` → `marked`).

### FR-MVP-5 Manual fallback

- **Unified single search field**: user types anything (name fragment, surname, or matriculation number digits) and sees a live-updating result list.
- Scan path uses **exact match only**; manual search uses **substring / fuzzy matching** across both `full_name` and `matriculation_number`.
- Select student from results → confirm present (same confirmation UX as scan path).
- Available even if OCR or camera fails to initialize.
- If manual search finds no result: show "Student not in list" and a **[Back to scanning]** button.

### FR-MVP-6 Live progress and participant list

- Display **present count** and **not-yet-marked count** (or equivalent: present + remaining).
- If CSV contains `exam_group`: show live counts **per exam group** (e.g. "EinfInf 144/164 · AuD 10/16").
- **Full scrollable participant list is MVP** (not post-MVP): shows all participants with their current status (present/excused/marked/not yet marked), sortable by matriculation number, surname, or full name. Tapping a row opens a status-change flow.
- Sort preference persists within the current session.

### FR-MVP-7 Export

- **Explicit Export** action generates a **CSV** saved or shared via local file flows.
- For **every** row from the imported participant list, output at least: identity fields (matriculation_number, full_name, exam_group if present), **`status`** = `present` | `absent` | `excused` | `marked`, and for present rows **`method`** (`scan` | `manual`). **MVP:** no **time** columns in the export.
- **`absent` definition:** at export time, any student with status `not_marked` (0) is written as **`absent`**.
- Export preserves `exam_group` column so the organizer can process exams separately on PC.
- UI shall warn that **unmarked students will appear as absent** in the export (clear copy before or on confirm).

### Post-MVP functional items (reference)

The following are **not required for MVP** but remain valid product direction:

- **FR-X1** Explicit exam session entity with title, date, exam id, draft/active/closed.
- **FR-X2** Structured audit trail for import, mark, duplicate, revert, export.
- **FR-X3** Encryption at rest and extended retention policy controls.
- **FR-X4** Timestamps (`marked_at`) on attendance records for formal audit purposes.

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

- Matriculation numbers are **unique within one exam group** — a student may appear in multiple exam groups (e.g. graded and ungraded variant of the same course). The unique constraint is `UNIQUE(matriculation_number, exam_group)`.
- Organizers can supply a correct CSV before or at exam start.
- Device camera is adequate for near-range capture on supported hardware.
- The exam registration system may export CSVs with different delimiters (comma, semicolon) or character encoding issues (e.g. "Göpfert" → "G?pfert"); the app handles delimiters automatically and tolerates encoding issues without crashing.

## User Flow: MVP exam scenario

1. User opens app and **imports** the participant CSV from the device.
2. User taps **Start scanning** (or equivalent).
3. For each student: scan card → unique match → **Confirm present**; or open **Manual search** → select → confirm.
4. As needed, user checks **present / not yet marked** counts.
5. When finished, user taps **Export**; confirms if prompted; **CSV** contains **present** and **absent** per rules above.

## Export semantics (normative for MVP)

| DB `status` value | CSV `status` output |
|-------------------|---------------------|
| `0` (not_marked)  | `absent`            |
| `1` (present)     | `present`           |
| `2` (excused)     | `excused`           |
| `3` (marked)      | `marked`            |

Second export recomputes from current data; behavior is deterministic from **participant list + stored status values**.
