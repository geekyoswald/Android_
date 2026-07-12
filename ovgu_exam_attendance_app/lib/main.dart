import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/import/domain/participant.dart';
import 'features/confirmation/presentation/screens/confirmation_screen.dart';
import 'features/export/presentation/screens/export_screen.dart';
import 'features/import/presentation/screens/import_screen.dart';
import 'features/participants/presentation/screens/participant_list_screen.dart';
import 'features/scan/presentation/screens/scan_screen.dart';
import 'features/search/presentation/screens/manual_search_screen.dart';

void main() {
  runApp(const OvguAttendanceApp());
}

class AppRoutes {
  static const import_ = '/';
  static const scan = '/scan';
  static const participantList = '/participants';
  static const manualSearch = '/manual-search';
  static const confirmation = '/confirmation';
  static const export_ = '/export';
}

class OvguAttendanceApp extends StatelessWidget {
  const OvguAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OVGU Exam Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      initialRoute: AppRoutes.import_,
      routes: {
        AppRoutes.import_: (_) => ImportScreen(),
        AppRoutes.scan: (_) => ScanScreen(),
        AppRoutes.participantList: (_) => ParticipantListScreen(),
        AppRoutes.manualSearch: (_) => ManualSearchScreen(),
        AppRoutes.export_: (_) => ExportScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.confirmation) {
          final participant = settings.arguments as Participant;
          return MaterialPageRoute(
            builder: (_) => ConfirmationScreen(participant: participant),
          );
        }
        return null;
      },
    );
  }
}
