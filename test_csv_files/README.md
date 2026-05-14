# CSV Test Files for Participant Import

This directory contains test CSV files for testing the CSV parser and validator. Each file is designed to test a specific error case or scenario.

## Test Files Overview

### Error Cases

| File | Purpose | Expected Behavior |
|------|---------|-------------------|
| **001_empty_file.csv** | Empty CSV file | Should report "CSV file is empty." |
| **002_missing_matriculation_column.csv** | Missing matriculation_number column | Should report missing required columns |
| **003_missing_full_name_column.csv** | Missing full_name column | Should report missing required columns |
| **004_headers_only_no_data.csv** | Headers present but no data rows | Should report "CSV has headers but no student rows." |
| **005_empty_matriculation_number.csv** | Row with empty matriculation number | Should skip the row with empty matriculation |
| **006_empty_full_name.csv** | Row with empty full_name | Should report error for empty full_name |
| **011_multiple_errors.csv** | Multiple error types in one file | Should report both skipped rows and errors |
| **012_all_skipped_rows.csv** | All rows have empty matriculation | Should skip all rows |

### Success Cases

| File | Purpose | Expected Behavior |
|------|---------|-------------------|
| **007_valid_comma_delimiter.csv** | Valid CSV with comma delimiter | Should parse successfully with 4 students |
| **008_valid_semicolon_delimiter.csv** | Valid CSV with semicolon delimiter | Should auto-detect delimiter and parse 3 students |
| **009_valid_tab_delimiter.csv** | Valid CSV with tab delimiter | Should auto-detect delimiter and parse 4 students |
| **010_unsupported_pipe_delimiter.csv** | CSV with unsupported pipe delimiter | Should fail validation (pipe not supported, falls back to tab) |
| **013_with_exam_group.csv** | Valid CSV including exam_group column | Should parse 5 students with exam groups |
| **015_special_characters.csv** | Valid CSV with special characters | Should handle non-ASCII names correctly |

### Edge Cases

| File | Purpose | Expected Behavior |
|------|---------|-------------------|
| **014_spaces_in_headers.csv** | Headers with extra spaces (quoted) | Should normalize headers and parse correctly |

## How to Use

1. Place these files in your app's file picker/import dialog
2. The parser should handle each file according to the expected behavior
3. Check the logs and UI messages to verify correct error/success handling
4. Test both the validator (`CsvImportValidator`) and the parser (`CsvParticipantParser`)

## Error Messages Tested

- ✓ CSV file is empty
- ✓ Required columns missing
- ✓ CSV has headers but no valid student rows
- ✓ Missing matriculation number (skipped rows)
- ✓ Full name must not be empty (error rows)
- ✓ Auto-detection of different delimiters (comma, semicolon, tab, pipe)
