import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../main.dart';
import '../../data/participant_repository.dart';
import '../../domain/import_result.dart';
import '../../services/csv_import_validator.dart';
import '../../services/csv_participant_parser.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _isImportSuccessful = false;
  _ImportResultCard? _resultCard;

  Future<void> _pickCsvFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (!mounted) return;
    if (result == null) return;

    final selectedFile = result.files.single;

    if (!selectedFile.name.toLowerCase().endsWith('.csv')) {
      setState(() {
        _isImportSuccessful = false;
        _resultCard = _ImportResultCard.error(
          title: 'Invalid file type',
          lines: ['Please select a .csv file.'],
        );
      });
      return;
    }

    if (selectedFile.path == null) {
      setState(() {
        _isImportSuccessful = false;
        _resultCard = _ImportResultCard.error(
          title: 'Could not read file path',
          lines: ['The selected file path is unavailable.'],
        );
      });
      return;
    }

    try {
      final csvContent = await File(selectedFile.path!).readAsString();
      final validation = CsvImportValidator.validate(csvContent);

      if (!validation.isValid) {
        setState(() {
          _isImportSuccessful = false;
          _resultCard = _ImportResultCard.error(
            title: 'Validation failed',
            lines: [validation.message],
          );
        });
        return;
      }

      final ImportResult parseResult = CsvParticipantParser.parse(csvContent);

      if (!parseResult.isUsable) {
        final lines = [
          ...parseResult.errors.map((e) => 'Line ${e.lineNumber}: ${e.message}'),
          ...parseResult.skippedRows.map((s) => 'Line ${s.lineNumber}: ${s.message}'),
        ];
        setState(() {
          _isImportSuccessful = false;
          _resultCard = _ImportResultCard.error(
            title: '❌ Import blocked — file not saved',
            lines: lines,
          );
        });
        return;
      }

      if (!mounted) return;

      await ParticipantRepository().replaceAllParticipants(parseResult.rows);

      if (!mounted) return;

      // Per-exam-group breakdown
      final groupCounts = <String, int>{};
      for (final row in parseResult.rows) {
        final key = row.examGroup.isEmpty ? '(no exam group)' : row.examGroup;
        groupCounts[key] = (groupCounts[key] ?? 0) + 1;
      }
      final breakdownLines = groupCounts.entries
          .map((e) => '${e.value} student(s) — ${e.key}')
          .toList();

      final skipLines = parseResult.skippedRows
          .map((s) => 'Line ${s.lineNumber}: ${s.message}')
          .toList();

      setState(() {
        _isImportSuccessful = true;
        _resultCard = _ImportResultCard.success(
          title: '✅ Import successful — ${parseResult.rows.length} student(s) saved',
          breakdownLines: breakdownLines,
          skipLines: skipLines,
        );
      });
    } catch (e) {
      setState(() {
        _isImportSuccessful = false;
        _resultCard = _ImportResultCard.error(
          title: 'Failed to read or save file',
          lines: [e.toString()],
        );
      });
    }
  }

  void _dismissResult() {
    setState(() {
      _resultCard = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OVGU Exam Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Import Participant List',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Import a CSV from this device to begin attendance marking.'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickCsvFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Import CSV'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isImportSuccessful
                  ? () => Navigator.pushNamed(context, AppRoutes.scan)
                  : null,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Start Scanning'),
            ),
            if (_resultCard != null) ...[
              const SizedBox(height: 20),
              _ResultCardWidget(
                card: _resultCard!,
                onDismiss: _dismissResult,
              ),
            ],
            const Spacer(),
            const Text(
              'CSV validation and database import are active.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportResultCard {
  final bool isSuccess;
  final String title;
  final List<String> lines;

  const _ImportResultCard._({
    required this.isSuccess,
    required this.title,
    required this.lines,
  });

  factory _ImportResultCard.error({
    required String title,
    required List<String> lines,
  }) =>
      _ImportResultCard._(isSuccess: false, title: title, lines: lines);

  factory _ImportResultCard.success({
    required String title,
    required List<String> breakdownLines,
    required List<String> skipLines,
  }) {
    final lines = [
      ...breakdownLines,
      if (skipLines.isNotEmpty) ...[
        '─────────────',
        '⚠️ ${skipLines.length} row(s) skipped:',
        ...skipLines,
      ],
    ];
    return _ImportResultCard._(isSuccess: true, title: title, lines: lines);
  }
}

class _ResultCardWidget extends StatelessWidget {
  final _ImportResultCard card;
  final VoidCallback onDismiss;

  const _ResultCardWidget({required this.card, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final color = card.isSuccess ? Colors.green : Colors.red;
    final bgColor = card.isSuccess
        ? Colors.green.shade50
        : Colors.red.shade50;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    card.title,
                    style: TextStyle(
                      color: color.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: color.shade700,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDismiss,
                  tooltip: 'Dismiss',
                ),
              ],
            ),
          ),
          if (card.lines.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: card.lines
                      .map(
                        (line) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Text(
                            line,
                            style: TextStyle(
                              color: color.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onDismiss,
                child: Text('OK', style: TextStyle(color: color.shade700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
