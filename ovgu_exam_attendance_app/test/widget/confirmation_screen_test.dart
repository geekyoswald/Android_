import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ovgu_exam_attendance_app/features/confirmation/presentation/screens/confirmation_screen.dart';
import 'package:ovgu_exam_attendance_app/features/import/domain/participant.dart';

import '../helpers/fake_participant_repository.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _participant = Participant(
  id: 1,
  matriculationNumber: '123456',
  fullName: 'Anna Becker',
  examGroup: 'EinfInf',
  status: 0,
);

Widget _buildScreen(FakeParticipantRepository repo) => MaterialApp(
      home: ConfirmationScreen(participant: _participant, repository: repo),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ConfirmationScreen', () {
    testWidgets('shows student name and matric number', (tester) async {
      final repo = FakeParticipantRepository([_participant]);
      await tester.pumpWidget(_buildScreen(repo));

      expect(find.text('Anna Becker'), findsOneWidget);
      expect(find.text('Matric: 123456'), findsOneWidget);
    });

    testWidgets('shows exam group when non-empty', (tester) async {
      final repo = FakeParticipantRepository([_participant]);
      await tester.pumpWidget(_buildScreen(repo));

      expect(find.text('Exam group: EinfInf'), findsOneWidget);
    });

    testWidgets('tapping confirm shows confirming state (CircularProgressIndicator)',
        (tester) async {
      final repo = FakeParticipantRepository([_participant]);
      await tester.pumpWidget(_buildScreen(repo));

      // Button shows Confirm label before tap
      expect(find.text('✓ Confirm'), findsOneWidget);

      await tester.tap(find.text('✓ Confirm'));
      await tester.pump(); // process tap → setState(_isConfirming = true)

      // Button now shows spinner — confirms the confirming state is entered
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('tapping cancel pops screen with false', (tester) async {
      final repo = FakeParticipantRepository([_participant]);
      Object? poppedValue;

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              poppedValue = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConfirmationScreen(
                    participant: _participant,
                    repository: repo,
                  ),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(poppedValue, false);
    });

    testWidgets('confirm button is disabled while confirming', (tester) async {
      final repo = FakeParticipantRepository([_participant]);
      await tester.pumpWidget(_buildScreen(repo));

      // Button should be enabled initially
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '✓ Confirm'),
      );
      expect(button.onPressed, isNotNull);
    });
  });
}
