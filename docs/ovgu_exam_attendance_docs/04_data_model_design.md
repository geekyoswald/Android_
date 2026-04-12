# 4. Data Model Design

## MVP semantics (simplified)

MVP assumes **one device per exam** — no exam sessions, batches, or `scope_id`. There is a **single participant list** for that run.

- One SQLite table holds **imported students** and **whether each is marked present** on the same row.
- **`is_present`**: `0` = not yet marked at check-in time; `1` = marked present after scan or manual confirmation.
- **Export**: any row still `is_present = 0` is written as **`absent`** in the export file; marked rows are **`present`**. (Product default is CSV; other formats are an implementation detail.)
- **MVP:** no stored **timestamps** (`created_at`, `marked_at`, etc.). **Post-MVP** may add marking time and audit times—see [11_future_improvements.md](11_future_improvements.md).
- **MVP:** no separate **normalized name** column — manual search uses `full_name` as stored (trimming in queries is enough for MVP).

Post-MVP entities (sessions, audit tables, normalized search columns, encryption) remain valid extensions; see [11_future_improvements.md](11_future_improvements.md).

## Data Modeling Principles

- Use minimal personal data required for attendance verification.
- One table for MVP keeps import + marking + export logic straightforward on a single device.
- Optimize exact lookup by matriculation number; name search uses `full_name` as imported.
- Avoid storing raw card images by default.

## MVP: single table `participants`

| Column | Type | Notes |
|--------|------|--------|
| `id` | INTEGER PK | Auto-increment |
| `matriculation_number` | TEXT NOT NULL | Unique per import; text preserves formatting |
| `full_name` | TEXT NOT NULL | As in CSV |
| `is_present` | INTEGER NOT NULL DEFAULT 0 | `0` = not marked, `1` = present |
| `marked_by_method` | TEXT NULL | When `is_present = 1`: e.g. `scan` \| `manual` (for export column if used) |

Constraints:

- `UNIQUE(matriculation_number)` — one row per matriculation after each import.

Import replacement (new CSV):

- Delete all rows in `participants`, then insert rows from the new file with `is_present = 0` (in a transaction).

Marking present (scan or manual):

- Update the matching row: `is_present = 1`, set `marked_by_method` as applicable.

Duplicate present attempt:

- Detected when `is_present` is already `1`; show warning; do not require a second row.

## Post-MVP (reference)

The following are **not** required for MVP but may return if product scope grows:

- `ExamSession`, `scope_id`, multi-exam devices
- `search_name_normalized` or full-text search tuning
- Separate `AttendanceRecord` table if you need richer event history
- `AuditEvent` table

## Recommended Storage Strategy

- **MVP:** SQLite in app-private storage; single `participants` table.
- **Post-MVP:** encrypt at rest, formal audit table—see [07_security_and_privacy_design.md](07_security_and_privacy_design.md).
- Do not store card images by default.

## Relational View (MVP)

```text
participants (one row per imported student; present flag on same row)
```

## Indexing Strategy (MVP)

- Unique constraint on `matriculation_number`
- Index on `full_name` to support simple manual search (substring / LIKE as implemented)

## Lookup Strategy

### Scan-Based Lookup

- Normalize OCR candidate; query `participants` by exact `matriculation_number`.
- Exactly one row → offer confirmation; zero or many → no auto-mark.

### Manual Search

- Match on `full_name` and/or `matriculation_number` as implemented (no separate normalized column in MVP).

## Export Derivation

- For each row in `participants`:
  - If `is_present = 1` → `status = present` (optionally include `marked_by_method`).
  - Else → `status = absent`.

## Data Integrity Rules (MVP)

- One row per matriculation in the current import.
- At most one present mark per row (same row updated).
- New CSV import replaces all participant rows for the device (single-table clear + insert).

## CSV import validation (implemented)

Code: `ovgu_exam_attendance_app/lib/features/import/services/csv_import_validator.dart`

The validator runs on the **raw CSV text** after the user picks a file. It performs **structural checks** on headers and line count.

| Check | Result if it fails |
|--------|---------------------|
| File has no non-empty lines | Error: empty file |
| Header row (first non-empty line) does not contain both required columns | Error: missing columns |
| After the header, there is no data row | Error: headers but no student rows |

**Required column names** (header cells are normalized: trim, lowercase, spaces → underscores, so `Full Name` matches `full_name`):

- `matriculation_number`
- `full_name`

**Success:** returns a student row count (number of data lines after the header).

**Row parsing (`CsvParticipantParser`):** after validation succeeds, each data row is parsed; **empty matriculation or full name** in a row fails with a line-specific error. **Duplicate matriculation** in one file fails on insert (`UNIQUE` constraint; transaction rolls back).

**DB write (`ParticipantRepository.replaceAllParticipants`):** one **transaction** — `DELETE` all rows in `participants`, then `INSERT` each row with `is_present = 0`. Commit on success; rollback on any failure.

**Import screen (UX):** after a successful flow, the UI shows **two lines**: first *Imported CSV: … (N students).*, then *Saved to database.* underneath. If saving fails after a good read, the second line can show a save error instead.

## Implementation Note (Current Progress)

- SQLite setup: `ovgu_exam_attendance_app/lib/core/database/app_database.dart`
- Single table `participants` in app code. **`databaseVersion`** + **`onUpgrade`** in `app_database.dart` follow the pattern documented under **Database versioning** in `README.md` (bump version and add migrations for store updates; during dev you can wipe the DB while iterating).
- Import replacement (transaction: clear `participants`, insert from CSV) is implemented in `ParticipantRepository` and wired from the import screen after validation + parse.
