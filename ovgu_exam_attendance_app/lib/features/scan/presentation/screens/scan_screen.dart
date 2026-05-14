import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan ID Card'),
      ),
      body: const Center(
        child: Text(
          'Camera scanning — coming soon.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
