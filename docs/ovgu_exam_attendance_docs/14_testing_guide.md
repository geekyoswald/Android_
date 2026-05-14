# Testing Guide

## Test Organization

```
ovgu_exam_attendance_app/test/
├── unit/
│   ├── csv_text_test.dart
│   ├── csv_import_validator_test.dart
│   └── csv_participant_parser_test.dart
├── integration/
│   └── csv_import_integration_test.dart
└── widget_test.dart

test_csv_files/          (at project root)
├── 001_empty_file.csv
├── 002_missing_matriculation_column.csv
├── ... (15 CSV test files)
└── README.md
```

## Running Tests

```bash
# Run all tests
flutter test

# Run unit tests only
flutter test test/unit/

# Run integration tests only
flutter test test/integration/

# Run specific test file
flutter test test/unit/csv_text_test.dart

# Run tests matching a pattern
flutter test test/unit/ -k "detectDelimiter"

# Verbose output
flutter test -v
```

## Test Categories

### Unit Tests
- `csv_text_test.dart` — Delimiter detection, CSV line parsing, header normalization
- `csv_import_validator_test.dart` — CSV validation (headers, empty files, required columns)
- `csv_participant_parser_test.dart` — CSV parsing (valid rows, errors, skipped rows)

### Integration Tests
- `csv_import_integration_test.dart` — Full workflows (validate → parse) with real CSV files from disk

### Test CSV Files
Located in `test_csv_files/` at project root:
- **Invalid:** `001_empty_file.csv`, `002_missing_matriculation_column.csv`, `003_missing_full_name_column.csv`, `004_headers_only_no_data.csv`, `010_unsupported_pipe_delimiter.csv`
- **Valid:** `007_valid_comma_delimiter.csv`, `008_valid_semicolon_delimiter.csv`, `009_valid_tab_delimiter.csv`, `013_with_exam_group.csv`, `014_spaces_in_headers.csv`, `015_special_characters.csv`
- **Partial Errors:** `005_empty_matriculation_number.csv`, `006_empty_full_name.csv`, `011_multiple_errors.csv`, `012_all_skipped_rows.csv`
- **Duplicate Detection:** `016_duplicate_matriculation_same_exam.csv` (same matric + same exam_group = REJECT), `017_duplicate_matriculation_no_exam_group.csv` (same matric twice, no exam_group = REJECT), `018_same_matriculation_different_exam_groups.csv` (same matric in different exams = ALLOW)

## Import Acceptance Rules

### ❌ REJECT Import (Block)

**Hard Errors — Validation Fails:**
- Empty CSV file
- Missing `matriculation_number` column
- Missing `full_name` column
- Headers only (no data rows)
- Unsupported delimiter (pipe `|`)

**Hard Errors — Parsing Fails (even if validation passes):**
- Empty `full_name` in any data row
- All rows skipped (no valid data remains)
- **Duplicate `(matriculation_number, exam_group)` pair** — same student registered twice for same exam
  - Example: "Duplicate matriculation 123456 in exam_group 'EinfInf' (lines: 2, 4)"
  - If exam_group column absent: "Duplicate matriculation 123456 (lines: 2, 4)"
  - Allows: Same matriculation in **different** exam_groups (legitimate multi-exam registration)

**Test cases that REJECT:** `001`, `002`, `003`, `004`, `006`, `010`, `011`, `012`, `016`, `017`

### ✅ ALLOW Import (Proceed)

**Valid CSVs** — All rows valid, no errors:
- `007_valid_comma_delimiter.csv`
- `008_valid_semicolon_delimiter.csv`
- `009_valid_tab_delimiter.csv`
- `013_with_exam_group.csv`
- `014_spaces_in_headers.csv`
- `015_special_characters.csv`
- `018_same_matriculation_different_exam_groups.csv` → Same student in multiple exams (allowed)

**Soft Errors** — Some rows skipped but valid rows exist:
- Empty `matriculation_number` → Skip that row, continue with others
- `005_empty_matriculation_number.csv` → ALLOWS import (3 valid rows remain)

**Decision:** If validator passes AND parser has at least one valid row AND no hard errors → IMPORT ALLOWED

**Note on duplicate matriculation:**
- ❌ Same `(matriculation_number, exam_group)` → HARD ERROR (blocks import)
- ✅ Same matriculation, different exam_groups → ALLOWED (legitimate multi-exam registration)

## What Tests Cover

| Component | Tests |
|---|---|
| Delimiter detection (`,`, `;`, `\t`) | ✅ |
| Quoted fields with special characters | ✅ |
| Header normalization (spaces, case) | ✅ |
| Required columns validation | ✅ |
| Hard errors (block import) | ✅ |
| Soft errors (skip rows but continue) | ✅ |
| exam_group optional field | ✅ |
| UTF-8 special characters | ✅ |
| Full end-to-end workflows | ✅ |

## Debugging Tests

If a test fails:
1. Check the test output for the specific assertion that failed
2. Run the specific test file with `-v` flag for verbose output
3. For integration tests, verify CSV files exist in `test_csv_files/`
4. Check relative file paths (tests use `../test_csv_files/filename.csv`)

## Adding New Tests

1. **For new parsing behavior:** Add test to appropriate unit test file
2. **For new CSV scenario:** Add CSV file to `test_csv_files/` + integration test
3. **Keep test names descriptive:** e.g., `test('007 - valid comma CSV validates and parses correctly')`
