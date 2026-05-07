# 4. Data Model Design

## MVP semantics (simplified)

MVP assumes **one device per exam** — no exam sessions, batches, or `scope_id`. There is a **single participant list** for that run.

- One SQLite table holds **imported students** and **their current attendance status** on the same row.
- **`status`**: integer code — `0` = not_marked, `1` = present, `2` = excused, `3` = marked.
- **Export**: the `status` integer is converted to a human-readable label (`present`, `absent`, `excused`, `marked`). Any row with `status = 0` is written as **`absent`** in the export file — absent is never stored, only derived.
- **`exam_group`**: optional text column, populated from the CSV. Enables live per-exam counts and multi-exam rooms. Uniqueness is per `(matriculation_number, exam_group)`, not per matriculation number alone.
- **MVP:** no stored **timestamps** (`created_at`, `marked_at`, etc.). May be added post-MVP — see [11_future_improvements.md](11_future_improvements.md).
- **MVP:** no separate **normalized name** column — search uses `full_name` as stored (substring LIKE in queries is enough for MVP).

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
| `matriculation_number` | TEXT NOT NULL | Text preserves formatting; may be empty for guest students (skipped on import with a hint) |
| `full_name` | TEXT NOT NULL | As in CSV |
| `exam_group` | TEXT NOT NULL DEFAULT '' | Exam label from CSV (e.g. "EinfInf", "AuD"); empty string when column absent in CSV |
| `status` | INTEGER NOT NULL DEFAULT 0 | `0` = not_marked, `1` = present, `2` = excused, `3` = marked |
| `marked_by_method` | TEXT NULL | When status ≥ 1: `scan` \| `manual` |

Constraints:

- `UNIQUE(matriculation_number, exam_group)` — one row per student per exam group. Same student in two exam groups is allowed (legitimate dual registration); same student twice in the same group is rejected.

Import replacement (new CSV):

- Delete all rows in `participants`, then insert rows from the new file with `status = 0` (in a transaction).

Marking present (scan or manual):

- Update the matching row: `status = 1` (or 2 for excused, 3 for marked), set `marked_by_method`.

Status correction (re-scan / list tap):

- When a row's `status` is already non-zero, show the current status and offer change options: present, excused, marked, not_marked (undo). This covers fraud correction (mark as `marked` for follow-up) and undo (reset to `not_marked`).

## Post-MVP (reference)

The following are **not** required for MVP but may return if product scope grows:

- `ExamSession`, `scope_id`, multi-exam devices
- `search_name_normalized` or full-text search tuning
- Separate `AttendanceRecord` table if you need richer event history
- `AuditEvent` table
- `marked_at` / `created_at` timestamp columns

## Recommended Storage Strategy

- **MVP:** SQLite in app-private storage; single `participants` table.
- **Post-MVP:** encrypt at rest, formal audit table — see [07_security_and_privacy_design.md](07_security_and_privacy_design.md).
- Do not store card images by default.

## Relational View (MVP)

```text
participants (one row per imported student per exam group; status on same row)
```

## Indexing Strategy (MVP)

- Unique constraint on `(matriculation_number, exam_group)`
- Index on `full_name` to support manual search (substring LIKE)

## Lookup Strategy

### Scan-Based Lookup

- Normalize OCR candidate; query `participants` by exact `matriculation_number`.
- If one row found → offer confirmation. If student is in multiple exam groups → ask which exam. If zero matches → show "Not found" + [Rescan] [Manual search].

### Manual Search

- Unified single search field: match substring on `full_name` and/or `matriculation_number`.
- Results appear as a live-updating list; tap a row to open confirmation flow.

## Export Derivation

For each row in `participants`:

| `status` value | CSV `status` output |
|----------------|---------------------|
| `0` (not_marked) | `absent` |
| `1` (present) | `present` |
| `2` (excused) | `excused` |
| `3` (marked) | `marked` |

Export also includes: `matriculation_number`, `full_name`, `exam_group` (if non-empty), `marked_by_method` (for status ≥ 1).

## Data Integrity Rules (MVP)

- One row per `(matriculation_number, exam_group)` in the current import.
- Status is updated in-place — no second row for a duplicate scan attempt.
- New CSV import replaces all participant rows for the device (single-table clear + insert, transaction).

## CSV import validation

Code: `ovgu_exam_attendance_app/lib/features/import/services/csv_import_validator.dart`

The validator runs on the **raw CSV text** after the user picks a file. It performs **structural and row-level checks**.

**Delimiter auto-detection**: try comma first; if that yields only one column, try semicolon; then tab. No user setting required. Handles exports from German Excel (semicolon) and other tools.

| Check | Result if it fails |
|--------|---------------------|
| File has no non-empty lines | Error: empty file |
| Header row does not contain both required columns | Error: missing columns, list which are missing |
| After the header, there is no data row | Error: headers but no student rows |
| A data row has missing `full_name` | Error: flagged with line number; row skipped |
| A data row has missing `matriculation_number` | Row skipped with hint in import result (guest student case) |
| Duplicate `(matriculation_number, exam_group)` within one file | Warning with line numbers; second row rejected |

**Required column names** (header cells are normalized: trim, lowercase, spaces → underscores):
- `matriculation_number`
- `full_name`

**Optional column names**:
- `exam_group` (any casing; normalized to `exam_group`)

**Error reporting**: all errors and warnings are collected and shown **at once** in the import result card (scrollable). The import is not aborted on the first error — the validator processes all rows. This allows the user to fix everything in one pass before re-importing.

**Import result card (inline, no separate screen)**:
- On success: "Imported 154 students." (or per-exam breakdown if `exam_group` present).
- On partial success: success count + list of skipped/warned rows.
- On failure (unusable file): error summary. Cannot start scanning until a valid import exists.
- Dismiss via OK button.

**DB write (`ParticipantRepository.replaceAllParticipants`):** one **transaction** — `DELETE` all rows in `participants`, then `INSERT` each valid row with `status = 0`. Commit on success; rollback on any failure.

## Implementation Note (Current Progress)

- SQLite setup: `ovgu_exam_attendance_app/lib/core/database/app_database.dart`
- Single table `participants` in app code. **`databaseVersion`** + **`onUpgrade`** in `app_database.dart` follow the pattern documented under **Database versioning** in `README.md`.
- Schema update needed (databaseVersion 2): rename `is_present` → `status` (values 0-3), add `exam_group` column, update UNIQUE constraint to `UNIQUE(matriculation_number, exam_group)`.
- Import replacement (transaction: clear `participants`, insert from CSV) is implemented in `ParticipantRepository` and wired from the import screen after validation + parse.
