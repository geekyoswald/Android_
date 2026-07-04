import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../import/domain/participant.dart';

class ExportService {
  ExportService._(); // static-only

  static const _headers =
      'matriculation_number,full_name,exam_group,status';

  static String _statusLabel(int status) {
    switch (status) {
      case 1:
        return 'present';
      case 2:
        return 'excused';
      case 3:
        return 'marked';
      default:
        return 'absent';
    }
  }

  /// Builds a CSV string from [participants], with a summary block appended.
  static String buildCsv(List<Participant> participants) {
    final buffer = StringBuffer();
    buffer.writeln(_headers);
    for (final p in participants) {
      final fields = [
        p.matriculationNumber,
        _escapeCsv(p.fullName),
        _escapeCsv(p.examGroup),
        _statusLabel(p.status),
      ];
      buffer.writeln(fields.join(','));
    }

    // Summary block
    final total = participants.length;
    final present = participants.where((p) => p.status == 1).length;
    final excused = participants.where((p) => p.status == 2).length;
    final marked = participants.where((p) => p.status == 3).length;
    final absent = participants.where((p) => p.status == 0).length;

    buffer.writeln();
    buffer.writeln('SUMMARY');
    buffer.writeln('total,$total');
    buffer.writeln('present,$present');
    buffer.writeln('absent,$absent');
    buffer.writeln('excused,$excused');
    buffer.writeln('marked,$marked');

    return buffer.toString();
  }

  /// Opens a "Save to folder" dialog (Android SAF / iOS Files picker) so the
  /// user can choose exactly where to save the CSV.
  /// Returns the saved file path, or null if the user cancelled.
  static Future<String?> saveToFolder(
    String csv, {
    String filename = 'attendance.csv',
  }) async {
    final bytes = Uint8List.fromList(csv.codeUnits);

    final savedPath = await FilePicker.saveFile(
      dialogTitle: 'Save attendance CSV',
      fileName: filename,
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: bytes,
    );

    return savedPath;
  }

  /// Wraps a field in double-quotes if it contains a comma, quote, or newline.
  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
