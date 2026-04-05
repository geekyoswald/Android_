# 4. Data Model Design

## MVP semantics

- The app stores the **participant list** (students from the CSV) and **present confirmations** only.
- **“Not yet marked”** is not a stored value; it is computed as participants without a present record.
- **`absent` in the exported CSV** is **not stored** in MVP: on export, each participant row becomes `present` if a confirmation exists, else **`absent`**.
- **MVP:** no stored **timestamps** (`created_at`, `marked_at`, etc.). **Post-MVP** may add marking time and audit times—see [11_future_improvements.md](11_future_improvements.md).

Post-MVP entities (full `ExamSession` lifecycle, `AuditEvent` table, reversal events) remain valid extensions; see [11_future_improvements.md](11_future_improvements.md).

## Data Modeling Principles

- Use minimal personal data required for attendance verification.
- Keep **participant list** data separate from attendance (present) records.
- Optimize exact lookup by matriculation number and fast search by name.
- Avoid storing raw card images by default.

## Core Entities

### Student (one row from the imported CSV)

Fields:

- `student_id`: local primary key
- `scope_id`: foreign key to implicit session or import batch (MVP: single active scope)
- `matriculation_number`: string
- `full_name`: string
- `search_name_normalized`: string (lowercase, whitespace-normalized for search)
- `seat_number`: nullable string (optional column from CSV; post-MVP if unused)
- `study_program`: nullable string (optional; post-MVP if unused)

Notes:

- `matriculation_number` stored as text to preserve formatting.
- Unique within the active participant list: `(scope_id, matriculation_number)`.

### ExamSession (MVP: minimal)

**MVP options** (choose one in implementation):

- **Option A:** One implicit `scope_id` constant and metadata stored only in export filename or CSV header generated at export.
- **Option B:** Single `ExamSession` row with optional `exam_title` only (no dates/timestamps required for MVP).

Full fields for **post-MVP** expansion:

- `exam_session_id`: primary key
- `exam_code`: string
- `exam_title`: string
- `exam_date`: datetime
- `status`: enum such as `draft`, `active`, `closed`
- `import_version`: optional string or checksum (of the participant CSV)
- `created_at`, `closed_at` (and other metadata timestamps as needed)

### AttendanceRecord (present only in MVP)

Fields:

- `attendance_id`: primary key
- `scope_id` / `exam_session_id`: foreign key
- `student_id`: foreign key
- `marked_by_method`: enum such as `ocr`, `manual_search` (**Post-MVP:** optional `marked_at` or full event history)
- `ocr_confidence`: nullable numeric value (post-MVP diagnostic)
- `ocr_raw_text_excerpt`: nullable short text (post-MVP; only if policy allows)

Notes:

- MVP stores **at most one effective present** per student per scope; duplicates blocked in application logic.
- There is **no** `status: absent` row; absent exists only in **export output**.

### AuditEvent (post-MVP)

Fields (when implemented):

- `event_id`, `exam_session_id`, optional `student_id`, `event_type`, `event_timestamp`, optional `metadata_json`

## Recommended Storage Strategy

- **MVP:** SQLite (or equivalent) in app-private storage; participant list + attendance tables.
- **Post-MVP:** encrypt at rest, formal audit table—see [07_security_and_privacy_design.md](07_security_and_privacy_design.md).
- Do not store card images by default.

## Relational View

```text
ExamSession (optional minimal) 1 --- N Student
ExamSession / scope            1 --- N AttendanceRecord (present only)
Student                        1 --- 0..1 AttendanceRecord (MVP: enforced as 0 or 1 present)
AuditEvent (post-MVP)          N --- 1 ExamSession
```

## Suggested Indexing Strategy

- Unique index on `(scope_id, matriculation_number)`
- Index on `(scope_id, search_name_normalized)` for manual search
- Index on `(scope_id, student_id)` for attendance join

## Lookup Strategy

### Scan-Based Lookup

- Normalize OCR candidate; query `Student` by exact `matriculation_number` within active scope.
- Exactly one row → offer confirmation; zero or many → no auto-mark.

### Manual Search

- Prefix/substring on `search_name_normalized`; matriculation partial or exact as implemented.

## Export Derivation

For export, join `Student` with `AttendanceRecord`:

- If a present record exists for `student_id` → output `status = present` and optionally `marked_by_method` (MVP: **no** time columns).
- Else → output `status = absent`.

## Data Integrity Rules (MVP)

- One row per matriculation per import batch.
- At most one present confirmation per student per active import.
- Export operates on **current** participant list + attendance only; OCR text never exported unless policy requires (post-MVP).
