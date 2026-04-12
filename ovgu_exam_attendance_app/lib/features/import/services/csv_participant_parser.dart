import 'dart:convert';

import 'csv_text.dart';
import '../domain/participant_import_row.dart';

class CsvParticipantParser {
  static List<ParticipantImportRow> parse(String csvContent) {
    final lines = const LineSplitter()
        .convert(csvContent)
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      throw const FormatException('CSV file is empty.');
    }

    final headerCells = parseCsvLine(lines.first);
    final headers = headerCells.map(normalizeCsvHeader).toList();
    final matriculationIndex = headers.indexOf('matriculation_number');
    final fullNameIndex = headers.indexOf('full_name');

    if (matriculationIndex < 0 || fullNameIndex < 0) {
      throw const FormatException(
        'Required columns missing: matriculation_number and full_name.',
      );
    }

    final rows = <ParticipantImportRow>[];
    for (var i = 1; i < lines.length; i++) {
      final columns = parseCsvLine(lines[i]);
      final matriculation = _cellAt(columns, matriculationIndex);
      final fullName = _cellAt(columns, fullNameIndex);

      if (matriculation.isEmpty || fullName.isEmpty) {
        throw FormatException(
          'Row ${i + 1}: matriculation number and full name must be non-empty.',
        );
      }

      rows.add(
        ParticipantImportRow(
          matriculationNumber: matriculation,
          fullName: fullName,
        ),
      );
    }

    if (rows.isEmpty) {
      throw const FormatException('CSV has headers but no student rows.');
    }

    return rows;
  }

  static String _cellAt(List<String> columns, int index) {
    if (index >= columns.length) {
      return '';
    }
    return columns[index].trim();
  }
}
