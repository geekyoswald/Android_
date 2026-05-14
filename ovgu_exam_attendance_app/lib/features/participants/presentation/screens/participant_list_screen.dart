import 'package:flutter/material.dart';

class ParticipantListScreen extends StatelessWidget {
  const ParticipantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participant List'),
      ),
      body: const Center(
        child: Text(
          'Participant list — coming soon.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
