import 'package:flutter/material.dart';

import '../../../import/data/participant_repository.dart';
import '../../../import/domain/participant.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

class ManualSearchScreen extends StatefulWidget {
  final ParticipantRepository repository;

  ManualSearchScreen({
    super.key,
    ParticipantRepository? repository,
  }) : repository = repository ?? ParticipantRepository();

  @override
  State<ManualSearchScreen> createState() => _ManualSearchScreenState();
}

class _ManualSearchScreenState extends State<ManualSearchScreen> {
  ParticipantRepository get _repository => widget.repository;
  final _searchController = TextEditingController();
  List<Participant> _allParticipants = [];
  List<Participant> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final all = await _repository.getAllParticipants();
    if (mounted) {
      setState(() {
        _allParticipants = all;
        _results = all;
        _isLoading = false;
      });
    }
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _results = _allParticipants;
      } else {
        final q = query.toLowerCase();
        _results = _allParticipants.where((p) {
          return p.fullName.toLowerCase().contains(q) ||
              p.matriculationNumber.contains(q);
        }).toList();
      }
    });
  }

  Future<void> _refresh() async {
    final all = await _repository.getAllParticipants();
    if (mounted) {
      setState(() {
        _allParticipants = all;
        _search(_searchController.text);
      });
    }
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('No students found.'),
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
                            return _buildResultRow(_results[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(Participant participant) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await Navigator.pushNamed(
          context,
          AppRoutes.confirmation,
          arguments: participant,
        );
        if (confirmed == true && mounted) {
          await _refresh();
        }
      },
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
