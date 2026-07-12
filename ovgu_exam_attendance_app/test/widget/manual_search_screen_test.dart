import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ovgu_exam_attendance_app/features/import/domain/participant.dart';
import 'package:ovgu_exam_attendance_app/features/search/presentation/screens/manual_search_screen.dart';
import 'package:ovgu_exam_attendance_app/main.dart';

import '../helpers/fake_participant_repository.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _participants = [
  Participant(id: 1, matriculationNumber: '111111', fullName: 'Anna Becker',   examGroup: 'A', status: 0),
  Participant(id: 2, matriculationNumber: '222222', fullName: 'Klaus Müller',  examGroup: 'A', status: 1),
  Participant(id: 3, matriculationNumber: '333333', fullName: 'Maria Schmidt', examGroup: 'B', status: 0),
];

Widget _buildScreen(FakeParticipantRepository repo) => MaterialApp(
      routes: {
        AppRoutes.confirmation: (_) => const Scaffold(body: Text('Confirm')),
      },
      home: ManualSearchScreen(repository: repo),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ManualSearchScreen', () {
    testWidgets('shows full list on open — no typing required', (tester) async {
      final repo = FakeParticipantRepository(_participants);
      await tester.pumpWidget(_buildScreen(repo));
      await tester.pumpAndSettle();

      expect(find.text('Anna Becker'), findsOneWidget);
      expect(find.text('Klaus Müller'), findsOneWidget);
      expect(find.text('Maria Schmidt'), findsOneWidget);
    });

    testWidgets('typing filters list by name', (tester) async {
      final repo = FakeParticipantRepository(_participants);
      await tester.pumpWidget(_buildScreen(repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Anna');
      await tester.pumpAndSettle();

      expect(find.text('Anna Becker'), findsOneWidget);
      expect(find.text('Klaus Müller'), findsNothing);
      expect(find.text('Maria Schmidt'), findsNothing);
    });

    testWidgets('typing filters list by matriculation number', (tester) async {
      final repo = FakeParticipantRepository(_participants);
      await tester.pumpWidget(_buildScreen(repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '3333');
      await tester.pumpAndSettle();

      expect(find.text('Maria Schmidt'), findsOneWidget);
      expect(find.text('Anna Becker'), findsNothing);
    });

    testWidgets('clearing search restores full list', (tester) async {
      final repo = FakeParticipantRepository(_participants);
      await tester.pumpWidget(_buildScreen(repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Anna');
      await tester.pumpAndSettle();
      expect(find.text('Klaus Müller'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      expect(find.text('Anna Becker'), findsOneWidget);
      expect(find.text('Klaus Müller'), findsOneWidget);
      expect(find.text('Maria Schmidt'), findsOneWidget);
    });

    testWidgets('shows no results message when query has no match',
        (tester) async {
      final repo = FakeParticipantRepository(_participants);
      await tester.pumpWidget(_buildScreen(repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzznomatch');
      await tester.pumpAndSettle();

      expect(find.text('No students found.'), findsOneWidget);
    });

    testWidgets('status chips are shown for each participant', (tester) async {
      final repo = FakeParticipantRepository(_participants);
      await tester.pumpWidget(_buildScreen(repo));
      await tester.pumpAndSettle();

      // Klaus has status 1 (Present), others are 0 (Not marked)
      expect(find.text('Present'), findsOneWidget);
      expect(find.text('Not marked'), findsWidgets);
    });
  });
}
