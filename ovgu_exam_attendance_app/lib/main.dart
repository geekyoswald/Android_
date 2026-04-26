import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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

  Future<void> _pickCsvFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (!mounted) {
      return;
    }

    if (result != null && result.files.single.name.toLowerCase().endsWith('.csv')) {
      setState(() {
        _selectedCsvFileName = result.files.single.name;
      });
      return;
    }

    setState(() {
      _selectedCsvFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canStartScanning = _selectedCsvFileName != null;
    final importStatus = _selectedCsvFileName == null
        ? 'No participant file imported yet.'
        : 'Selected file: $_selectedCsvFileName';

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
            Text(importStatus),
            const Spacer(),
            const Text(
              'UI setup only: CSV parsing and navigation will be added next.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
