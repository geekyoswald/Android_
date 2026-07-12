import 'package:flutter/material.dart';

import '../../../import/data/participant_repository.dart';
import '../../../import/domain/participant.dart';
import '../../../../core/theme/app_theme.dart';

enum SortMethod {
  fullName,
  matriculation,
  surname,
}

class ParticipantListScreen extends StatefulWidget {
  final ParticipantRepository repository;

  ParticipantListScreen({
    super.key,
    ParticipantRepository? repository,
  }) : repository = repository ?? ParticipantRepository();

  @override
  State<ParticipantListScreen> createState() => _ParticipantListScreenState();
}

class _ParticipantListScreenState extends State<ParticipantListScreen> {
  late Future<List<Participant>> _participantsFuture;
  ParticipantRepository get _repository => widget.repository;
  final _searchController = TextEditingController();
  SortMethod _sortMethod = SortMethod.fullName;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _participantsFuture = _repository.getAllParticipants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Participant> _sortParticipants(List<Participant> participants) {
    switch (_sortMethod) {
      case SortMethod.fullName:
        participants.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case SortMethod.matriculation:
        participants.sort((a, b) => a.matriculationNumber.compareTo(b.matriculationNumber));
        break;
      case SortMethod.surname:
        participants.sort((a, b) {
          final aSurname = a.fullName.split(' ').last;
          final bSurname = b.fullName.split(' ').last;
          return aSurname.compareTo(bSurname);
        });
        break;
    }
    return participants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participant List'),
        actions: [
          PopupMenuButton<SortMethod>(
            initialValue: _sortMethod,
            onSelected: (method) {
              setState(() {
                _sortMethod = method;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortMethod.fullName,
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: SortMethod.matriculation,
                child: Text('Sort by Matriculation'),
              ),
              const PopupMenuItem(
                value: SortMethod.surname,
                child: Text('Sort by Surname'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Participant>>(
        future: _participantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          var participants = snapshot.data ?? [];
          participants = _sortParticipants(participants);

          final filtered = _searchQuery.isEmpty
              ? participants
              : participants.where((p) {
                  final q = _searchQuery.toLowerCase();
                  return p.fullName.toLowerCase().contains(q) ||
                      p.matriculationNumber.contains(q);
                }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by name or matriculation number',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              if (participants.isEmpty)
                const Expanded(
                  child: Center(child: Text('No participants imported yet.')),
                )
              else if (filtered.isEmpty)
                const Expanded(
                  child: Center(child: Text('No results found.')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _buildParticipantRow(filtered[index]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildParticipantRow(Participant participant) {
    return GestureDetector(
      onTap: () => _showStatusBottomSheet(participant),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        participant.matriculationNumber,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (participant.examGroup.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          participant.examGroup,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AppTheme.statusChip(status: participant.status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStatusBottomSheet(Participant participant) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Status for ${participant.fullName}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _buildStatusOption(participant, 1, 'Present'),
              _buildStatusOption(participant, 2, 'Excused'),
              _buildStatusOption(participant, 3, 'Marked'),
              _buildStatusOption(participant, 0, 'Not Marked (Undo)'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(Participant participant, int status, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () async {
            await _repository.updateStatus(participant.id, status);
            if (mounted) {
              setState(() {
                _participantsFuture = _repository.getAllParticipants();
              });
              Navigator.pop(context);
            }
          },
          child: Text(label),
        ),
      ),
    );
  }
}
