import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black,
        primary: Colors.black,
        secondary: Colors.black87,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      timePickerTheme: _timePickerTheme(Brightness.light),
      datePickerTheme: _datePickerTheme(Brightness.light),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        primary: Colors.white,
        onPrimary: Colors.black, // Explicitly black on white primary
        secondary: Colors.white70,
        surface: const Color(0xFF1E1E1E), // Slightly lighter for contrast
        onSurface: Colors.white,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white70;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white38;
          return Colors.white12;
        }),
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(
        color: Colors.white,
        selectedColor: Colors.black,
        fillColor: Colors.white,
        borderColor: Colors.white.withValues(alpha: 0.1),
        selectedBorderColor: Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      timePickerTheme: _timePickerTheme(Brightness.dark),
      datePickerTheme: _datePickerTheme(Brightness.dark),
    );
  }

  static TimePickerThemeData _timePickerTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final onPrimaryColor = isDark ? Colors.black : Colors.white;
    final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final surfaceColor = isDark
        ? const Color(0xFF383838)
        : Colors.grey.shade100;

    return TimePickerThemeData(
      backgroundColor: backgroundColor,
      hourMinuteShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      dayPeriodBorderSide: BorderSide(
        color: primaryColor.withValues(alpha: 0.1),
      ),
      dayPeriodShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      dayPeriodColor: WidgetStateColor.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? primaryColor
            : Colors.transparent;
      }),
      dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? onPrimaryColor
            : primaryColor;
      }),
      hourMinuteColor: WidgetStateColor.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? primaryColor
            : surfaceColor;
      }),
      hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? onPrimaryColor
            : primaryColor;
      }),
      dialHandColor: primaryColor,
      dialBackgroundColor: surfaceColor,
      dialTextColor: WidgetStateColor.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? onPrimaryColor
            : primaryColor;
      }),
      entryModeIconColor: primaryColor,
      helpTextStyle: TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.bold,
      ),
      cancelButtonStyle: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(primaryColor),
      ),
      confirmButtonStyle: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(primaryColor),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static DatePickerThemeData _datePickerTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final onPrimaryColor = isDark ? Colors.black : Colors.white;
    final backgroundColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return DatePickerThemeData(
      backgroundColor: backgroundColor,
      headerBackgroundColor: isDark ? const Color(0xFF1E1E1E) : primaryColor,
      headerForegroundColor: isDark ? Colors.white : onPrimaryColor,
      surfaceTintColor: Colors.transparent,
      todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
      todayForegroundColor: WidgetStateProperty.all(primaryColor),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return onPrimaryColor;
        }
        if (states.contains(WidgetState.disabled)) {
          return isDark ? Colors.white24 : Colors.grey;
        }
        return primaryColor;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return onPrimaryColor;
        }
        return primaryColor;
      }),
      cancelButtonStyle: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(primaryColor),
      ),
      confirmButtonStyle: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(primaryColor),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
