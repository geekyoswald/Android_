import 'package:ovgu_exam_attendance_app/features/import/data/participant_repository.dart';
import 'package:ovgu_exam_attendance_app/features/import/domain/participant.dart';
import 'package:ovgu_exam_attendance_app/features/import/domain/participant_import_row.dart';

/// In-memory fake repository for widget tests.
/// No real database — no OS threads — no hanging.
class FakeParticipantRepository extends ParticipantRepository {
  List<Participant> _participants;

  FakeParticipantRepository([List<Participant>? initial])
      : _participants = List.of(initial ?? []);

  @override
  Future<List<Participant>> getAllParticipants() async =>
      List.of(_participants);

  @override
  Future<void> updateStatus(int id, int status) async {
    _participants = [
      for (final p in _participants)
        if (p.id == id)
          Participant(
            id: p.id,
            matriculationNumber: p.matriculationNumber,
            fullName: p.fullName,
            examGroup: p.examGroup,
            status: status,
          )
        else
          p,
    ];
  }

  @override
  Future<List<Participant>> searchParticipants(String query) async {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _participants
        .where((p) =>
            p.fullName.toLowerCase().contains(q) ||
            p.matriculationNumber.contains(q))
        .toList();
  }

  @override
  Future<Map<int, int>> getStatusCounts() async {
    final counts = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};
    for (final p in _participants) {
      counts[p.status] = (counts[p.status] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Future<Map<String, Map<String, int>>> getCountsByExamGroup() async {
    final counts = <String, Map<String, int>>{};
    for (final p in _participants) {
      final key = p.examGroup.isEmpty ? '' : p.examGroup;
      counts.putIfAbsent(key, () => {'present': 0, 'total': 0});
      counts[key]!['total'] = counts[key]!['total']! + 1;
      if (p.status == 1) {
        counts[key]!['present'] = counts[key]!['present']! + 1;
      }
    }
    return counts;
  }

  @override
  Future<void> replaceAllParticipants(List<ParticipantImportRow> rows) async {
    _participants = [
      for (var i = 0; i < rows.length; i++)
        Participant(
          id: i + 1,
          matriculationNumber: rows[i].matriculationNumber,
          fullName: rows[i].fullName,
          examGroup: rows[i].examGroup,
          status: 0,
        ),
    ];
  }
}
