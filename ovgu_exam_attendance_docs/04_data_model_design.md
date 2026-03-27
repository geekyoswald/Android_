# 4. Data Model Design

## Data Modeling Principles

- Use minimal personal data required for attendance verification.
- Separate roster data from attendance events.
- Preserve auditability without storing unnecessary raw artifacts.
- Optimize exact lookup by matriculation number and fast search by name.

## Core Entities

### Student

Fields:

- `student_id`: local primary key
- `exam_session_id`: foreign key to exam session
- `matriculation_number`: string
- `full_name`: string
- `search_name_normalized`: string
- `seat_number`: nullable string
- `study_program`: nullable string
- `created_at`: timestamp

Notes:

- `matriculation_number` should be stored as text, not integer, to preserve formatting consistency.
- `search_name_normalized` should contain a lowercase, whitespace-normalized version of the name for efficient manual lookup.

### ExamSession

Fields:

- `exam_session_id`: primary key
- `exam_code`: string
- `exam_title`: string
- `exam_date`: datetime
- `status`: enum such as `draft`, `active`, `closed`
- `roster_version`: optional string or checksum
- `created_at`: timestamp
- `closed_at`: nullable timestamp

### AttendanceRecord

Fields:

- `attendance_id`: primary key
- `exam_session_id`: foreign key
- `student_id`: foreign key
- `status`: enum such as `present` or `reverted`
- `marked_at`: timestamp
- `marked_by_method`: enum such as `ocr`, `manual_search`, `manual_entry`
- `ocr_confidence`: nullable numeric value
- `ocr_raw_text_excerpt`: nullable short text if retention is justified
- `notes`: nullable text

Notes:

- The design should prefer append-only attendance events for auditability.
- A derived current status view or cached current-state table may be added for fast list rendering.

### AuditEvent

Fields:

- `event_id`: primary key
- `exam_session_id`: foreign key
- `student_id`: nullable foreign key
- `event_type`: enum such as `import`, `mark_present`, `duplicate_detected`, `revert`, `export`
- `event_timestamp`: timestamp
- `metadata_json`: nullable structured metadata

## Recommended Storage Strategy

- Use SQLite as the primary local database.
- Store the database in app-private storage only.
- Apply encryption at rest.
- Do not store card images by default.
- Retain OCR raw text only if required for troubleshooting and only in minimized form.

## Relational View

```text
ExamSession 1 --- N Student
ExamSession 1 --- N AttendanceRecord
Student     1 --- N AttendanceRecord
ExamSession 1 --- N AuditEvent
Student     0 --- N AuditEvent
```

## Suggested Indexing Strategy

Required indexes:

- Unique index on `(exam_session_id, matriculation_number)`
- Index on `(exam_session_id, search_name_normalized)`
- Index on `(exam_session_id, marked_at)` for attendance review and export
- Index on `(exam_session_id, status)` or equivalent current-state structure

Optional optimization:

- If roster size becomes large, maintain a materialized current attendance table keyed by `student_id`.

## Lookup Strategy

### Scan-Based Lookup

- Normalize the OCR candidate value.
- Query `Student` by exact `matriculation_number` within the active `exam_session_id`.
- If exactly one row is found, show confirmation.
- If none is found, route to rescan or manual fallback.

### Manual Search

- Search by normalized prefix of `search_name_normalized`.
- Search by exact or partial matriculation number where appropriate.
- Return a short list optimized for quick selection.

## Data Integrity Rules

- A student may exist only once per exam roster.
- Attendance should not be marked twice as valid `present` for the same student in the same session.
- Reversal actions must remain auditable.
- Export should operate only on the active confirmed dataset, not unvalidated transient OCR output.
