class DatabaseConstants {
  DatabaseConstants._();

  static const databaseName = 'ovgu_exam_attendance.db';

  /// CRITICAL: Increment this EVERY time you modify _createParticipantsTable() schema.
  /// Since data is exam-session-only (transient), onUpgrade will DROP and recreate.
  /// No migrations needed — data is not persisted across app updates.
  static const databaseVersion = 1;

  /// One row per imported student. Present marking is stored on the same row.
  static const participantsTable = 'participants';
}
