import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_constants.dart';
import '../../../core/database/app_database.dart';
import '../domain/participant_import_row.dart';
import '../domain/participant.dart';

class ParticipantRepository {
  Future<void> replaceAllParticipants(List<ParticipantImportRow> rows) async {
    final db = await AppDatabase.instance.database;

    await db.transaction((txn) async {
      await txn.delete(DatabaseConstants.participantsTable);

      for (final row in rows) {
        await txn.insert(
          DatabaseConstants.participantsTable,
          {
            'matriculation_number': row.matriculationNumber,
            'full_name': row.fullName,
            'exam_group': row.examGroup,
            'status': 0,
            'marked_by_method': null,
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
    });
  }

  Future<List<Participant>> getAllParticipants() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      DatabaseConstants.participantsTable,
      orderBy: 'full_name ASC',
    );
    return [
      for (final map in maps)
        Participant(
          id: map['id'] as int,
          matriculationNumber: map['matriculation_number'] as String,
          fullName: map['full_name'] as String,
          examGroup: map['exam_group'] as String? ?? '',
          status: map['status'] as int,
          markedByMethod: map['marked_by_method'] as String?,
        ),
    ];
  }

  Future<Map<int, int>> getStatusCounts() async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      'SELECT status, COUNT(*) as count FROM ${DatabaseConstants.participantsTable} GROUP BY status',
    );
    final counts = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};
    for (final row in result) {
      final status = row['status'] as int;
      final count = row['count'] as int;
      counts[status] = count;
    }
    return counts;
  }

  Future<Map<String, Map<String, int>>> getCountsByExamGroup() async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      'SELECT exam_group, status, COUNT(*) as count FROM ${DatabaseConstants.participantsTable} GROUP BY exam_group, status',
    );
    final counts = <String, Map<String, int>>{};
    for (final row in result) {
      final examGroup = row['exam_group'] as String? ?? '';
      final status = row['status'] as int;
      final count = row['count'] as int;

      if (!counts.containsKey(examGroup)) {
        counts[examGroup] = {'present': 0, 'total': 0};
      }
      counts[examGroup]!['total'] = counts[examGroup]!['total']! + count;
      if (status == 1) {
        counts[examGroup]!['present'] = counts[examGroup]!['present']! + count;
      }
    }
    return counts;
  }

  Future<void> updateStatus(int id, int status, String? method) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      DatabaseConstants.participantsTable,
      {
        'status': status,
        'marked_by_method': method,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
