// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:ovgu_exam_attendance_app/core/database/app_database.dart';
import 'package:ovgu_exam_attendance_app/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.testDatabasePath = ':memory:';
  });

  setUp(() async {
    await AppDatabase.instance.resetForTesting();
  });

  testWidgets('Import screen renders expected controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OvguAttendanceApp());
    await tester.pumpAndSettle();

    expect(find.text('OVGU Exam Attendance'), findsOneWidget);
    expect(find.text('Import Participant List'), findsOneWidget);
    expect(find.text('Import CSV'), findsOneWidget);
    expect(find.text('Start Scanning'), findsOneWidget);
  });
}
