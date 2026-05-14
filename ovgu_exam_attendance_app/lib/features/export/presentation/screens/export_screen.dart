import 'package:flutter/material.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Attendance'),
      ),
      body: const Center(
        child: Text(
          'CSV export — coming soon.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
