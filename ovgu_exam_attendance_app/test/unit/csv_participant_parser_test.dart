import 'package:flutter_test/flutter_test.dart';
import 'package:ovgu_exam_attendance_app/features/import/services/csv_participant_parser.dart';

void main() {
  group('CsvParticipantParser.parse', () {
    group('Hard errors - import is blocked', () {
      test('001 - empty file returns error', () {
        const csv = '';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, false);
        expect(result.rows, isEmpty);
        expect(result.errors, isNotEmpty);
      });

      test('002 - missing matriculation_number column returns error', () {
        const csv = '''full_name,email
John Doe,john@example.com''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, false);
        expect(result.rows, isEmpty);
        expect(result.errors.length, 1);
        expect(result.errors[0].message, contains('Required columns'));
      });

      test('003 - missing full_name column returns error', () {
        const csv = '''matriculation_number,email
123456,john@example.com''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, false);
        expect(result.errors, isNotEmpty);
      });

      test('004 - headers only returns error', () {
        const csv = 'matriculation_number,full_name,exam_group';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, false);
        expect(result.rows, isEmpty);
      });

      test('006 - some rows with empty full_name blocks import', () {
        const csv = '''matriculation_number,full_name
123456,John Doe
789012,
345678,Alice Wonder''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, false);
        expect(result.errors, isNotEmpty);
        expect(result.errors[0].lineNumber, 3);
        expect(result.errors[0].message, contains('name'));
      });

      test('010 - unsupported pipe delimiter causes column error', () {
        const csv = '''matriculation_number|full_name|exam_group
4001|Noah Anderson|Group A''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, false);
        expect(result.errors, isNotEmpty);
      });

      test('011 - multiple errors block import', () {
        const csv = '''matriculation_number,full_name
5001,John Doe
,Jane Smith
5003,
5004,Bob Johnson
,
5006,Alice Cooper''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, false);
        expect(result.errors.isNotEmpty, true);
        expect(result.skippedRows.isNotEmpty, true);
      });

      test('012 - all rows skipped returns error', () {
        const csv = '''matriculation_number,full_name
,John Doe
,Jane Smith
,Bob Johnson
,Alice Cooper''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, false);
        expect(result.rows, isEmpty);
        expect(result.errors, isNotEmpty);
        expect(result.skippedRows.length, 4);
      });
    });

    group('Soft errors - rows skipped but import continues', () {
      test('005 - rows with empty matriculation are skipped', () {
        const csv = '''matriculation_number,full_name
123456,John Doe
,Jane Smith
789012,Bob Johnson''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, true);
        expect(result.rows.length, 2);
        expect(result.rows[0].matriculationNumber, '123456');
        expect(result.rows[1].matriculationNumber, '789012');
        expect(result.skippedRows.length, 1);
        expect(result.errors, isEmpty);
      });

      test('skipped rows include line number', () {
        const csv = '''matriculation_number,full_name
123456,John Doe
,Jane Smith''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.skippedRows[0].lineNumber, 3);
        expect(result.skippedRows[0].message, contains('matriculation'));
      });
    });

    group('Success cases - import accepted', () {
      test('007 - valid comma CSV parsed correctly', () {
        const csv = '''matriculation_number,full_name,exam_group
1001,John Doe,Group A
1002,Jane Smith,Group B
1003,Bob Johnson,Group A
1004,Alice Cooper,Group C''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, true);
        expect(result.rows.length, 4);
        expect(result.errors, isEmpty);
        expect(result.skippedRows, isEmpty);
        expect(result.rows[0].matriculationNumber, '1001');
        expect(result.rows[0].fullName, 'John Doe');
        expect(result.rows[0].examGroup, 'Group A');
      });

      test('008 - valid semicolon CSV parsed correctly', () {
        const csv = '''matriculation_number;full_name;exam_group
2001;Michael Brown;Group A
2002;Sarah Davis;Group B
2003;Chris Wilson;Group C''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, true);
        expect(result.rows.length, 3);
        expect(result.rows[1].fullName, 'Sarah Davis');
      });

      test('009 - valid tab CSV parsed correctly', () {
        const csv = '''matriculation_number\tfull_name\texam_group
3001\tEmma Thompson\tGroup A
3002\tOliver Martinez\tGroup B
3003\tSophia Garcia\tGroup C''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, true);
        expect(result.rows.length, 3);
      });

      test('013 - exam_group is parsed correctly', () {
        const csv = '''matriculation_number,full_name,exam_group
6001,Elena White,Midterm
6002,Daniel Black,Final
6003,Victoria Green,Midterm''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, true);
        expect(result.rows[0].examGroup, 'Midterm');
        expect(result.rows[1].examGroup, 'Final');
      });

      test('014 - spaces in headers are normalized', () {
        const csv = ''' matriculation_number , full_name , exam_group
7001,Frank Howard,Group A
7002,George Lewis,Group B
7003,Hannah Walker,Group C''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, true);
        expect(result.rows.length, 3);
      });

      test('015 - special characters in names parsed correctly', () {
        const csv = '''matriculation_number,full_name,exam_group
8001,"Müller, Hans",Group A
8002,François Dubois,Group B
8003,José María García,Group C
8004,"O'Brien, Patrick",Group A''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, true);
        expect(result.rows.length, 4);
        expect(result.rows[0].fullName, 'Müller, Hans');
        expect(result.rows[1].fullName, 'François Dubois');
        expect(result.rows[2].fullName, 'José María García');
        expect(result.rows[3].fullName, "O'Brien, Patrick");
      });
    });

    group('Edge cases', () {
      test('exam_group is optional and defaults to empty string', () {
        const csv = '''matriculation_number,full_name
1001,John Doe
1002,Jane Smith''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, true);
        expect(result.rows[0].examGroup, '');
        expect(result.rows[1].examGroup, '');
      });

      test('whitespace in matriculation is trimmed', () {
        const csv = '''matriculation_number,full_name
  1001  ,John Doe''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, true);
        expect(result.rows[0].matriculationNumber, '1001');
      });

      test('whitespace in full_name is trimmed', () {
        const csv = '''matriculation_number,full_name
1001,  John Doe  ''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, true);
        expect(result.rows[0].fullName, 'John Doe');
      });

      test('missing exam_group column is handled gracefully', () {
        const csv = '''matriculation_number,full_name
1001,John Doe
1002,Jane Smith''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.rows[0].examGroup, '');
      });

      test('isUsable = rows not empty AND no errors', () {
        const csv = '''matriculation_number,full_name
1001,John Doe
,Jane Smith''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, true);
        expect(result.rows.isNotEmpty, true);
        expect(result.errors.isEmpty, true);
      });

      test('duplicate matriculation in same exam_group blocks import', () {
        const csv = '''matriculation_number,full_name,exam_group
123456,John Doe,EinfInf
789012,Jane Smith,AuD
123456,John Duplicate,EinfInf''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, false);
        expect(result.errors, isNotEmpty);
        expect(result.errors[0].message, contains('Duplicate matriculation 123456'));
        expect(result.errors[0].message, contains('EinfInf'));
        expect(result.errors[0].message, contains('lines: 2, 4'));
      });

      test('duplicate matriculation without exam_group blocks import', () {
        const csv = '''matriculation_number,full_name
123456,John Doe
789012,Jane Smith
123456,John Duplicate''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, false);
        expect(result.errors, isNotEmpty);
        expect(result.errors[0].message, contains('Duplicate matriculation 123456'));
        expect(result.errors[0].message, contains('lines: 2, 4'));
      });

      test('multiple duplicates in same exam_group shows all instances', () {
        const csv = '''matriculation_number,full_name,exam_group
123456,John Doe,EinfInf
789012,Jane Smith,AuD
123456,John Dup1,EinfInf
123456,John Dup2,EinfInf''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, false);
        expect(result.errors[0].message, contains('lines: 2, 4, 5'));
      });

      test('same matriculation different exam_groups is allowed', () {
        const csv = '''matriculation_number,full_name,exam_group
123456,John Doe,EinfInf
789012,Jane Smith,AuD
123456,John Again,AuD''';
        final result = CsvParticipantParser.parse(csv);

        expect(result.isUsable, true);
        expect(result.rows.length, 3);
        expect(result.errors, isEmpty);
      });
    });
  });
}
