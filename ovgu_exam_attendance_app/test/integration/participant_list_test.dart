import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ovgu_exam_attendance_app/core/theme/app_theme.dart';
import 'package:ovgu_exam_attendance_app/features/import/domain/participant.dart';
import 'package:ovgu_exam_attendance_app/features/participants/presentation/screens/participant_list_screen.dart';

import '../helpers/fake_participant_repository.dart';

// ---------------------------------------------------------------------------
// Test data — 10 students across 2 exam groups
// ---------------------------------------------------------------------------

List<Participant> _testParticipants() => [
      Participant(id: 1,  matriculationNumber: '111111', fullName: 'Anna Becker',    examGroup: 'EinfInf', status: 0),
      Participant(id: 2,  matriculationNumber: '222222', fullName: 'Klaus Müller',   examGroup: 'EinfInf', status: 0),
      Participant(id: 3,  matriculationNumber: '333333', fullName: 'Maria Schmidt',  examGroup: 'EinfInf', status: 0),
      Participant(id: 4,  matriculationNumber: '444444', fullName: 'Jonas Weber',    examGroup: 'EinfInf', status: 0),
      Participant(id: 5,  matriculationNumber: '555555', fullName: 'Sophie Fischer', examGroup: 'EinfInf', status: 0),
      Participant(id: 6,  matriculationNumber: '666666', fullName: 'Ben Hoffmann',   examGroup: 'AuD',     status: 0),
      Participant(id: 7,  matriculationNumber: '777777', fullName: 'Lena Wagner',    examGroup: 'AuD',     status: 0),
      Participant(id: 8,  matriculationNumber: '888888', fullName: 'Felix Braun',    examGroup: 'AuD',     status: 0),
      Participant(id: 9,  matriculationNumber: '999999', fullName: 'Mia Koch',       examGroup: 'AuD',     status: 0),
      Participant(id: 10, matriculationNumber: '100000', fullName: 'Tom Richter',    examGroup: 'AuD',     status: 0),
    ];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen(FakeParticipantRepository repo) => MaterialApp(
      theme: AppTheme.lightTheme(),
      home: ParticipantListScreen(repository: repo),
    );

Future<void> _pumpScreen(WidgetTester tester, FakeParticipantRepository repo) async {
  await tester.pumpWidget(_buildScreen(repo));
  await tester.pumpAndSettle();
}

Future<void> _tapRow(WidgetTester tester, String fullName) async {
  final gesture = find
      .ancestor(of: find.text(fullName), matching: find.byType(GestureDetector))
      .first;
  await tester.tap(gesture);
  await tester.pumpAndSettle();
}

Future<void> _tapStatusOption(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Initial list rendering
  // -------------------------------------------------------------------------

  group('initial list rendering', () {
    testWidgets('first visible student is Anna Becker (alphabetical order)',
        (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      expect(find.text('Anna Becker'), findsOneWidget);
    });

    testWidgets('visible rows all show Not marked status', (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      expect(find.text('Present'), findsNothing);
      expect(find.text('Excused'), findsNothing);
      expect(find.text('Marked'), findsNothing);
    });

    testWidgets('EinfInf exam group is shown for EinfInf students',
        (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      expect(find.text('EinfInf'), findsWidgets);
    });

    testWidgets('scrolling reveals all 10 students', (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pump();

      expect(find.text('Tom Richter'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Sorting
  // -------------------------------------------------------------------------

  group('sorting', () {
    testWidgets('default sort shows Anna Becker first', (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      final nameWidgets = tester
          .widgetList<Text>(find.byWidgetPredicate(
              (w) => w is Text && _testParticipants().any((p) => p.fullName == w.data)))
          .toList();

      expect(nameWidgets.first.data, 'Anna Becker');
    });

    testWidgets('sort by matriculation shows Tom Richter first (100000)',
        (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      await tester.tap(find.byType(PopupMenuButton<SortMethod>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sort by Matriculation'));
      await tester.pump();

      final nameWidgets = tester
          .widgetList<Text>(find.byWidgetPredicate(
              (w) => w is Text && _testParticipants().any((p) => p.fullName == w.data)))
          .toList();

      expect(nameWidgets.first.data, 'Tom Richter');
    });

    testWidgets('sort by surname shows Anna Becker first (Becker)',
        (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      await tester.tap(find.byType(PopupMenuButton<SortMethod>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sort by Surname'));
      await tester.pump();

      final nameWidgets = tester
          .widgetList<Text>(find.byWidgetPredicate(
              (w) => w is Text && _testParticipants().any((p) => p.fullName == w.data)))
          .toList();

      expect(nameWidgets.first.data, 'Anna Becker');
    });
  });

  // -------------------------------------------------------------------------
  // Tap row → bottom sheet → change status
  // -------------------------------------------------------------------------

  group('tap row to change status', () {
    testWidgets('tapping a row opens bottom sheet with all status options',
        (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      await _tapRow(tester, 'Anna Becker');

      expect(find.text('Present'), findsOneWidget);
      expect(find.text('Excused'), findsOneWidget);
      expect(find.text('Marked'), findsOneWidget);
      expect(find.text('Not Marked (Undo)'), findsOneWidget);
    });

    testWidgets('marking present closes sheet and shows Present chip',
        (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      await _tapRow(tester, 'Anna Becker');
      await _tapStatusOption(tester, 'Present');

      expect(find.text('Present'), findsOneWidget);
    });

    testWidgets('marking excused closes sheet and shows Excused chip',
        (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      await _tapRow(tester, 'Anna Becker');
      await _tapStatusOption(tester, 'Excused');

      expect(find.text('Excused'), findsOneWidget);
    });

    testWidgets('undoing present status shows Not marked chip again',
        (tester) async {
      // Start with Anna already marked present
      final participants = _testParticipants();
      final annaPresent = Participant(
        id: participants[0].id,
        matriculationNumber: participants[0].matriculationNumber,
        fullName: participants[0].fullName,
        examGroup: participants[0].examGroup,
        status: 1,
      );
      final repo = FakeParticipantRepository([
        annaPresent,
        ...participants.skip(1),
      ]);
      await _pumpScreen(tester, repo);

      // Undo her status
      await _tapRow(tester, 'Anna Becker');
      await _tapStatusOption(tester, 'Not Marked (Undo)');

      expect(find.text('Present'), findsNothing);
    });

    testWidgets('status persists in fake repo after marking present',
        (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      await _tapRow(tester, 'Anna Becker');
      await _tapStatusOption(tester, 'Present');

      final all = await repo.getAllParticipants();
      final anna = all.firstWhere((p) => p.fullName == 'Anna Becker');
      expect(anna.status, 1);
      expect(all.where((p) => p.fullName != 'Anna Becker').every((p) => p.status == 0), isTrue);
    });

    testWidgets('does not affect other rows when marking one student',
        (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      await _tapRow(tester, 'Anna Becker');
      await _tapStatusOption(tester, 'Present');

      // Only one Present chip should exist
      expect(find.text('Present'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Search bar
  // -------------------------------------------------------------------------

  group('search bar', () {
    testWidgets('typing in search bar filters results', (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      await tester.enterText(find.byType(TextField), 'Anna');
      await tester.pumpAndSettle();

      expect(find.text('Anna Becker'), findsOneWidget);
      expect(find.text('Klaus Müller'), findsNothing);
    });

    testWidgets('clearing search restores full list', (tester) async {
      final repo = FakeParticipantRepository(_testParticipants());
      await _pumpScreen(tester, repo);

      await tester.enterText(find.byType(TextField), 'Anna');
      await tester.pumpAndSettle();
      expect(find.text('Klaus Müller'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(find.text('Anna Becker'), findsOneWidget);
      expect(find.text('Klaus Müller'), findsOneWidget);
    });
  });
}
