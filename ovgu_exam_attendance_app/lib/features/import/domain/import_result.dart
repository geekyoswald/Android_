import 'participant_import_row.dart';

class ImportIssue {
  const ImportIssue({required this.lineNumber, required this.message});

  final int lineNumber;
  final String message;
}

class ImportResult {
  const ImportResult({
    required this.rows,
    required this.errors,
    required this.skippedRows,
  });

  final List<ParticipantImportRow> rows;
  final List<ImportIssue> errors;
  final List<ImportIssue> skippedRows;

  bool get isUsable => rows.isNotEmpty && errors.isEmpty;
}
