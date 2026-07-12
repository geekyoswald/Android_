# Commit Roadmap — OVGU Exam Attendance MVP

Each commit is one screen, one layer, or one clear responsibility.
🟢 = done | ⬜ = pending

---

## 🟢 Commit 1 — `chore: update db schema (status, exam_group, composite unique)`

**Files:** `app_database.dart`, `database_constants.dart`

- Renamed `is_present` → `status` (0 = not_marked, 1 = present, 2 = excused, 3 = marked)
- Added `exam_group TEXT NOT NULL DEFAULT ''` column
- Changed unique constraint to `UNIQUE(matriculation_number, exam_group)`
- Removed all migration/upgrade logic (exam-time app, no long-term retention)

---

## 🟢 Commit 2 — `feat: add examGroup to domain model, add ImportResult type`

**Files:** `participant_import_row.dart`, `import_result.dart` (new)

- Added `examGroup` field to `ParticipantImportRow`
- Created `ImportIssue` (lineNumber + message) and `ImportResult` (rows, errors, skippedRows, isUsable)

---

## 🟢 Commit 3 — `feat: auto-detect CSV delimiter, collect all parse errors, handle guest rows`

**Files:** `csv_text.dart`, `csv_import_validator.dart`, `csv_participant_parser.dart`, `main.dart`

- Added `detectDelimiter()` — tries comma, semicolon, tab
- Updated `parseCsvLine()` to accept a delimiter parameter
- Rewrote parser to return `ImportResult` instead of throwing — collects all errors at once
- Rows with missing matriculation are skipped with a hint (guest student case)
- `main.dart` updated to consume `ImportResult`

---

## 🟢 Commit 4 — `feat: align repository with status and exam_group columns`
*(bundled in `9effb3c`)*

**Files:** `participant_repository.dart`

- Replace `is_present: 0` with `status: 0` in INSERT
- Add `exam_group: row.examGroup` to INSERT

---

## 🟢 Commit 5 — `feat: detect duplicate (matriculation, exam_group) pairs`
*(bundled in `9effb3c`)*

**Files:** `csv_participant_parser.dart`, `test/unit/csv_participant_parser_test.dart`, `test_csv_files/016-018`

- Duplicate `(matriculation_number, exam_group)` pair = HARD ERROR (blocks import, lists all line numbers)
- Same matriculation in different exam_groups = ALLOWED (legitimate multi-exam registration)
- 5 new unit tests, 3 new test CSV files (016, 017, 018)

---

## 🟢 Commit 6 — `refactor: extract ImportScreen to its own file`

**Files:** `import_screen.dart` (new), `main.dart`

- Moved `ImportScreen` StatefulWidget from `main.dart` to `lib/features/import/presentation/screens/import_screen.dart`
- `main.dart` keeps only `main()` and `OvguAttendanceApp`

---

## 🟢 Commit 7 — `feat: import result card with per-exam breakdown and dismiss button`

**Files:** `import_screen.dart`

- Replaced inline status text with a proper result card widget
- Success: shows total count + per-exam-group breakdown ("144 EinfInf, 10 AuD")
- Error: shows all hard errors with line numbers (scrollable)
- Skipped rows listed with line numbers under a separator
- OK button and × icon to dismiss the card
- Color-coded (green = success, red = blocked)

---

## 🟢 Commit 8 — `test: unit + integration tests for CSV import services`
*(bundled in `9effb3c`)*

**Files:** `test/unit/csv_text_test.dart`, `test/unit/csv_import_validator_test.dart`, `test/unit/csv_participant_parser_test.dart`, `test/integration/csv_import_integration_test.dart`, `test_csv_files/001–018`

**Test coverage:**
- `detectDelimiter()` — comma, semicolon, tab auto-detection
- `parseCsvLine()` — different delimiters, quoted values, escaping edge cases
- `CsvImportValidator` — missing headers, empty file, header detection, row counting
- `CsvParticipantParser` — valid rows, missing matric (skipped), missing full_name (error), all errors collected, exam_group parsing, duplicate detection
- Integration tests — full validate → parse workflows with real CSV files from disk
- 18 test CSV files covering all valid, invalid, partial-error and duplicate scenarios

**Run:** `flutter test`

---

## 🟢 Commit 9 — `feat: app navigation with named routes and placeholder screens`

**Files:** `main.dart`, `scan_screen.dart` (new), `participant_list_screen.dart` (new), `export_screen.dart` (new)

- `AppRoutes` class with named route constants (`/`, `/scan`, `/participants`, `/export`)
- Placeholder screens for scan, participant list, export
- Import screen "Start Scanning" button navigates to scan screen after successful import

---

## 🟢 Commit 10 — `feat: add app theme with colors, typography, and shared styles`

**Files:** `app_theme.dart` (new), `main.dart`

- Defined app color scheme (primary blue, teal, success green, error red, warning orange)
- Created Material 3 theme with typography, button styles, chip styles, input decoration
- Added status colors for different attendance states (not marked, present, excused, marked)
- Implemented shared style helpers: `statusChip()`, `successTextStyle()`, `errorTextStyle()`, `warningTextStyle()`
- Added spacing and border radius constants for consistent UI
- Applied `AppTheme.lightTheme()` to `MaterialApp` in main.dart

---

## 🟢 Commit 11 — `feat: participant repository — read queries`

**Files:** `participant_repository.dart`

- `getAllParticipants()` — fetch all rows ordered by full_name
- `getStatusCounts()` — returns count of each status (0–3)
- `getCountsByExamGroup()` — returns per-exam-group present/total counts for live progress

---

## 🟢 Commit 12 — `feat: participant repository — write queries (mark/update status)`

**Files:** `participant_repository.dart`

- `updateStatus(int id, int status, String method)` — update a student's status and method
- Covers: mark present, mark excused, mark flagged, undo (reset to not_marked)

---

## 🟢 Commit 13 — `feat: participant repository — unified search query`

**Files:** `participant_repository.dart`

- `searchParticipants(String query)` — substring match on both `full_name` and `matriculation_number` using LIKE
- Returns ordered results (exact matric match ranked first)

---

## 🟢 Commit 14 — `feat: participant list screen — scrollable list with status indicators`

**Files:** `participant_list_screen.dart`

- Full scrollable list of all participants
- Each row: name, matriculation, exam_group (if any), status chip
- Live-updating from repository on screen open

---

## 🟢 Commit 15 — `feat: participant list screen — sort control`

**Files:** `participant_list_screen.dart`

- Sort dropdown/toggle: by matriculation number / surname / full name
- Sort preference persists for the session

---

## 🟢 Commit 16 — `feat: participant list screen — tap row to change status`

**Files:** `participant_list_screen.dart`

- Tap a row → bottom sheet with status options (present / excused / marked / undo)
- Calls `updateStatus()`, refreshes list immediately

---

## 🟢 Commit 17 — `fix: re-enable import buttons on app restart if participants already in DB`

**Files:** `import_screen.dart`

- Added `_checkExistingData()` in `initState` — queries `getStatusCounts()` on launch
- If total > 0, sets `_isImportSuccessful = true` so "Start Scanning" and "View Participant List" buttons are re-enabled immediately
- Fixes bug where buttons were disabled on every app restart despite data being persisted in SQLite

---

## 🟢 Commit 18 — `test: unit tests for participant repository`

**Files:** `test/data/participant_repository_test.dart` (new)

**Test coverage:**
- `getAllParticipants()` — returns all rows, ordered by full_name
- `getStatusCounts()` — counts for each status (0–3)
- `getCountsByExamGroup()` — per-exam counts (EinfInf: 5/10, AuD: 3/8)
- `searchParticipants()` — substring match, exact matric ranked first
- `updateStatus()` — status and method updates, DB persistence
- `replaceAllParticipants()` — clear-and-insert transaction, returns count

**Run:** `flutter test test/data/participant_repository_test.dart`

---

## 🟢 Commit 19 — `test: integration test for participant list operations`

**Files:** `test/integration/participant_list_test.dart` (new — widget test using
`sqflite_common_ffi` in-memory DB rather than the `integration_test` package, since
`ParticipantListScreen` doesn't require a real device/emulator to test this way)

**Test flow:**
- Import 10 students (various exam groups) directly via the repository
- Open ParticipantListScreen
- Verify: all visible students shown, status = "not marked"
- Test sorting: tap sort control, sort by matric/surname/name
- Verify: list reorders correctly for each sort
- Tap a row
- Verify: status options appear (present/excused/marked/undo)
- Change status to "present"
- Verify: chip updates immediately, status persists in DB

**Also fixed:** real bottom-sheet overflow bug on short viewports (wrapped in
`SingleChildScrollView` with dynamic bottom padding).

**Deferred (2 tests removed from the file, not just skipped):**
- "marking a student excused shows Excused chip"
- "undoing a pre-marked present status shows Not marked chip again"

Both were written and pass their assertions, but triggered what turned out to be a
**process-teardown hang** (`flutter test` never exits after a real
`sqflite_common_ffi` DB write inside `tester.runAsync`) — confirmed unrelated to
test content, since the hang persists even when the DB-writing test is the very
last test in the file. See `TESTING_NOTES.md` for the full debugging log. Deferred
to Commit 28 below to keep moving on the roadmap.

**Known issue affecting this file today:** even the 10 remaining committed tests
will hang the `flutter test` *process* after the last test prints, though every
assertion passes correctly before that point. Manually interrupt the process once
the final test line appears in output.

**Run:** `flutter test test/integration/participant_list_test.dart`

---

## 🟢 Commit 20 — `feat: manual search screen — unified field, live results, and navigation`

**Files:** `manual_search_screen.dart`, `main.dart`, `import_screen.dart`

- Single search field (name or matric)
- Live-updating result list as user types (calls `searchParticipants`)
- "Student not in list" message + Back button if no results
- Wire route into `AppRoutes` in `main.dart`
- Add "Manual Search" button on import screen (enabled after import)

> **Note:** `manual_search_screen.dart` file already exists but is not yet wired into navigation — route and entry button still need to be added.

---

## 🟢 Commit 21 — `feat: confirmation screen — shared widget with haptic feedback`

**Files:** `confirmation_screen.dart` (new)

- Shows: full name, matriculation, exam_group
- Single large "✓ Confirm" tap target — no dialog
- Haptic vibration on confirm
- Calls `updateStatus()`, returns to caller screen
- Reused by both manual search and scan paths

---

## 🟢 Commit 22 — `feat: scan screen — camera permission, live preview, and tap-to-scan`

**Files:** `scan_screen.dart`, `pubspec.yaml` (camera dependency)

- Request and handle camera permission
- Live camera preview with framing guide overlay
- **Tap-to-scan button** — student holds card steady, taps once to trigger capture (no timer/continuous processing)
  - Avoids motion-blur from timer-triggered frames
  - Same approach used by professional scanner apps
  - ML Kit OCR engine is identical to Google Lens on-device — accuracy is proven
- Present/not-yet-marked live count (calls `getStatusCounts`)
- Per-exam count if exam_group present
- Entry points to manual search and participant list

---

## 🟢 Commit 23 — `feat: OCR — on-device text extraction and matric detection`

**Files:** `ocr_service.dart` (new), `pubspec.yaml` (OCR dependency)

- Integrate on-device OCR engine (Google ML Kit)
- Extract raw text from camera frame
- Detect matric number using label-based extraction: `RegExp(r'Matrikel-Nr\.?:?\s*(\d+)')`
- Return matric candidate (purely numeric — no character substitution normalization)

---

## 🟢 Commit 24 — `feat: matching engine and scan result UX`

**Files:** `matching_engine.dart` (new), `scan_screen.dart`

- Exact match of OCR candidate against participant list
- Result states:
  - Unique match → navigate to confirmation screen
  - Already marked → show current status + [Change status] option
  - Multiple exam groups → disambiguation prompt ("Which exam?")
  - No match → show "Not found" + [Rescan] [Manual search] buttons
- No fuzzy matching on scan path

---

## 🟢 Commit 25 — `test: unit tests for matching engine`

**Files:** `test/matching_engine_test.dart` (new)

**Test coverage:**
- Exact match: matric found in list → returns match
- No match: matric not in list → returns empty
- Multiple exam groups: student in EinfInf + AuD → returns disambiguation state
- Already marked: status ≠ 0 → returns "already marked" with current status
- Edge cases: empty list, empty matric candidate

**Run:** `flutter test test/matching_engine_test.dart`

---

## 🟢 Commit 26 — `feat: export attendance CSV + remove marked_by_method`

**Files:** `export_service.dart` (new), `export_screen.dart`, `participant_repository.dart`, `participant.dart`, `app_database.dart`, `database_constants.dart`, `confirmation_screen.dart`, `main.dart`, `scan_screen.dart`, `manual_search_screen.dart`, `participant_list_screen.dart`, tests

- Read all participants from DB
- Map status integers to labels: 0 → absent, 1 → present, 2 → excused, 3 → marked
- Write CSV: matriculation_number, full_name, exam_group, status
- Appends summary block: total / present / absent / excused / marked
- Save to folder via FilePicker (Android SAF / iOS Files)
- Warn user: "Unmarked students will appear as absent"
- Removed marked_by_method column entirely (DB version bumped to 2)
- Simplified updateStatus(id, status) — no method param

---

## 🟢 Commit 27 — `test: widget tests with fake repository (replaces commits 27+28)`

- All 6 screens refactored to accept an optional `repository` parameter
- `FakeParticipantRepository` added — in-memory, no real DB, no hanging
- `participant_list_test.dart` rewritten with fake repo; previously-hanging excused/undo tests now pass
- New `confirmation_screen_test.dart` and `manual_search_screen_test.dart`
- **145 tests, all passing**
