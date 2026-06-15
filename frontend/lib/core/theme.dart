import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppConstants.primaryGreen,
      primary: AppConstants.primaryGreen,
      secondary: AppConstants.darkGreen,
      surface: AppConstants.white,
      error: AppConstants.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppConstants.pageGray,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.white,
        foregroundColor: AppConstants.ink,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppConstants.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.darkGreen,
          foregroundColor: AppConstants.white,
          disabledBackgroundColor: AppConstants.line,
          disabledForegroundColor: AppConstants.mutedInk,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.darkGreen,
          side: const BorderSide(color: AppConstants.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: _inputBorder(AppConstants.line),
        enabledBorder: _inputBorder(AppConstants.line),
        focusedBorder: _inputBorder(AppConstants.primaryGreen, width: 1.5),
        errorBorder: _inputBorder(AppConstants.danger),
        focusedErrorBorder: _inputBorder(AppConstants.danger, width: 1.5),
        hintStyle: const TextStyle(color: AppConstants.mutedInk),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          side: const BorderSide(color: AppConstants.line),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppConstants.white,
        indicatorColor: AppConstants.mutedGreen,
        height: AppConstants.bottomNavHeight,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppConstants.darkGreen
                : AppConstants.mutedInk,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppConstants.ink,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          color: AppConstants.ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: AppConstants.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: AppConstants.ink,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        bodyLarge: TextStyle(
          color: AppConstants.ink,
          fontSize: 16,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          color: AppConstants.ink,
          fontSize: 14,
          letterSpacing: 0,
        ),
        bodySmall: TextStyle(
          color: AppConstants.mutedInk,
          fontSize: 12,
          letterSpacing: 0,
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
