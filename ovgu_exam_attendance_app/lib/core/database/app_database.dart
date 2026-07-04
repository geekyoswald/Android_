import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  /// When set, overrides the database path. Use in tests to force an
  /// in-memory database (pass [inMemoryDatabasePath]).
  static String? testDatabasePath;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasePath = testDatabasePath ??
        join(await getDatabasesPath(), DatabaseConstants.databaseName);

    return openDatabase(
      databasePath,
      version: DatabaseConstants.databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        await _createParticipantsTable(db);
        await _createIndexes(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Exam-only app strategy: data is transient (imported for ONE exam, exported to CSV, cleared).
        // No long-term data persistence, so DROP and RECREATE is safe and preferred.
        // This ensures all devices get the latest schema without migration complexity.
        await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.participantsTable}');
        await _createParticipantsTable(db);
        await _createIndexes(db);
      },
    );
  }

  /// status: 0 = not_marked, 1 = present, 2 = excused, 3 = marked.
  /// exam_group: from CSV column; empty string when column absent.
  /// Unique per (matriculation_number, exam_group) — same student may appear in multiple exam groups.
  Future<void> _createParticipantsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.participantsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        matriculation_number TEXT NOT NULL,
        full_name TEXT NOT NULL,
        exam_group TEXT NOT NULL DEFAULT '',
        status INTEGER NOT NULL DEFAULT 0,
        UNIQUE(matriculation_number, exam_group)
      )
    ''');
  }

  /// Closes and clears the cached database instance.
  /// Use only in tests to get a fresh in-memory DB for each test case.
  Future<void> resetForTesting() async {
    await _database?.close();
    _database = null;
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX idx_participants_full_name
      ON ${DatabaseConstants.participantsTable}(full_name)
    ''');
  }
}
