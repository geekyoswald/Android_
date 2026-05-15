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
  const ParticipantListScreen({super.key});

  @override
  State<ParticipantListScreen> createState() => _ParticipantListScreenState();
}

class _ParticipantListScreenState extends State<ParticipantListScreen> {
  late Future<List<Participant>> _participantsFuture;
  final _repository = ParticipantRepository();
  SortMethod _sortMethod = SortMethod.fullName;

  @override
  void initState() {
    super.initState();
    _participantsFuture = _repository.getAllParticipants();
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

          if (participants.isEmpty) {
            return const Center(
              child: Text('No participants imported yet.'),
            );
          }

          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return _buildParticipantRow(participant);
            },
          );
        },
      ),
    );
  }

  Widget _buildParticipantRow(Participant participant) {
    return Padding(
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
    );
  }
}
