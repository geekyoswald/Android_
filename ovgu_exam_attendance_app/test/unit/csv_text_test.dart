import 'package:flutter_test/flutter_test.dart';
import 'package:ovgu_exam_attendance_app/features/import/services/csv_text.dart';

void main() {
  group('detectDelimiter', () {
    test('detects comma delimiter', () {
      final delimiter = detectDelimiter('name,age,city');
      expect(delimiter, ',');
    });

    test('detects semicolon delimiter', () {
      final delimiter = detectDelimiter('name;age;city');
      expect(delimiter, ';');
    });

    test('detects tab delimiter', () {
      final delimiter = detectDelimiter('name\tage\tcity');
      expect(delimiter, '\t');
    });

    test('falls back to tab for single column', () {
      final delimiter = detectDelimiter('name');
      expect(delimiter, '\t');
    });

    test('falls back to tab for unsupported pipe delimiter', () {
      final delimiter = detectDelimiter('name|age|city');
      expect(delimiter, '\t');
    });

    test('prefers comma over semicolon when both present', () {
      final delimiter = detectDelimiter('name,age;city');
      expect(delimiter, ',');
    });
  });

  group('parseCsvLine', () {
    test('splits simple comma-delimited line', () {
      final cells = parseCsvLine('John,Doe,25');
      expect(cells, ['John', 'Doe', '25']);
    });

    test('splits semicolon-delimited line', () {
      final cells = parseCsvLine('John;Doe;25', ';');
      expect(cells, ['John', 'Doe', '25']);
    });

    test('splits tab-delimited line', () {
      final cells = parseCsvLine('John\tDoe\t25', '\t');
      expect(cells, ['John', 'Doe', '25']);
    });

    test('handles quoted field with comma inside', () {
      final cells = parseCsvLine('"Doe, John",30');
      expect(cells, ['Doe, John', '30']);
    });

    test('handles empty field between delimiters', () {
      final cells = parseCsvLine('John,,25');
      expect(cells, ['John', '', '25']);
    });

    test('trims whitespace from cells', () {
      final cells = parseCsvLine(' John , Doe , 25 ');
      expect(cells, ['John', 'Doe', '25']);
    });

    test('handles multiple empty fields', () {
      final cells = parseCsvLine('John,,,25');
      expect(cells, ['John', '', '', '25']);
    });

    test('handles quoted empty field', () {
      final cells = parseCsvLine('John,"",25');
      expect(cells, ['John', '', '25']);
    });

    test('handles field with only spaces', () {
      final cells = parseCsvLine('John,   ,25');
      expect(cells, ['John', '', '25']);
    });

    test('handles quoted field with spaces inside', () {
      final cells = parseCsvLine('" name ",30');
      expect(cells, ['name', '30']);
    });

    test('handles special characters in fields', () {
      final cells = parseCsvLine('Müller,José,François');
      expect(cells, ['Müller', 'José', 'François']);
    });

    test('handles quoted field with apostrophe', () {
      final cells = parseCsvLine('"O\'Brien",Patrick');
      expect(cells, ["O'Brien", 'Patrick']);
    });

    test('default delimiter is comma', () {
      final cells = parseCsvLine('a,b,c');
      expect(cells.length, 3);
    });
  });

  group('normalizeCsvHeader', () {
    test('lowercases header text', () {
      final normalized = normalizeCsvHeader('MATRICULATION_NUMBER');
      expect(normalized, 'matriculation_number');
    });

    test('trims leading and trailing whitespace', () {
      final normalized = normalizeCsvHeader('  full_name  ');
      expect(normalized, 'full_name');
    });

    test('replaces spaces with underscores', () {
      final normalized = normalizeCsvHeader('Matriculation Number');
      expect(normalized, 'matriculation_number');
    });

    test('handles mixed case and spaces', () {
      final normalized = normalizeCsvHeader('  Full Name  ');
      expect(normalized, 'full_name');
    });

    test('preserves underscores', () {
      final normalized = normalizeCsvHeader('matriculation_number');
      expect(normalized, 'matriculation_number');
    });

    test('handles already normalized header', () {
      final normalized = normalizeCsvHeader('exam_group');
      expect(normalized, 'exam_group');
    });

    test('converts multiple spaces to single underscore', () {
      final normalized = normalizeCsvHeader('Full  Name  Here');
      expect(normalized, 'full_name_here');
    });
  });
}
