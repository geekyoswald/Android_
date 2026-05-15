import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Color Palette
  static const Color _primaryBlue = Color(0xFF1E3A8A);
  static const Color _accentTeal = Color(0xFF14B8A6);
  static const Color _successGreen = Color(0xFF16A34A);
  static const Color _warningOrange = Color(0xFFF97316);
  static const Color _errorRed = Color(0xFFDC2626);
  static const Color _lightGrey = Color(0xFFF3F4F6);
  static const Color _darkGrey = Color(0xFF1F2937);
  static const Color _surfaceGrey = Color(0xFFFFFFFF);

  // Status Colors
  static const Color statusNotMarked = Color(0xFF9CA3AF);
  static const Color statusPresent = _successGreen;
  static const Color statusExcused = _warningOrange;
  static const Color statusMarked = _primaryBlue;

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: _primaryBlue,
        onPrimary: Colors.white,
        secondary: _accentTeal,
        onSecondary: Colors.white,
        error: _errorRed,
        onError: Colors.white,
        surface: _surfaceGrey,
        onSurface: _darkGrey,
        surfaceContainerHighest: _lightGrey,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryBlue,
          side: const BorderSide(color: _primaryBlue, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: _darkGrey,
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: _darkGrey,
        ),
        titleLarge: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _darkGrey,
        ),
        titleMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _darkGrey,
        ),
        titleSmall: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _darkGrey,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _darkGrey,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _darkGrey,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _darkGrey,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _lightGrey,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryBlue, width: 2),
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _darkGrey,
        ),
      ),
      scaffoldBackgroundColor: _surfaceGrey,
    );
  }

  // Shared style helper methods
  static Widget statusChip({
    required int status,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
  }) {
    final Map<int, Map<String, dynamic>> statusMap = {
      0: {
        'label': 'Not marked',
        'color': statusNotMarked,
        'textColor': Colors.white,
      },
      1: {
        'label': 'Present',
        'color': statusPresent,
        'textColor': Colors.white,
      },
      2: {
        'label': 'Excused',
        'color': statusExcused,
        'textColor': Colors.white,
      },
      3: {
        'label': 'Marked',
        'color': statusMarked,
        'textColor': Colors.white,
      },
    };

    final statusData = statusMap[status] ?? statusMap[0]!;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: statusData['color']! as Color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusData['label']! as String,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: statusData['textColor']! as Color,
        ),
      ),
    );
  }

  static TextStyle successTextStyle({double fontSize = 14}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: statusPresent,
    );
  }

  static TextStyle errorTextStyle({double fontSize = 14}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: _errorRed,
    );
  }

  static TextStyle warningTextStyle({double fontSize = 14}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: _warningOrange,
    );
  }

  static const EdgeInsets screenPadding = EdgeInsets.all(20);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 16,
  );

  static const SizedBox verticalSpacingSmall = SizedBox(height: 8);
  static const SizedBox verticalSpacingMedium = SizedBox(height: 16);
  static const SizedBox verticalSpacingLarge = SizedBox(height: 24);

  static const SizedBox horizontalSpacingSmall = SizedBox(width: 8);
  static const SizedBox horizontalSpacingMedium = SizedBox(width: 16);
  static const SizedBox horizontalSpacingLarge = SizedBox(width: 24);

  static const BorderRadius borderRadiusSmall = BorderRadius.all(
    Radius.circular(6),
  );
  static const BorderRadius borderRadiusMedium = BorderRadius.all(
    Radius.circular(8),
  );
  static const BorderRadius borderRadiusLarge = BorderRadius.all(
    Radius.circular(12),
  );
}
