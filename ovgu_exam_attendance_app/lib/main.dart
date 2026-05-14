import 'package:flutter/material.dart';

import 'features/export/presentation/screens/export_screen.dart';
import 'features/import/presentation/screens/import_screen.dart';
import 'features/participants/presentation/screens/participant_list_screen.dart';
import 'features/scan/presentation/screens/scan_screen.dart';

void main() {
  runApp(const OvguAttendanceApp());
}

class AppRoutes {
  static const import_ = '/';
  static const scan = '/scan';
  static const participantList = '/participants';
  static const export_ = '/export';
}

class OvguAttendanceApp extends StatelessWidget {
  const OvguAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OVGU Exam Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      initialRoute: AppRoutes.import_,
      routes: {
        AppRoutes.import_: (_) => const ImportScreen(),
        AppRoutes.scan: (_) => const ScanScreen(),
        AppRoutes.participantList: (_) => const ParticipantListScreen(),
        AppRoutes.export_: (_) => const ExportScreen(),
      },
    );
  }
}
