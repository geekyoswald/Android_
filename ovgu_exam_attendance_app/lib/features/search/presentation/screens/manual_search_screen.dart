import 'package:flutter/material.dart';

import '../../../import/data/participant_repository.dart';
import '../../../import/domain/participant.dart';
import '../../../../core/theme/app_theme.dart';

class ManualSearchScreen extends StatefulWidget {
  const ManualSearchScreen({super.key});

  @override
  State<ManualSearchScreen> createState() => _ManualSearchScreenState();
}

class _ManualSearchScreenState extends State<ManualSearchScreen> {
  final _repository = ParticipantRepository();
  final _searchController = TextEditingController();
  List<Participant> _results = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    _repository.searchParticipants(query).then((results) {
      if (mounted) {
        setState(() {
          _results = results;
          _hasSearched = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Search'),
      ),
      body: Padding(
        padding: AppTheme.screenPadding,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search by name or matriculation number',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
              ),
            ),
            AppTheme.verticalSpacingLarge,
            Expanded(
              child: _hasSearched
                  ? _results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Student not in list.'),
                              AppTheme.verticalSpacingMedium,
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Back to Scanning'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final participant = _results[index];
                            return _buildResultRow(participant);
                          },
                        )
                  : const Center(
                      child: Text('Start typing to search...'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(Participant participant) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, participant),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.fullName,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        participant.matriculationNumber,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                AppTheme.statusChip(status: participant.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
