class DatabaseConstants {
  DatabaseConstants._();

  static const databaseName = 'ovgu_exam_attendance.db';

  static const databaseVersion = 1;

  /// One row per imported student. Present marking is stored on the same row.
  static const participantsTable = 'participants';
}
