import 'package:flutter/material.dart';

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

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

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
              onPressed: () {},
              icon: const Icon(Icons.upload_file),
              label: const Text('Import CSV'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Start Scanning'),
            ),
            const SizedBox(height: 20),
            const Text('No participant file imported yet.'),
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
