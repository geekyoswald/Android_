class ParticipantImportRow {
  const ParticipantImportRow({
    required this.matriculationNumber,
    required this.fullName,
    this.examGroup = '',
  });

  final String matriculationNumber;
  final String fullName;
  final String examGroup;
}
