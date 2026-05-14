import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'features/import/data/participant_repository.dart';
import 'features/import/domain/import_result.dart';
import 'features/import/services/csv_import_validator.dart';
import 'features/import/services/csv_participant_parser.dart';

void main() {
  runApp(const OvguAttendanceApp());
}

class OvguAttendanceApp extends StatelessWidget {
  const OvguAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OVGU Exam Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const ImportScreen(),
    );
  }
}

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  String _statusPrimary = 'No participant file imported yet.';
  String? _statusSecondary;
  bool _isImportSuccessful = false;
  Color _statusColor = Colors.grey;

  Future<void> _pickCsvFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (!mounted) {
      return;
    }

    if (result == null) {
      return;
    }

    final selectedFile = result.files.single;
    if (!selectedFile.name.toLowerCase().endsWith('.csv')) {
      setState(() {
        _isImportSuccessful = false;
        _statusPrimary = 'Error: Please select a .csv file.';
        _statusSecondary = null;
        _statusColor = Colors.red;
      });
      return;
    }

    if (selectedFile.path == null) {
      setState(() {
        _isImportSuccessful = false;
        _statusPrimary = 'Error: Could not read selected file path.';
        _statusSecondary = null;
        _statusColor = Colors.red;
      });
      return;
    }

    try {
      final csvContent = await File(selectedFile.path!).readAsString();
      final validation = CsvImportValidator.validate(csvContent);

      if (!validation.isValid) {
        setState(() {
          _isImportSuccessful = false;
          _statusPrimary = validation.message;
          _statusSecondary = null;
          _statusColor = Colors.red;
        });
        return;
      }

      final ImportResult result = CsvParticipantParser.parse(csvContent);

      if (!result.isUsable) {
        final errorMessages = result.errors.map((e) => 'Line ${e.lineNumber}: ${e.message}').toList();
        final skipMessages = result.skippedRows.map((s) => 'Line ${s.lineNumber}: ${s.message}').toList();
        final messages = [...errorMessages, ...skipMessages];

        setState(() {
          _isImportSuccessful = false;
          _statusPrimary = '❌ IMPORT BLOCKED - FILE NOT SAVED\n\n${messages.join('\n')}';
          _statusSecondary = null;
          _statusColor = Colors.red;
        });
        return;
      }

      if (!mounted) return;

      setState(() {
        _isImportSuccessful = false;
        _statusPrimary =
            'Parsed ${result.rows.length} students from ${selectedFile.name}.';
        _statusSecondary = null;
        _statusColor = Colors.orange;
      });

      await ParticipantRepository().replaceAllParticipants(result.rows);

      if (!mounted) return;

      // Build detailed report of soft errors (skipped rows)
      String? detailedIssuesReport;
      if (result.skippedRows.isNotEmpty) {
        final skipMessages = result.skippedRows
            .map((s) => 'Line ${s.lineNumber}: ${s.message}')
            .toList();
        detailedIssuesReport = '⚠️ ${result.skippedRows.length} row(s) skipped:\n${skipMessages.join('\n')}';
      }

      setState(() {
        _isImportSuccessful = true;
        _statusPrimary = '✅ IMPORT SUCCESSFUL - ${result.rows.length} students saved to database.';
        _statusSecondary = detailedIssuesReport;
        _statusColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _isImportSuccessful = false;
        _statusPrimary = 'Failed to read or save the file.\n\nError: ${e.toString()}';
        _statusSecondary = null;
        _statusColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canStartScanning = _isImportSuccessful;

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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Import a CSV from this device to begin attendance marking.',
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickCsvFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Import CSV'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: canStartScanning ? () {} : null,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Start Scanning'),
            ),
            const SizedBox(height: 20),
            Text(
              _statusPrimary,
              style: TextStyle(
                color: _statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_statusSecondary != null) ...[
              const SizedBox(height: 8),
              Text(
                _statusSecondary!,
                style: TextStyle(
                  color: _statusColor,
                  fontSize: 13,
                ),
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
