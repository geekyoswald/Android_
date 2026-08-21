import 'dart:convert';

import 'csv_text.dart';

class CsvValidationResult {
  const CsvValidationResult({
    required this.isValid,
    required this.message,
    this.studentCount = 0,
  });

  final bool isValid;
  final String message;
  final int studentCount;
}

class CsvImportValidator {
  // Standard app format
  static const _requiredHeaders = {'matriculation_number', 'full_name'};
  // OVGU German export format (LSF/Prüfungsamt)
  static const _germanRequiredHeaders = {'mtknr', 'nachname', 'vorname'};

  static CsvValidationResult validate(String csvContent) {
    final lines = const LineSplitter()
        .convert(csvContent)
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const CsvValidationResult(
        isValid: false,
        message: 'Error: CSV file is empty.',
      );
    }

    final delimiter = detectDelimiter(lines.first);
    final headerColumns = parseCsvLine(lines.first, delimiter)
        .map(normalizeCsvHeader)
        .toSet();

    final isStandardFormat = _requiredHeaders.every(headerColumns.contains);
    final isGermanFormat = _germanRequiredHeaders.every(headerColumns.contains);

    if (!isStandardFormat && !isGermanFormat) {
      return const CsvValidationResult(
        isValid: false,
        message:
            'Error: Required columns are missing. Expected either (matriculation_number, full_name) or (mtknr, nachname, vorname).',
      );
    }

    final studentCount = lines.length - 1;
    if (studentCount <= 0) {
      return const CsvValidationResult(
        isValid: false,
        message: 'Error: CSV has headers but no student rows.',
      );
    }

    return CsvValidationResult(
      isValid: true,
      message: 'Import successful.',
      studentCount: studentCount,
    );
  }
}
