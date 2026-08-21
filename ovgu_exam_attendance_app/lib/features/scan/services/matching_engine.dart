import '../../import/domain/participant.dart';

/// The four possible outcomes when matching an OCR-detected matric number
/// against the participant list.
enum MatchStatus {
  /// Exactly one participant found with status = 0 (not yet marked).
  uniqueMatch,

  /// Exactly one participant found but already marked (status > 0).
  alreadyMarked,

  /// Multiple participants share the same matric number (different exam groups).
  /// The user must pick which group to confirm.
  multipleGroups,

  /// No participant found with this matric number.
  noMatch,
}

class MatchResult {
  final MatchStatus status;

  /// The matching participant(s).
  /// - [uniqueMatch] / [alreadyMarked]: exactly one element.
  /// - [multipleGroups]: two or more elements (one per exam group).
  /// - [noMatch]: empty.
  final List<Participant> matches;

  const MatchResult({required this.status, required this.matches});

  /// Convenience getter for the single participant when there is exactly one.
  Participant get participant => matches.first;
}

/// Pure domain logic — no async, no DB access.
/// Takes the full participant list (already fetched) and the raw matric
/// string from OCR, returns a [MatchResult].
class MatchingEngine {
  MatchingEngine._(); // static-only

  static MatchResult match({
    required List<Participant> participants,
    required String matricCandidate,
  }) {
    final normalised = matricCandidate.trim();

    final found = participants
        .where((p) => p.matriculationNumber == normalised)
        .toList();

    if (found.isEmpty) {
      return const MatchResult(status: MatchStatus.noMatch, matches: []);
    }

    if (found.length > 1) {
      // Same matric across multiple exam groups — needs disambiguation.
      return MatchResult(status: MatchStatus.multipleGroups, matches: found);
    }

    // Single match — check whether already marked.
    final single = found.first;
    if (single.status > 0) {
      return MatchResult(status: MatchStatus.alreadyMarked, matches: [single]);
    }

    return MatchResult(status: MatchStatus.uniqueMatch, matches: [single]);
  }
}
