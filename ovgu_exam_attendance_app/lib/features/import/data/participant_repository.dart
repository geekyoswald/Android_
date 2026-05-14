import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_constants.dart';
import '../../../core/database/app_database.dart';
import '../domain/participant_import_row.dart';

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
}
