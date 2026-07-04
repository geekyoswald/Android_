import 'package:flutter_test/flutter_test.dart';

import 'package:ovgu_exam_attendance_app/features/import/domain/participant.dart';
import 'package:ovgu_exam_attendance_app/features/scan/domain/matching_engine.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Participant _p({
  required int id,
  required String matric,
  required String name,
  String examGroup = 'EinfInf',
  int status = 0,
}) =>
    Participant(
      id: id,
      matriculationNumber: matric,
      fullName: name,
      examGroup: examGroup,
      status: status,
      markedByMethod: null,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MatchingEngine.match', () {
    // ── No match ─────────────────────────────────────────────────────────────

    test('returns noMatch when list is empty', () {
      final result = MatchingEngine.match(
        participants: [],
        matricCandidate: '123456',
      );
      expect(result.status, MatchStatus.noMatch);
      expect(result.matches, isEmpty);
    });

    test('returns noMatch when matric not in list', () {
      final result = MatchingEngine.match(
        participants: [_p(id: 1, matric: '111111', name: 'Anna Becker')],
        matricCandidate: '999999',
      );
      expect(result.status, MatchStatus.noMatch);
      expect(result.matches, isEmpty);
    });

    test('returns noMatch for empty matric candidate', () {
      final result = MatchingEngine.match(
        participants: [_p(id: 1, matric: '111111', name: 'Anna Becker')],
        matricCandidate: '',
      );
      expect(result.status, MatchStatus.noMatch);
    });

    test('returns noMatch when candidate differs by leading zero', () {
      final result = MatchingEngine.match(
        participants: [_p(id: 1, matric: '123456', name: 'Anna')],
        matricCandidate: '0123456',
      );
      expect(result.status, MatchStatus.noMatch);
    });

    // ── Unique match ──────────────────────────────────────────────────────────

    test('returns uniqueMatch for exact matric with status 0', () {
      final result = MatchingEngine.match(
        participants: [_p(id: 1, matric: '123456', name: 'Anna Becker')],
        matricCandidate: '123456',
      );
      expect(result.status, MatchStatus.uniqueMatch);
      expect(result.participant.fullName, 'Anna Becker');
    });

    test('trims whitespace from candidate before matching', () {
      final result = MatchingEngine.match(
        participants: [_p(id: 1, matric: '123456', name: 'Anna Becker')],
        matricCandidate: '  123456  ',
      );
      expect(result.status, MatchStatus.uniqueMatch);
    });

    test('does not match partial matric', () {
      final result = MatchingEngine.match(
        participants: [_p(id: 1, matric: '123456', name: 'Anna')],
        matricCandidate: '1234',
      );
      expect(result.status, MatchStatus.noMatch);
    });

    test('uniqueMatch returns the correct participant object', () {
      final anna = _p(id: 7, matric: '777777', name: 'Anna Becker');
      final result = MatchingEngine.match(
        participants: [
          _p(id: 1, matric: '111111', name: 'Klaus'),
          anna,
          _p(id: 3, matric: '333333', name: 'Maria'),
        ],
        matricCandidate: '777777',
      );
      expect(result.status, MatchStatus.uniqueMatch);
      expect(result.participant.id, 7);
    });

    // ── Already marked ────────────────────────────────────────────────────────

    test('returns alreadyMarked when status is 1 (present)', () {
      final result = MatchingEngine.match(
        participants: [_p(id: 1, matric: '123456', name: 'Anna', status: 1)],
        matricCandidate: '123456',
      );
      expect(result.status, MatchStatus.alreadyMarked);
      expect(result.participant.status, 1);
    });

    test('returns alreadyMarked when status is 2 (excused)', () {
      final result = MatchingEngine.match(
        participants: [_p(id: 1, matric: '123456', name: 'Anna', status: 2)],
        matricCandidate: '123456',
      );
      expect(result.status, MatchStatus.alreadyMarked);
    });

    test('returns alreadyMarked when status is 3 (marked)', () {
      final result = MatchingEngine.match(
        participants: [_p(id: 1, matric: '123456', name: 'Anna', status: 3)],
        matricCandidate: '123456',
      );
      expect(result.status, MatchStatus.alreadyMarked);
    });

    test('alreadyMarked returns the participant with correct status', () {
      final result = MatchingEngine.match(
        participants: [_p(id: 5, matric: '555555', name: 'Ben', status: 1)],
        matricCandidate: '555555',
      );
      expect(result.matches.length, 1);
      expect(result.participant.id, 5);
      expect(result.participant.status, 1);
    });

    // ── Multiple exam groups ──────────────────────────────────────────────────

    test('returns multipleGroups when same matric in two exam groups', () {
      final result = MatchingEngine.match(
        participants: [
          _p(id: 1, matric: '123456', name: 'Anna', examGroup: 'EinfInf'),
          _p(id: 2, matric: '123456', name: 'Anna', examGroup: 'AuD'),
        ],
        matricCandidate: '123456',
      );
      expect(result.status, MatchStatus.multipleGroups);
      expect(result.matches.length, 2);
    });

    test('multipleGroups returns all matching participants', () {
      final result = MatchingEngine.match(
        participants: [
          _p(id: 1, matric: '123456', name: 'Anna', examGroup: 'EinfInf'),
          _p(id: 2, matric: '123456', name: 'Anna', examGroup: 'AuD'),
          _p(id: 3, matric: '123456', name: 'Anna', examGroup: 'Math'),
        ],
        matricCandidate: '123456',
      );
      expect(result.status, MatchStatus.multipleGroups);
      expect(result.matches.length, 3);
      expect(
        result.matches.map((p) => p.examGroup).toList(),
        containsAll(['EinfInf', 'AuD', 'Math']),
      );
    });

    test('other participants are not affected by multipleGroups match', () {
      final result = MatchingEngine.match(
        participants: [
          _p(id: 1, matric: '123456', name: 'Anna', examGroup: 'EinfInf'),
          _p(id: 2, matric: '123456', name: 'Anna', examGroup: 'AuD'),
          _p(id: 3, matric: '999999', name: 'Klaus', examGroup: 'EinfInf'),
        ],
        matricCandidate: '123456',
      );
      expect(result.matches.length, 2);
      expect(result.matches.every((p) => p.matriculationNumber == '123456'),
          isTrue);
    });
  });
}
