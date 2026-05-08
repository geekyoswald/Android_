class DatabaseConstants {
  DatabaseConstants._();

  static const databaseName = 'ovgu_exam_attendance.db';

  /// sqflite requires a version on openDatabase. Since this app is exam-time only
  /// (no long-term data retention), no migration logic is needed — schema changes
  /// just require a fresh install or clearing app storage during dev.
  static const databaseVersion = 1;

  /// One row per imported student. Present marking is stored on the same row.
  static const participantsTable = 'participants';
}
