import 'package:flutter_test/flutter_test.dart';
import 'package:ovgu_exam_attendance_app/features/import/services/csv_import_validator.dart';

void main() {
  group('CsvImportValidator.validate', () {
    group('Invalid CSVs - should be rejected', () {
      test('001 - empty file is invalid', () {
        const csv = '';
        final result = CsvImportValidator.validate(csv);

        expect(result.isValid, false);
        expect(result.message, contains('empty'));
      });

      test('002 - missing matriculation_number column is invalid', () {
        const csv = '''full_name,email
John Doe,john@example.com
Jane Smith,jane@example.com''';
        final result = CsvImportValidator.validate(csv);

        expect(result.isValid, false);
        expect(result.message, contains('Required columns'));
        expect(result.message, contains('matriculation_number'));
      });

      test('003 - missing full_name column is invalid', () {
        const csv = '''matriculation_number,email
123456,john@example.com
789012,jane@example.com''';
        final result = CsvImportValidator.validate(csv);

        expect(result.isValid, false);
        expect(result.message, contains('Required columns'));
      });

      test('004 - headers only with no data rows is invalid', () {
        const csv = 'matriculation_number,full_name,exam_group';
        final result = CsvImportValidator.validate(csv);

        expect(result.isValid, false);
        expect(result.message, contains('headers but no student rows'));
      });

      test('010 - unsupported pipe delimiter falls back and is invalid', () {
        const csv = '''matriculation_number|full_name|exam_group
4001|Noah Anderson|Group A''';
        final result = CsvImportValidator.validate(csv);

        expect(result.isValid, false);
        expect(result.message, contains('Required columns'));
      });
    });

    group('Valid CSVs - should be accepted', () {
      test('007 - valid comma-delimited CSV is valid', () {
        const csv = '''matriculation_number,full_name,exam_group
1001,John Doe,Group A
1002,Jane Smith,Group B
1003,Bob Johnson,Group A
1004,Alice Cooper,Group C''';
        final result = CsvImportValidator.validate(csv);

        expect(result.isValid, true);
        expect(result.message, contains('successful'));
        expect(result.studentCount, 4);
      });

      test('008 - valid semicolon-delimited CSV is valid', () {
        const csv = '''matriculation_number;full_name;exam_group
2001;Michael Brown;Group A
2002;Sarah Davis;Group B
2003;Chris Wilson;Group C''';
        final result = CsvImportValidator.validate(csv);

        expect(result.isValid, true);
        expect(result.studentCount, 3);
      });

      test('009 - valid tab-delimited CSV is valid', () {
        const csv = '''matriculation_number\tfull_name\texam_group
3001\tEmma Thompson\tGroup A
3002\tOliver Martinez\tGroup B''';
        final result = CsvImportValidator.validate(csv);

        expect(result.isValid, true);
        expect(result.studentCount, 2);
      });

      test('014 - spaces in column headers are normalized', () {
        const csv = ''' matriculation_number , full_name , exam_group
7001,Frank Howard,Group A
7002,George Lewis,Group B''';
        final result = CsvImportValidator.validate(csv);

        expect(result.isValid, true);
        expect(result.studentCount, 2);
      });

      test('015 - special characters in names are accepted', () {
        const csv = '''matriculation_number,full_name,exam_group
8001,"Müller, Hans",Group A
8002,François Dubois,Group B
8003,José María García,Group C''';
        final result = CsvImportValidator.validate(csv);

        expect(result.isValid, true);
        expect(result.studentCount, 3);
      });

      test('013 - CSV with exam_group column is valid', () {
        const csv = '''matriculation_number,full_name,exam_group
6001,Elena White,Midterm
6002,Daniel Black,Final''';
        final result = CsvImportValidator.validate(csv);

        expect(result.isValid, true);
      });
    });

    group('Edge cases', () {
      test('only whitespace lines are ignored', () {
        const csv = '''matriculation_number,full_name

1001,John Doe


1002,Jane Smith


''';
        final result = CsvImportValidator.validate(csv);

        expect(result.isValid, true);
        expect(result.studentCount, 2);
      });

      test('case-insensitive header matching', () {
        const csv = '''MATRICULATION_NUMBER,FULL_NAME
1001,John Doe''';
        final result = CsvImportValidator.validate(csv);

        expect(result.isValid, true);
      });
    });
  });
}
