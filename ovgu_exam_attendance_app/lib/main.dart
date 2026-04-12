import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'features/import/services/csv_import_validator.dart';

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
  String? _selectedCsvFileName;
  String _importStatusMessage = 'No participant file imported yet.';
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
        _selectedCsvFileName = null;
        _isImportSuccessful = false;
        _importStatusMessage = 'Error: Please select a .csv file.';
      });
      return;
    }

    if (selectedFile.path == null) {
      setState(() {
        _selectedCsvFileName = null;
        _isImportSuccessful = false;
        _importStatusMessage = 'Error: Could not read selected file path.';
      });
      return;
    }

    try {
      final csvContent = await File(selectedFile.path!).readAsString();
      final validation = CsvImportValidator.validate(csvContent);

      setState(() {
        _selectedCsvFileName = validation.isValid ? selectedFile.name : null;
        _isImportSuccessful = validation.isValid;
        _importStatusMessage = validation.isValid
            ? 'Success: ${selectedFile.name} imported (${validation.studentCount} students).'
            : validation.message;
      });
    } catch (_) {
      setState(() {
        _selectedCsvFileName = null;
        _isImportSuccessful = false;
        _importStatusMessage = 'Error: Failed to read the selected CSV file.';
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
            Text(_importStatusMessage),
            if (_selectedCsvFileName != null) ...[
              const SizedBox(height: 8),
              Text('Selected file: $_selectedCsvFileName'),
            ],
            const Spacer(),
            const Text(
              'Step 3 complete: basic CSV validation is active.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
