import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'features/import/data/participant_repository.dart';
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
      });
      return;
    }

    if (selectedFile.path == null) {
      setState(() {
        _isImportSuccessful = false;
        _statusPrimary = 'Error: Could not read selected file path.';
        _statusSecondary = null;
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
        });
        return;
      }

      final rows = CsvParticipantParser.parse(csvContent);

      if (!mounted) {
        return;
      }

      setState(() {
        _isImportSuccessful = false;
        _statusPrimary =
            'Imported CSV: ${selectedFile.name} (${rows.length} students).';
        _statusSecondary = null;
      });

      await ParticipantRepository().replaceAllParticipants(rows);

      if (!mounted) {
        return;
      }

      setState(() {
        _isImportSuccessful = true;
        _statusSecondary = 'Saved to database.';
      });
    } on FormatException catch (e) {
      setState(() {
        _isImportSuccessful = false;
        _statusPrimary = 'Error: ${e.message}';
        _statusSecondary = null;
      });
    } catch (_) {
      setState(() {
        _isImportSuccessful = false;
        _statusPrimary =
            'Imported CSV read OK, but saving failed. Check the CSV and try again.';
        _statusSecondary = 'Error: Could not save to database.';
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
            Text(_statusPrimary),
            if (_statusSecondary != null) ...[
              const SizedBox(height: 8),
              Text(_statusSecondary!),
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
