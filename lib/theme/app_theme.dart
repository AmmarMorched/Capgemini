  import 'package:flutter/material.dart';

class AppTheme {
  // Color palette that reflects modern technology and professionalism
  static const Color primaryColor = Color(0xFF2196F3);  // Deep blue
  static const Color secondaryColor = Color(0xFF03A9F4);  // Lighter blue
  static const Color accentColor = Color(0xFF00BCD4);    // Cyan
  static const Color warningColor = Color(0xFFFF9800);   // Orange
  static const Color errorColor = Color(0xFFE53935);     // Red
  static const Color successColor = Color(0xFF4CAF50);   // Green
  static const Color backgroundColor = Color(0xFF1A1F2E); // Dark background
  static const Color surfaceColor = Color(0xFF2A2E3D);   // Slightly lighter surface
  static const Color cardColor = Color(0xFF33384C);      // Card background
  static const Color textColor = Color(0xFFE0E0E0);      // Light text
  static const Color hintColor = Color(0xFF757575);      // Medium text
  static const Color disabledColor = Color(0xFF424242);  // Disabled elements

  static ThemeData get theme {
    return ThemeData(
      // Base settings
      useMaterial3: true,
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        error: errorColor,
        brightness: Brightness.dark,
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textColor,
          height: 1.3,
          ),
        ),

        // Card styling
        cardTheme: CardTheme(
          color: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: const Color(0xFF00C2FF).withOpacity(0.2),
              width: 1,
            ),
          ),
          elevation: 4,
          margin: const EdgeInsets.all(8),
        ),

        // Button styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C2FF),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // Slider/Gauge styling
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFF00C2FF),
          inactiveTrackColor: const Color(0xFF00C2FF).withOpacity(0.3),
          thumbColor: const Color(0xFF00C2FF),
          trackHeight: 4,
        ),

        // Icons and dividers
        iconTheme: const IconThemeData(
          color: Colors.white70,
          size: 24,
        ),
        dividerColor: Colors.white12,
      );
    }
  }
