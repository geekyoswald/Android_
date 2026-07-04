import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../import/data/participant_repository.dart';
import '../../../import/domain/participant.dart';

class ConfirmationScreen extends StatefulWidget {
  final Participant participant;

  const ConfirmationScreen({super.key, required this.participant});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final _repository = ParticipantRepository();
  bool _isConfirming = false;

  Future<void> _confirm() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);

    await HapticFeedback.mediumImpact();
    await _repository.updateStatus(widget.participant.id, 1, 'manual');

    if (mounted) {
      Navigator.pop(context, true); // true = confirmed
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.participant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            // Student details card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Matric: ${p.matriculationNumber}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (p.examGroup.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Exam group: ${p.examGroup}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            // Single large confirm button
            SizedBox(
              height: 64,
              child: ElevatedButton.icon(
                onPressed: _isConfirming ? null : _confirm,
                icon: _isConfirming
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 28),
                label: Text(
                  _isConfirming ? 'Confirming…' : '✓ Confirm',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isConfirming ? null : () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
