import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovgu_exam_attendance_app/features/import/services/csv_import_validator.dart';
import 'package:ovgu_exam_attendance_app/features/import/services/csv_participant_parser.dart';

void main() {
  group('CSV Import Integration Tests', () {
    /// Helper function to read test CSV files from disk
    /// CSV files are located at ../../test_csv_files/ relative to this test file
    String readTestCsv(String filename) {
      final file = File('../test_csv_files/$filename');
      if (!file.existsSync()) {
        throw FileSystemException('Test CSV file not found', file.path);
      }
      return file.readAsStringSync();
    }

    group('Valid CSVs - validation and parsing succeed', () {
      test('007 - valid comma-delimited CSV validates and parses end-to-end', () {
        final csvContent = readTestCsv('007_valid_comma_delimiter.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, true);
        expect(validation.studentCount, 4);

        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, true);
        expect(result.rows.length, 4);
        expect(result.rows[0].matriculationNumber, '1001');
        expect(result.rows[0].fullName, 'John Doe');
        expect(result.rows[0].examGroup, 'Group A');
      });

      test('008 - valid semicolon-delimited CSV validates and parses correctly', () {
        final csvContent = readTestCsv('008_valid_semicolon_delimiter.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, true);

        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, true);
        expect(result.rows.length, 3);
      });

      test('009 - valid tab-delimited CSV validates and parses correctly', () {
        final csvContent = readTestCsv('009_valid_tab_delimiter.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, true);

        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, true);
        expect(result.rows.length, 4);
      });

      test('013 - CSV with exam_group validates and parses correctly', () {
        final csvContent = readTestCsv('013_with_exam_group.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, true);

        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, true);
        expect(result.rows.length, 5);
        expect(result.rows[0].examGroup, 'Midterm');
      });

      test('014 - CSV with spaces in headers validates and parses correctly', () {
        final csvContent = readTestCsv('014_spaces_in_headers.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, true);

        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, true);
        expect(result.rows.length, 3);
      });

      test('015 - CSV with special characters validates and parses correctly', () {
        final csvContent = readTestCsv('015_special_characters.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, true);

        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, true);
        expect(result.rows.length, 4);
        expect(result.rows[0].fullName, 'Müller, Hans');
        expect(result.rows[1].fullName, 'François Dubois');
      });
    });

    group('Invalid CSVs - validation fails early', () {
      test('001 - empty file is rejected by validator', () {
        final csvContent = readTestCsv('001_empty_file.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, false);
        expect(validation.message, contains('empty'));
      });

      test('002 - missing matriculation_number column is rejected', () {
        final csvContent = readTestCsv('002_missing_matriculation_column.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, false);
        expect(validation.message, contains('Required columns'));
      });

      test('003 - missing full_name column is rejected', () {
        final csvContent = readTestCsv('003_missing_full_name_column.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, false);
      });

      test('004 - headers only is rejected', () {
        final csvContent = readTestCsv('004_headers_only_no_data.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, false);
      });

      test('010 - unsupported pipe delimiter is rejected', () {
        final csvContent = readTestCsv('010_unsupported_pipe_delimiter.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, false);
      });
    });

    group('Partial errors - import continues with warnings', () {
      test('005 - some rows with empty matriculation are skipped', () {
        final csvContent = readTestCsv('005_empty_matriculation_number.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, true); // Validation passes

        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, true); // Import succeeds with warnings
        expect(result.rows.length, 2); // 2 valid rows
        expect(result.skippedRows.length, 1); // 1 skipped
        expect(result.errors.isEmpty, true); // No hard errors
      });

      test('006 - some rows with empty full_name block import', () {
        final csvContent = readTestCsv('006_empty_full_name.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, true); // Validation passes

        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, false); // Import blocked
        expect(result.errors.isNotEmpty, true); // Has error
      });

      test('011 - multiple errors block import', () {
        final csvContent = readTestCsv('011_multiple_errors.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, true);

        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, false); // Blocked due to errors
        expect(result.errors.isNotEmpty, true);
        expect(result.skippedRows.isNotEmpty, true);
        expect(result.rows.isNotEmpty, true); // But some rows parsed
      });

      test('012 - all rows skipped blocks import', () {
        final csvContent = readTestCsv('012_all_skipped_rows.csv');

        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, true); // Validation passes

        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, false); // No valid data to import
        expect(result.rows.isEmpty, true);
        expect(result.skippedRows.length, 4); // All 4 rows skipped
      });
    });

    group('Full import workflow - simulate real usage', () {
      test('valid file flow: validate -> parse -> ready for database', () {
        final csvContent = readTestCsv('007_valid_comma_delimiter.csv');

        // Step 1: Validate
        final validation = CsvImportValidator.validate(csvContent);
        if (!validation.isValid) {
          fail('Validation should pass: ${validation.message}');
        }

        // Step 2: Parse
        final result = CsvParticipantParser.parse(csvContent);
        if (!result.isUsable) {
          final errorMessages = result.errors.map((e) => e.message).join(', ');
          fail('Parse should succeed. Errors: $errorMessages');
        }

        // Step 3: Ready to save to database
        expect(result.rows.isNotEmpty, true);
        expect(result.rows.length, 4);

        // Verify structure
        final firstRow = result.rows[0];
        expect(firstRow.matriculationNumber.isNotEmpty, true);
        expect(firstRow.fullName.isNotEmpty, true);
      });

      test('invalid file flow: validate fails, stops early', () {
        final csvContent = readTestCsv('002_missing_matriculation_column.csv');

        // Step 1: Validate
        final validation = CsvImportValidator.validate(csvContent);
        if (validation.isValid) {
          fail('Validation should fail for missing columns');
        }

        // Never proceeds to parsing in real UI
        // UI shows validation.message to user
        expect(validation.message, contains('Required columns'));
      });

      test('partial error flow: validate passes, parse shows warnings', () {
        final csvContent = readTestCsv('005_empty_matriculation_number.csv');

        // Step 1: Validate
        final validation = CsvImportValidator.validate(csvContent);
        expect(validation.isValid, true);

        // Step 2: Parse
        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, true); // Can proceed

        // Step 3: UI shows warnings
        if (result.skippedRows.isNotEmpty) {
          final warnings = result.skippedRows.map((s) => 'Line ${s.lineNumber}: ${s.message}').toList();
          expect(warnings.isNotEmpty, true);
        }

        // Still saves valid rows to database
        expect(result.rows.isNotEmpty, true);
      });
    });

    group('Delimiter detection from real files', () {
      test('007 - correctly auto-detects comma delimiter', () {
        final csvContent = readTestCsv('007_valid_comma_delimiter.csv');
        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, true);
      });

      test('008 - correctly auto-detects semicolon delimiter', () {
        final csvContent = readTestCsv('008_valid_semicolon_delimiter.csv');
        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, true);
      });

      test('009 - correctly auto-detects tab delimiter', () {
        final csvContent = readTestCsv('009_valid_tab_delimiter.csv');
        final result = CsvParticipantParser.parse(csvContent);
        expect(result.isUsable, true);
      });
    });
  });
}
