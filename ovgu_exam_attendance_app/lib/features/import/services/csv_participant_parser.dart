import 'dart:convert';

import 'csv_text.dart';
import '../domain/participant_import_row.dart';
import '../domain/import_result.dart';

class CsvParticipantParser {
  static ImportResult parse(String csvContent) {
    final lines = const LineSplitter()
        .convert(csvContent)
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const ImportResult(
        rows: [],
        errors: [ImportIssue(lineNumber: 0, message: 'CSV file is empty.')],
        skippedRows: [],
      );
    }

    final delimiter = detectDelimiter(lines.first);
    final headerCells = parseCsvLine(lines.first, delimiter);
    final headers = headerCells.map(normalizeCsvHeader).toList();

    final matriculationIndex = headers.indexOf('matriculation_number');
    final fullNameIndex = headers.indexOf('full_name');
    final examGroupIndex = headers.indexOf('exam_group');

    if (matriculationIndex < 0 || fullNameIndex < 0) {
      return const ImportResult(
        rows: [],
        errors: [
          ImportIssue(
            lineNumber: 1,
            message:
                'Required columns missing: matriculation_number and full_name.',
          ),
        ],
        skippedRows: [],
      );
    }

    final rows = <ParticipantImportRow>[];
    final errors = <ImportIssue>[];
    final skippedRows = <ImportIssue>[];

    for (var i = 1; i < lines.length; i++) {
      final lineNumber = i + 1;
      final columns = parseCsvLine(lines[i], delimiter);
      final matriculation = _cellAt(columns, matriculationIndex);
      final fullName = _cellAt(columns, fullNameIndex);
      final examGroup =
          examGroupIndex >= 0 ? _cellAt(columns, examGroupIndex) : '';

      if (matriculation.isEmpty) {
        skippedRows.add(ImportIssue(
          lineNumber: lineNumber,
          message: 'Missing matriculation number (entry skipped).',
        ));
        continue;
      }

      if (fullName.isEmpty) {
        errors.add(ImportIssue(
          lineNumber: lineNumber,
          message: 'Full name must not be empty.',
        ));
        continue;
      }

      rows.add(ParticipantImportRow(
        matriculationNumber: matriculation,
        fullName: fullName,
        examGroup: examGroup,
      ));
    }

    if (rows.isEmpty && errors.isEmpty) {
      return ImportResult(
        rows: const [],
        errors: const [
          ImportIssue(lineNumber: 0, message: 'CSV has headers but no valid student rows.'),
        ],
        skippedRows: skippedRows,
      );
    }

    return ImportResult(rows: rows, errors: errors, skippedRows: skippedRows);
  }

  static String _cellAt(List<String> columns, int index) {
    if (index >= columns.length) return '';
    return columns[index].trim();
  }
}
