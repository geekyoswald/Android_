class DatabaseConstants {
  DatabaseConstants._();

  static const databaseName = 'ovgu_exam_attendance.db';

  /// `sqflite` requires a version on [openDatabase]. See **Database versioning** in
  /// `docs/ovgu_exam_attendance_docs/README.md`.
  ///
  /// - **Active dev:** often keep this at **1** and wipe the DB (uninstall / clear storage) when
  ///   you change `CREATE TABLE`/`onCreate` without writing a migration yet.
  /// - **Store update:** bump this number and implement `AppDatabase._upgradeDatabase`
  ///   so existing installs migrate without losing data.
  static const databaseVersion = 1;

  /// One row per imported student. Present marking is stored on the same row.
  static const participantsTable = 'participants';
}
