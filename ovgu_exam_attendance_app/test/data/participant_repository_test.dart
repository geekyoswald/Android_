import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:ovgu_exam_attendance_app/core/database/app_database.dart';
import 'package:ovgu_exam_attendance_app/features/import/data/participant_repository.dart';
import 'package:ovgu_exam_attendance_app/features/import/domain/participant_import_row.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<ParticipantImportRow> _rows({String examGroup = ''}) => [
      ParticipantImportRow(
        matriculationNumber: '111111',
        fullName: 'Anna Becker',
        examGroup: examGroup,
      ),
      ParticipantImportRow(
        matriculationNumber: '222222',
        fullName: 'Klaus Müller',
        examGroup: examGroup,
      ),
      ParticipantImportRow(
        matriculationNumber: '333333',
        fullName: 'Maria Schmidt',
        examGroup: examGroup,
      ),
    ];

// ---------------------------------------------------------------------------
// Test setup — uses sqflite_common_ffi so tests run on desktop / CI
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Force every openDatabase call to use an in-memory DB.
    AppDatabase.testDatabasePath = ':memory:';
  });

  setUp(() async {
    // Close and discard the previous in-memory DB so each test starts fresh.
    await AppDatabase.instance.resetForTesting();
  });

  final repo = ParticipantRepository();

  // -------------------------------------------------------------------------
  // replaceAllParticipants
  // -------------------------------------------------------------------------

  group('replaceAllParticipants', () {
    test('inserts all rows and returns correct count via getAllParticipants',
        () async {
      await repo.replaceAllParticipants(_rows());
      final all = await repo.getAllParticipants();
      expect(all.length, 3);
    });

    test('clears previous data before inserting', () async {
      await repo.replaceAllParticipants(_rows());
      await repo.replaceAllParticipants([
        ParticipantImportRow(
          matriculationNumber: '999999',
          fullName: 'Only One',
        ),
      ]);
      final all = await repo.getAllParticipants();
      expect(all.length, 1);
      expect(all.first.matriculationNumber, '999999');
    });

    test('all inserted rows have status 0 and null markedByMethod', () async {
      await repo.replaceAllParticipants(_rows());
      final all = await repo.getAllParticipants();
      for (final p in all) {
        expect(p.status, 0);
        expect(p.markedByMethod, isNull);
      }
    });
  });

  // -------------------------------------------------------------------------
  // getAllParticipants
  // -------------------------------------------------------------------------

  group('getAllParticipants', () {
    test('returns empty list when table is empty', () async {
      final all = await repo.getAllParticipants();
      expect(all, isEmpty);
    });

    test('returns rows ordered by full_name ascending', () async {
      await repo.replaceAllParticipants(_rows());
      final all = await repo.getAllParticipants();
      final names = all.map((p) => p.fullName).toList();
      expect(names, ['Anna Becker', 'Klaus Müller', 'Maria Schmidt']);
    });

    test('maps all fields correctly', () async {
      await repo.replaceAllParticipants([
        ParticipantImportRow(
          matriculationNumber: '123456',
          fullName: 'Test User',
          examGroup: 'EinfInf',
        ),
      ]);
      final p = (await repo.getAllParticipants()).first;
      expect(p.matriculationNumber, '123456');
      expect(p.fullName, 'Test User');
      expect(p.examGroup, 'EinfInf');
      expect(p.status, 0);
      expect(p.markedByMethod, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // getStatusCounts
  // -------------------------------------------------------------------------

  group('getStatusCounts', () {
    test('returns all four statuses as 0 when table is empty', () async {
      final counts = await repo.getStatusCounts();
      expect(counts, {0: 0, 1: 0, 2: 0, 3: 0});
    });

    test('counts each status correctly after updates', () async {
      await repo.replaceAllParticipants(_rows());
      final all = await repo.getAllParticipants();

      // Mark: Anna → present (1), Klaus → excused (2)
      await repo.updateStatus(all[0].id, 1, 'manual');
      await repo.updateStatus(all[1].id, 2, 'manual');

      final counts = await repo.getStatusCounts();
      expect(counts[0], 1); // Maria — not marked
      expect(counts[1], 1); // Anna — present
      expect(counts[2], 1); // Klaus — excused
      expect(counts[3], 0);
    });
  });

  // -------------------------------------------------------------------------
  // getCountsByExamGroup
  // -------------------------------------------------------------------------

  group('getCountsByExamGroup', () {
    test('returns empty map when table is empty', () async {
      final counts = await repo.getCountsByExamGroup();
      expect(counts, isEmpty);
    });

    test('returns correct present and total per exam group', () async {
      await repo.replaceAllParticipants([
        ParticipantImportRow(
            matriculationNumber: '111111',
            fullName: 'A',
            examGroup: 'EinfInf'),
        ParticipantImportRow(
            matriculationNumber: '222222',
            fullName: 'B',
            examGroup: 'EinfInf'),
        ParticipantImportRow(
            matriculationNumber: '333333', fullName: 'C', examGroup: 'AuD'),
      ]);

      final all = await repo.getAllParticipants();
      // Mark A (EinfInf) present
      final a = all.firstWhere((p) => p.matriculationNumber == '111111');
      await repo.updateStatus(a.id, 1, 'scan');

      final counts = await repo.getCountsByExamGroup();
      expect(counts['EinfInf']!['total'], 2);
      expect(counts['EinfInf']!['present'], 1);
      expect(counts['AuD']!['total'], 1);
      expect(counts['AuD']!['present'], 0);
    });
  });

  // -------------------------------------------------------------------------
  // updateStatus
  // -------------------------------------------------------------------------

  group('updateStatus', () {
    test('updates status and markedByMethod correctly', () async {
      await repo.replaceAllParticipants(_rows());
      final all = await repo.getAllParticipants();
      final target = all.first;

      await repo.updateStatus(target.id, 1, 'scan');

      final updated = (await repo.getAllParticipants())
          .firstWhere((p) => p.id == target.id);
      expect(updated.status, 1);
      expect(updated.markedByMethod, 'scan');
    });

    test('can undo status back to 0 with null method', () async {
      await repo.replaceAllParticipants(_rows());
      final all = await repo.getAllParticipants();
      final target = all.first;

      await repo.updateStatus(target.id, 1, 'manual');
      await repo.updateStatus(target.id, 0, null);

      final updated = (await repo.getAllParticipants())
          .firstWhere((p) => p.id == target.id);
      expect(updated.status, 0);
      expect(updated.markedByMethod, isNull);
    });

    test('does not affect other rows', () async {
      await repo.replaceAllParticipants(_rows());
      final all = await repo.getAllParticipants();

      await repo.updateStatus(all[0].id, 1, 'manual');

      final others =
          (await repo.getAllParticipants()).where((p) => p.id != all[0].id);
      for (final p in others) {
        expect(p.status, 0);
      }
    });
  });

  // -------------------------------------------------------------------------
  // searchParticipants
  // -------------------------------------------------------------------------

  group('searchParticipants', () {
    setUp(() async {
      await repo.replaceAllParticipants([
        ParticipantImportRow(
            matriculationNumber: '111111', fullName: 'Anna Becker'),
        ParticipantImportRow(
            matriculationNumber: '222222', fullName: 'Klaus Müller'),
        ParticipantImportRow(
            matriculationNumber: '333333', fullName: 'Maria Schmidt'),
      ]);
    });

    test('returns empty list for empty query', () async {
      final results = await repo.searchParticipants('');
      expect(results, isEmpty);
    });

    test('finds by partial name', () async {
      final results = await repo.searchParticipants('Beck');
      expect(results.length, 1);
      expect(results.first.fullName, 'Anna Becker');
    });

    test('finds by partial matriculation number', () async {
      final results = await repo.searchParticipants('2222');
      expect(results.length, 1);
      expect(results.first.matriculationNumber, '222222');
    });

    test('exact matriculation match is ranked first', () async {
      // Insert a student whose name also contains '111111' to force ranking check
      await repo.replaceAllParticipants([
        ParticipantImportRow(
            matriculationNumber: '111111', fullName: 'Alice 111111'),
        ParticipantImportRow(
            matriculationNumber: '999999', fullName: 'Bob'),
      ]);
      final results = await repo.searchParticipants('111111');
      expect(results.first.matriculationNumber, '111111');
    });

    test('returns no results for non-matching query', () async {
      final results = await repo.searchParticipants('zzznomatch');
      expect(results, isEmpty);
    });

    test('search is case-insensitive for ASCII names', () async {
      final results = await repo.searchParticipants('anna');
      expect(results.length, 1);
      expect(results.first.fullName, 'Anna Becker');
    });
  });
}
