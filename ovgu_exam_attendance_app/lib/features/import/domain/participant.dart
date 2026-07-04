class Participant {
  final int id;
  final String matriculationNumber;
  final String fullName;
  final String examGroup;
  final int status;

  Participant({
    required this.id,
    required this.matriculationNumber,
    required this.fullName,
    required this.examGroup,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case 0:
        return 'Not marked';
      case 1:
        return 'Present';
      case 2:
        return 'Excused';
      case 3:
        return 'Marked';
      default:
        return 'Unknown';
    }
  }
}
