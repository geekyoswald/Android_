import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../import/data/participant_repository.dart';
import '../../data/export_service.dart';

class ExportScreen extends StatefulWidget {
  final ParticipantRepository repository;

  ExportScreen({
    super.key,
    ParticipantRepository? repository,
  }) : repository = repository ?? ParticipantRepository();

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  ParticipantRepository get _repository => widget.repository;
  bool _isExporting = false;
  String? _lastSavedPath;

  Future<void> _export() async {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
      _lastSavedPath = null;
    });

    try {
      final participants = await _repository.getAllParticipants();
      if (!mounted) return;

      if (participants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No participants to export.')),
        );
        return;
      }

      final csv = ExportService.buildCsv(participants);
      final savedPath = await ExportService.saveToFolder(csv);

      if (!mounted) return;

      if (savedPath != null) {
        setState(() => _lastSavedPath = savedPath);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV saved successfully.')),
        );
      }
      // If null — user cancelled, do nothing
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CSV Export',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The CSV will contain:\n'
                    '• Matriculation number\n'
                    '• Full name\n'
                    '• Exam group\n'
                    '• Status (present / excused / marked / absent)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Unmarked students will appear as absent in the export.',
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                  ),
                ],
              ),
            ),
            // Last saved path
            if (_lastSavedPath != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Saved to: $_lastSavedPath',
                        style: TextStyle(
                            color: Colors.green.shade800, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _export,
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_alt),
                label: Text(
                  _isExporting ? 'Preparing…' : 'Save CSV to Folder',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            AppTheme.verticalSpacingMedium,
          ],
        ),
      ),
    );
  }
}
