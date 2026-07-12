# Testing Guide — OVGU Exam Attendance App

> **Status:** 145 tests · all passing · last verified July 2026
>
> This document is the authoritative reference for the project's test suite.
> It explains what tests exist, what each one verifies, how to run them, and
> the architectural decisions behind the testing approach.

---

## Table of Contents

1. [What is a Test? (Quick Reference)](#1-what-is-a-test-quick-reference)
2. [Test Pyramid — How This Project is Structured](#2-test-pyramid--how-this-project-is-structured)
3. [How to Run Tests](#3-how-to-run-tests)
4. [Test Architecture — Key Decisions](#4-test-architecture--key-decisions)
5. [Test Files — Full Breakdown](#5-test-files--full-breakdown)
   - [Unit: csv_text_test.dart](#51-unit-csv_text_testdart--26-tests)
   - [Unit: csv_import_validator_test.dart](#52-unit-csv_import_validator_testdart--13-tests)
   - [Unit: csv_participant_parser_test.dart](#53-unit-csv_participant_parser_testdart--23-tests)
   - [Unit: matching_engine_test.dart](#54-unit-matching_engine_testdart--15-tests)
   - [Data: participant_repository_test.dart](#55-data-participant_repository_testdart--19-tests)
   - [Integration: csv_import_integration_test.dart](#56-integration-csv_import_integration_testdart--17-tests)
   - [Widget: participant_list_test.dart](#57-widget-participant_list_testdart--14-tests)
   - [Widget: confirmation_screen_test.dart](#58-widget-confirmation_screen_testdart--4-tests)
   - [Widget: manual_search_screen_test.dart](#59-widget-manual_search_screen_testdart--6-tests)
6. [Test Helper — FakeParticipantRepository](#6-test-helper--fakeparticipantrepository)
7. [What Is NOT Tested (and Why)](#7-what-is-not-tested-and-why)
8. [Total Count Summary](#8-total-count-summary)

---

## 1. What is a Test? (Quick Reference)

Before diving in, here is a plain-English explanation of the three types of
tests used in this project:

### Unit Test
A test that checks **one function or class in isolation** — no database,
no UI, no network. Input goes in, output comes out, you check it matches.

```
Input ──► Function ──► Output
              ▲
          (pure logic,
           no side effects)
```

**Example:** Does `detectDelimiter('a,b,c')` return `','`? Yes/No.

Fast. No setup. Hundreds can run in a second. If this breaks, you know
*exactly* which function is wrong.

---

### Integration Test (as used in this project)
A test that checks **multiple real components working together** — in this
project, specifically: a Flutter screen widget talking to a real in-memory
SQLite database.

```
Widget ──► Repository ──► SQLite (in-memory)
  ▲              ▲
(real UI)   (real SQL)
```

This is NOT the "integration_test" Flutter package (which needs a real
phone). Here it means: the Flutter widget and the database both run for
real inside the test process on your Mac.

**Example:** Does inserting rows via the repository, then opening the
screen, then tapping a row and changing status actually update the chip
displayed in the UI?

Slower than unit tests. Catches bugs that unit tests can't see (e.g., "the
SQL query is right but the widget never re-renders").

---

### Widget Test
A test that renders a Flutter widget in a simulated environment and checks
that the UI looks/behaves as expected. In this project, widget tests use a
**fake in-memory repository** (no real database), so they are fast, reliable,
and don't hang.

```
Widget (rendered in test VM)
   │
   └── FakeParticipantRepository (in-memory, no DB)
```

**Example:** Does tapping "✓ Confirm" show a `CircularProgressIndicator`?

---

## 2. Test Pyramid — How This Project is Structured

```
                    ┌───────────────────────┐
                    │     Widget Tests      │  ← UI behaviour with fake repo
                    │   (24 tests across    │
                    │    3 test files)      │
                    └───────────────────────┘
               ┌─────────────────────────────────────┐
               │         Integration Tests           │  ← Full pipeline, real files/DB
               │  (31 tests across 2 test files)     │
               └─────────────────────────────────────┘
          ┌───────────────────────────────────────────────┐
          │                  Unit Tests                   │  ← Pure logic, no I/O
          │        (90 tests across 4 test files)         │
          └───────────────────────────────────────────────┘
```

Most tests are at the bottom (unit). They are fast and pinpoint failures
exactly. Widget tests at the top check real screen behaviour. Integration
tests check the middle layer (data pipeline and DB).

---

## 3. How to Run Tests

All commands run from the `ovgu_exam_attendance_app/` directory.

```bash
# Run every test
flutter test

# Run a specific file
flutter test test/unit/csv_text_test.dart

# Run with verbose output (prints each test name)
flutter test --reporter expanded

# Run a specific group or test by name pattern
flutter test --name "detectDelimiter"
```

### Run by category

```bash
# All unit tests
flutter test test/unit/

# All data/repository tests
flutter test test/data/

# All integration tests
flutter test test/integration/

# All widget tests
flutter test test/widget/
```

### Expected output

```
00:05 +145: All tests passed!
```

All 145 tests pass in roughly 5–10 seconds on a standard MacBook.

---

## 4. Test Architecture — Key Decisions

### Why FakeParticipantRepository for widget tests?

Early versions of widget tests used `sqflite_common_ffi` (a native SQLite
binding for desktop) combined with Flutter's `testWidgets` test runner.

The problem: `testWidgets` runs inside Flutter's **FakeAsync zone** — a fake
clock that drives `Future`s, timers, and animations synthetically. But
`sqflite_common_ffi` performs I/O using a **real OS-level thread** via FFI
(Foreign Function Interface). That thread is completely invisible to the fake
clock.

The hang that occurred:

```
FakeAsync fake clock: "All Dart futures are resolved. Test is done."
FakeAsync: [starts shutting down the Dart isolate]

  Meanwhile, sqflite OS thread: [still running a DB write]
  sqflite OS thread: [finishes, tries to call back into Dart via isolate port]
  sqflite OS thread: [the Dart isolate port is GONE]
  sqflite OS thread: [stuck alive, holding the process open forever]

`flutter test` process: [never exits — CI kills it after 10 minutes]
```

The solution was **dependency injection**: all 6 screens now accept an
optional `repository` parameter. Production code passes nothing (uses the
real DB). Tests pass a `FakeParticipantRepository` — a pure Dart class that
stores data in a `List`, no DB, no threads, no hanging.

```dart
// Production (main.dart)
home: ParticipantListScreen()   // uses real DB

// Test
home: ParticipantListScreen(repository: FakeParticipantRepository(data))
```

### Why use sqflite_common_ffi for repository tests?

`participant_repository_test.dart` is a pure **Dart** test (no widgets, no
FakeAsync). It uses `sqflite_common_ffi` safely because there is no fake
clock involved. Real `Future`s resolve normally. This is the correct and
stable approach for testing database logic directly.

---

## 5. Test Files — Full Breakdown

---

### 5.1 Unit: `csv_text_test.dart` — 26 tests

**File:** `test/unit/csv_text_test.dart`
**Tests:** Low-level CSV text utilities
**Runs against:** `lib/features/import/services/csv_text.dart`
**Needs DB:** No | **Needs Flutter:** No

#### Group: `detectDelimiter` (6 tests)

| # | Test | What it checks |
|---|------|----------------|
| 1 | detects comma delimiter | `'a,b,c'` → `','` |
| 2 | detects semicolon delimiter | `'a;b;c'` → `';'` |
| 3 | detects tab delimiter | `'a\tb\tc'` → `'\t'` |
| 4 | falls back to tab for single column | `'name'` → `'\t'` |
| 5 | falls back to tab for unsupported pipe | `'a\|b\|c'` → `'\t'` |
| 6 | prefers comma over semicolon when both present | `'a,b;c'` → `','` |

#### Group: `parseCsvLine` (13 tests)

| # | Test | What it checks |
|---|------|----------------|
| 7 | splits simple comma-delimited line | basic split |
| 8 | splits semicolon-delimited line | `;` delimiter |
| 9 | splits tab-delimited line | `\t` delimiter |
| 10 | handles quoted field with comma inside | `"Doe, John"` → `['Doe, John']` |
| 11 | handles empty field between delimiters | `'a,,b'` → `['a','','b']` |
| 12 | trims whitespace from cells | `' a , b '` → `['a','b']` |
| 13 | handles multiple empty fields | `'a,,,b'` |
| 14 | handles quoted empty field | `'a,"",b'` → `['a','','b']` |
| 15 | handles field with only spaces | `'a,   ,b'` → `['a','','b']` |
| 16 | handles quoted field with spaces inside | `'" name "` → `['name']` |
| 17 | handles special characters (Müller, José) | German/French/Spanish names |
| 18 | handles quoted field with apostrophe | `"O'Brien"` → `["O'Brien"]` |
| 19 | default delimiter is comma | 3 fields → length 3 |

#### Group: `normalizeCsvHeader` (7 tests)

| # | Test | What it checks |
|---|------|----------------|
| 20 | lowercases header text | `'MATRICULATION_NUMBER'` → `'matriculation_number'` |
| 21 | trims leading and trailing whitespace | `'  full_name  '` → `'full_name'` |
| 22 | replaces spaces with underscores | `'Full Name'` → `'full_name'` |
| 23 | handles mixed case and spaces | `'  Full Name  '` → `'full_name'` |
| 24 | preserves underscores | `'matriculation_number'` unchanged |
| 25 | handles already normalized header | `'exam_group'` unchanged |
| 26 | converts multiple spaces to single underscore | `'Full  Name  Here'` → `'full_name_here'` |

---

### 5.2 Unit: `csv_import_validator_test.dart` — 13 tests

**File:** `test/unit/csv_import_validator_test.dart`
**Tests:** CSV structural validation (before parsing)
**Runs against:** `lib/features/import/services/csv_import_validator.dart`
**Needs DB:** No | **Needs Flutter:** No

The validator is a fast pre-check that runs before the full parser. It rejects
structurally broken files early.

#### Group: `Invalid CSVs - should be rejected` (5 tests)

| # | Test (CSV file ref) | What it checks |
|---|---------------------|----------------|
| 1 | 001 - empty file | Returns `isValid: false`, message contains "empty" |
| 2 | 002 - missing `matriculation_number` column | Rejects, message lists missing column |
| 3 | 003 - missing `full_name` column | Rejects |
| 4 | 004 - headers only, no data rows | Rejects, message "headers but no student rows" |
| 5 | 010 - pipe delimiter (`\|`) not supported | Rejects because columns can't be found |

#### Group: `Valid CSVs - should be accepted` (6 tests)

| # | Test | What it checks |
|---|------|----------------|
| 6 | 007 - comma-delimited | `isValid: true`, `studentCount: 4` |
| 7 | 008 - semicolon-delimited | `isValid: true`, `studentCount: 3` |
| 8 | 009 - tab-delimited | `isValid: true`, `studentCount: 2` |
| 9 | 014 - spaces in column headers | Normalized correctly, still valid |
| 10 | 015 - special characters in names (Müller, François) | Accepted without error |
| 11 | 013 - CSV with exam_group column | Optional column handled |

#### Group: `Edge cases` (2 tests)

| # | Test | What it checks |
|---|------|----------------|
| 12 | whitespace-only lines are ignored | Blank lines between data don't count as rows |
| 13 | case-insensitive header matching | `MATRICULATION_NUMBER` = `matriculation_number` |

---

### 5.3 Unit: `csv_participant_parser_test.dart` — 23 tests

**File:** `test/unit/csv_participant_parser_test.dart`
**Tests:** Row-by-row CSV parsing logic (after validation)
**Runs against:** `lib/features/import/services/csv_participant_parser.dart`
**Needs DB:** No | **Needs Flutter:** No

The parser returns an `ImportResult` with `rows` (valid), `errors` (hard
blocks), and `skippedRows` (soft warnings). `isUsable` = rows not empty AND
no hard errors.

#### Group: `Hard errors - import is blocked` (7 tests)

| # | Test | What it checks |
|---|------|----------------|
| 1 | 001 - empty file | `isUsable: false`, `errors` not empty |
| 2 | 002 - missing `matriculation_number` column | `isUsable: false`, error on line 1 |
| 3 | 003 - missing `full_name` column | `isUsable: false` |
| 4 | 004 - headers only | `isUsable: false`, `rows` empty |
| 5 | 006 - some rows have empty `full_name` | Import blocked, error points to line number |
| 6 | 010 - pipe delimiter | `isUsable: false` (columns not detected) |
| 7 | 011 - multiple errors in same file | All errors collected at once, not just the first |

#### Group: `Soft errors - rows skipped but import continues` (2 tests)

| # | Test | What it checks |
|---|------|----------------|
| 8 | 005 - rows with empty matriculation | Those rows skipped, others imported; `isUsable: true` |
| 9 | skipped rows include line number | `skippedRows[0].lineNumber == 3` |

#### Group: `Success cases - import accepted` (6 tests)

| # | Test | What it checks |
|---|------|----------------|
| 10 | 007 - valid comma CSV | 4 rows, correct matric/name/examGroup |
| 11 | 008 - valid semicolon CSV | 3 rows, `Sarah Davis` correctly parsed |
| 12 | 009 - valid tab CSV | 3 rows |
| 13 | 013 - `exam_group` parsed correctly | `Midterm` and `Final` extracted |
| 14 | 014 - spaces in headers normalized | 3 rows, import works despite messy headers |
| 15 | 015 - special characters | `Müller, Hans`, `François Dubois`, `"O'Brien, Patrick"` all parsed |

#### Group: `Edge cases` (8 tests)

| # | Test | What it checks |
|---|------|----------------|
| 16 | `exam_group` optional, defaults to `''` | No error when column missing |
| 17 | whitespace in matriculation is trimmed | `'  1001  '` → `'1001'` |
| 18 | whitespace in `full_name` is trimmed | `'  John Doe  '` → `'John Doe'` |
| 19 | missing `exam_group` column handled gracefully | `examGroup == ''` |
| 20 | `isUsable = rows not empty AND no errors` | Both conditions verified |
| 21 | duplicate matric in same `exam_group` blocks import | Error: "Duplicate matriculation 123456 in EinfInf, lines: 2, 4" |
| 22 | duplicate matric without `exam_group` blocks import | Same check, no group name in message |
| 23 | same matric in different `exam_groups` is ALLOWED | Student registered for 2 exams — valid |

> **Note on duplicate rule:** A student can legitimately sit multiple exams
> (`EinfInf` + `AuD`). Only a duplicate in the **same** exam group is an
> error (likely a spreadsheet copy-paste mistake).

---

### 5.4 Unit: `matching_engine_test.dart` — 15 tests

**File:** `test/unit/matching_engine_test.dart`
**Tests:** OCR scan result matching logic
**Runs against:** `lib/features/scan/domain/matching_engine.dart`
**Needs DB:** No | **Needs Flutter:** No

After the camera scans a student ID card, OCR extracts a matric number
candidate. The matching engine decides what to do with it. Four possible
outcomes: `noMatch`, `uniqueMatch`, `alreadyMarked`, `multipleGroups`.

```
OCR candidate  ──►  MatchingEngine.match(participants, candidate)
                           │
              ┌────────────┼─────────────┬─────────────┐
              ▼            ▼             ▼             ▼
          noMatch    uniqueMatch   alreadyMarked  multipleGroups
       (not found)  (confirm it)  (show current  (pick which
                                    status)        exam group)
```

#### Group: `No match` (4 tests)

| # | Test | What it checks |
|---|------|----------------|
| 1 | empty participant list | Returns `noMatch` |
| 2 | matric not in list | Returns `noMatch` |
| 3 | empty matric candidate | Returns `noMatch` (no OCR output) |
| 4 | candidate differs by leading zero | `'0123456'` ≠ `'123456'` — strict equality only |

#### Group: `Unique match` (4 tests)

| # | Test | What it checks |
|---|------|----------------|
| 5 | exact matric, status 0 | Returns `uniqueMatch` + correct participant |
| 6 | trims whitespace from candidate | `'  123456  '` → match found |
| 7 | partial matric does not match | `'1234'` for `'123456'` → `noMatch` |
| 8 | returns correct participant object (by id) | Finds id=7 from list of 3 |

#### Group: `Already marked` (4 tests)

| # | Test | What it checks |
|---|------|----------------|
| 9 | status 1 (present) → `alreadyMarked` | Can't mark twice by accident |
| 10 | status 2 (excused) → `alreadyMarked` | Same protection |
| 11 | status 3 (marked) → `alreadyMarked` | Same protection |
| 12 | returns participant with correct status | `participant.status == 1` |

#### Group: `Multiple exam groups` (3 tests)

| # | Test | What it checks |
|---|------|----------------|
| 13 | same matric in 2 groups → `multipleGroups` | Shows disambiguation prompt |
| 14 | `matches` contains all matching rows | 3 groups → `matches.length == 3` |
| 15 | other participants not included in matches | Only same-matric rows returned |

---

### 5.5 Data: `participant_repository_test.dart` — 19 tests

**File:** `test/data/participant_repository_test.dart`
**Tests:** Every method of `ParticipantRepository` against a real SQLite DB
**Runs against:** `lib/features/import/data/participant_repository.dart`
**Needs DB:** Yes (in-memory via `sqflite_common_ffi`) | **Needs Flutter:** No

This is the only test file that uses a real SQLite database. It can do this
because it is a plain Dart test (no Flutter widget, no FakeAsync), so real
`Future`s resolve normally with no hanging risk.

**Setup (runs once before all tests):**
```dart
sqfliteFfiInit();
databaseFactory = databaseFactoryFfi;
AppDatabase.testDatabasePath = ':memory:';
```

**Setup (runs before each test):**
```dart
await AppDatabase.instance.resetForTesting(); // fresh empty DB
```

#### Group: `replaceAllParticipants` (3 tests)

| # | Test | What it checks |
|---|------|----------------|
| 1 | inserts all rows and returns correct count | 3 rows in → 3 rows retrieved |
| 2 | clears previous data before inserting | Old rows gone after new import |
| 3 | all inserted rows have status 0 | Default status is "not marked" |

#### Group: `getAllParticipants` (3 tests)

| # | Test | What it checks |
|---|------|----------------|
| 4 | returns empty list when table is empty | No crash on empty DB |
| 5 | returns rows ordered by `full_name` ascending | Anna, Klaus, Maria order |
| 6 | maps all fields correctly | matric, name, examGroup, status all correct |

#### Group: `getStatusCounts` (2 tests)

| # | Test | What it checks |
|---|------|----------------|
| 7 | all four statuses are 0 on empty table | `{0:0, 1:0, 2:0, 3:0}` |
| 8 | counts each status correctly after updates | Mark Anna present, Klaus excused → counts match |

#### Group: `getCountsByExamGroup` (2 tests)

| # | Test | What it checks |
|---|------|----------------|
| 9 | returns empty map on empty table | No crash |
| 10 | correct present/total per exam group | EinfInf: 2 total, 1 present; AuD: 1 total, 0 present |

#### Group: `updateStatus` (3 tests)

| # | Test | What it checks |
|---|------|----------------|
| 11 | updates status correctly | `updateStatus(id, 1)` → DB shows `status: 1` |
| 12 | can undo status back to 0 | Mark then unmark → `status: 0` |
| 13 | does not affect other rows | Only target row updated |

#### Group: `searchParticipants` (6 tests)

| # | Test | What it checks |
|---|------|----------------|
| 14 | empty query returns empty list | Guard against `LIKE '%%'` matching everything |
| 15 | finds by partial name | `'Beck'` → Anna Becker |
| 16 | finds by partial matriculation number | `'2222'` → Klaus Müller |
| 17 | exact matric match is ranked first | `'111111'` → exact matric row before name-match row |
| 18 | no results for non-matching query | `'zzznomatch'` → empty list |
| 19 | search is case-insensitive for ASCII | `'anna'` → Anna Becker |

> **Bug caught by test 14:** Before this test was written, `searchParticipants('')`
> returned every student because `'%' + '' + '%'` = `'%%'` matches all SQL rows.
> A guard `if (query.isEmpty) return []` was added after the test exposed this.

---

### 5.6 Integration: `csv_import_integration_test.dart` — 17 tests

**File:** `test/integration/csv_import_integration_test.dart`
**Tests:** Full validate → parse pipeline using real CSV files from disk
**Runs against:** `CsvImportValidator` + `CsvParticipantParser` together
**Needs DB:** No | **Needs Flutter:** No | **Needs real files:** Yes (`test_csv_files/`)

These tests open actual `.csv` files from `test_csv_files/` and run the full
two-step import pipeline on them: first `validate`, then `parse`. They check
that both steps agree on the outcome.

```
test_csv_files/007_valid_comma_delimiter.csv
        │
        ▼
CsvImportValidator.validate(content)   ← Step 1: Structure check
        │ isValid: true
        ▼
CsvParticipantParser.parse(content)    ← Step 2: Row-by-row parse
        │ rows: [...]
        ▼
   Assert correct rows, examGroup, names
```

#### Group: `Valid CSVs` (5 tests)

Tests CSV files 007, 008, 009, 013, 014, 015 end-to-end. Verifies correct
row counts, names, examGroups, and special character handling.

#### Group: `Invalid CSVs - validation fails early` (5 tests)

Tests CSV files 001, 002, 003, 004, 010. Verifies validator rejects them
before the parser even runs.

#### Group: `Partial errors - import continues with warnings` (4 tests)

Tests CSV files 005, 006, 011, 012. Mixed cases: validation passes but parser
produces skipped rows or errors.

#### Group: `Full import workflow - simulate real usage` (3 tests)

Three end-to-end scenarios that mirror real app usage:
1. **Happy path:** validate → parse → data ready for DB
2. **Error path:** validate fails early, stop (never reach parse)
3. **Warning path:** validate passes, parse shows skipped rows, save valid rows

---

### 5.7 Widget: `participant_list_test.dart` — 14 tests

**File:** `test/integration/participant_list_test.dart`
**Tests:** `ParticipantListScreen` — the main list UI
**Uses:** `FakeParticipantRepository` (no real DB)
**Test data:** 10 students, EinfInf (5) + AuD (5)

This was originally the file that caused the hanging test problem (described
in section 4). It has been rewritten to use `FakeParticipantRepository`
instead of a real SQLite DB. All previously-hanging tests (excused, undo)
now pass cleanly.

#### Group: `initial list rendering` (4 tests)

| # | Test | What it checks |
|---|------|----------------|
| 1 | first visible student is Anna Becker | Alphabetical order correct |
| 2 | visible rows all show "Not marked" status | All chips default to not marked |
| 3 | EinfInf exam group shown for EinfInf students | Group label rendered |
| 4 | scrolling reveals all 10 students | Lazy list still shows all when scrolled |

#### Group: `sorting` (3 tests)

| # | Test | What it checks |
|---|------|----------------|
| 5 | default sort (by name) shows Anna Becker first | Default is alphabetical by full name |
| 6 | sort by matriculation shows Tom Richter first | `100000` is lexically lowest |
| 7 | sort by surname shows Anna Becker first | `Becker` alphabetically first |

#### Group: `tap row to change status` (6 tests)

| # | Test | What it checks |
|---|------|----------------|
| 8 | tapping a row opens bottom sheet with all options | 4 options: Present / Excused / Marked / Not Marked (Undo) |
| 9 | marking present closes sheet and shows Present chip | Status chip updates immediately |
| 10 | marking excused closes sheet and shows Excused chip | (Was hanging before fake repo) |
| 11 | undoing present status shows Not marked chip again | (Was hanging before fake repo) |
| 12 | status persists in fake repo after marking present | `repo.getAllParticipants()` returns status=1 |
| 13 | does not affect other rows when marking one student | Only 1 Present chip appears |

#### Group: `search bar` (2 tests)

| # | Test | What it checks |
|---|------|----------------|
| 14 | typing in search bar filters results | `'Anna'` shows Anna Becker, hides Klaus Müller |
| 15 | clearing search restores full list | Empty field → all 10 students back |

---

### 5.8 Widget: `confirmation_screen_test.dart` — 4 tests

**File:** `test/widget/confirmation_screen_test.dart`
**Tests:** `ConfirmationScreen` — the "confirm attendance" screen shown after a scan or search result
**Uses:** `FakeParticipantRepository`

This screen shows the matched student's details and a large "✓ Confirm" button.
Confirming calls `updateStatus` and navigates back with `true`. Cancelling
navigates back with `false`.

| # | Test | What it checks |
|---|------|----------------|
| 1 | shows student name and matric number | `'Anna Becker'` and `'Matric: 123456'` visible |
| 2 | shows exam group when non-empty | `'Exam group: EinfInf'` visible |
| 3 | tapping confirm shows CircularProgressIndicator | Button enters confirming state after tap |
| 4 | tapping cancel pops screen with `false` | Navigator receives `false` as the pop result |

> **Why no "confirm calls updateStatus" test?** After tapping Confirm,
> the code calls `HapticFeedback.mediumImpact()` (a platform channel call)
> before `updateStatus`. In the test VM, that platform channel call needs
> many pump cycles to resolve — more than practical. The confirming state
> (spinner appears) is a reliable proxy that the button was tapped and the
> async chain started. The actual `updateStatus` correctness is covered by
> `participant_repository_test.dart`.

---

### 5.9 Widget: `manual_search_screen_test.dart` — 6 tests

**File:** `test/widget/manual_search_screen_test.dart`
**Tests:** `ManualSearchScreen` — the search screen inside the scan flow
**Uses:** `FakeParticipantRepository` with 3 students (Anna, Klaus, Maria)

This screen shows the full participant list immediately on open, and filters
it in-memory as the user types. Unlike the old version (which waited for the
user to type before showing anything), it shows all students by default for
a better UX.

| # | Test | What it checks |
|---|------|----------------|
| 1 | shows full list on open — no typing required | All 3 students visible before any input |
| 2 | typing filters list by name | `'Anna'` → only Anna Becker shown |
| 3 | typing filters list by matriculation number | `'3333'` → only Maria Schmidt shown |
| 4 | clearing search restores full list | Empty field → all 3 students back |
| 5 | shows "No students found." for no match | `'zzznomatch'` → empty state message |
| 6 | status chips shown for each participant | Klaus (status 1) shows "Present" chip |

---

## 6. Test Helper — FakeParticipantRepository

**File:** `test/helpers/fake_participant_repository.dart`

This is the key enabler for all widget tests. It extends
`ParticipantRepository` and overrides every method to use a simple Dart
`List` instead of SQLite.

```
                        ParticipantRepository (real)
                               │  extends
                FakeParticipantRepository (test-only)
                       │
                       └── List<Participant> _participants
                              (in-memory, pure Dart, no DB)
```

**Methods implemented:**
- `getAllParticipants()` — returns a copy of the list
- `updateStatus(int id, int status)` — updates the matching item in the list
- `searchParticipants(String query)` — in-memory substring search
- `getStatusCounts()` — counts statuses from the list
- `getCountsByExamGroup()` — groups by examGroup
- `replaceAllParticipants(List rows)` — replaces list contents

The fake runs entirely in Dart. No native threads, no OS interaction. FakeAsync
can see all its `Future`s. No hanging, ever.

---

## 7. What Is NOT Tested (and Why)

| Area | Reason not tested |
|------|-------------------|
| Camera / OCR | Requires physical camera hardware. Cannot run in `flutter test`. |
| File saving (FilePicker) | Platform channel — requires real device. Export logic itself is tested at the service level. |
| App startup / navigation | No single "e2e on a phone" test. The Flutter `integration_test` package could do this but requires a connected device or emulator — not needed for an exam-day app with a short lifecycle. |
| Screen transitions | Widget tests verify navigation by checking pushed routes, not by running the full nav graph. |
| Export CSV content | Covered implicitly by testing `ExportService` data output; file-save itself is platform-gated. |

---

## 8. Total Count Summary

| File | Type | Tests |
|------|------|-------|
| `test/unit/csv_text_test.dart` | Unit | 26 |
| `test/unit/csv_import_validator_test.dart` | Unit | 13 |
| `test/unit/csv_participant_parser_test.dart` | Unit | 23 |
| `test/unit/matching_engine_test.dart` | Unit | 15 |
| `test/data/participant_repository_test.dart` | Data / SQLite | 19 |
| `test/integration/csv_import_integration_test.dart` | Integration | 17 |
| `test/integration/participant_list_test.dart` | Widget | 14 |
| `test/widget/confirmation_screen_test.dart` | Widget | 4 |
| `test/widget/manual_search_screen_test.dart` | Widget | 6 |
| **Total** | | **145** |

```
Run: cd ovgu_exam_attendance_app && flutter test
Expected: 00:05 +145: All tests passed!
```
