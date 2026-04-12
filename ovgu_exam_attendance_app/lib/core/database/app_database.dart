import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databaseDirectory = await getDatabasesPath();
    final databasePath = join(databaseDirectory, DatabaseConstants.databaseName);

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
        await _upgradeDatabase(db, oldVersion, newVersion);
      },
    );
  }

  /// Runs when an existing DB file has a **lower** stored version than [DatabaseConstants.databaseVersion].
  /// After this completes, sqflite persists the new version — no manual bump needed.
  ///
  /// Add one `if (oldVersion < N)` block per shipped schema step. Example for v1 → v2:
  /// ```dart
  /// if (oldVersion < 2) {
  ///   await db.execute(
  ///     'ALTER TABLE ${DatabaseConstants.participantsTable} ADD COLUMN example TEXT',
  ///   );
  /// }
  /// ```
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // When you bump [DatabaseConstants.databaseVersion], add migration steps here, e.g.:
    // if (oldVersion < 2) {
    //   await db.execute(
    //     'ALTER TABLE ${DatabaseConstants.participantsTable} ADD COLUMN example TEXT',
    //   );
    // }
    assert(oldVersion < newVersion, 'onUpgrade only runs when upgrading');
    assert(
      newVersion == DatabaseConstants.databaseVersion,
      'onUpgrade target should match DatabaseConstants.databaseVersion',
    );
  }

  /// MVP: single device, single exam — no session/scope rows.
  /// `is_present` 0 = not yet marked; 1 = marked present (export: unmarked → absent).
  Future<void> _createParticipantsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.participantsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        matriculation_number TEXT NOT NULL,
        full_name TEXT NOT NULL,
        is_present INTEGER NOT NULL DEFAULT 0,
        marked_by_method TEXT,
        UNIQUE(matriculation_number)
      )
    ''');
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX idx_participants_full_name
      ON ${DatabaseConstants.participantsTable}(full_name)
    ''');
  }
}
