import 'package:flutter/material.dart';

// Modern Trending Color Palette - Nature Inspired with Vibrant Accents
const Color kPrimaryGreen = Color(0xFF10B981); // Emerald Green
const Color kPrimaryGreenDark = Color(0xFF059669); // Darker Green
const Color kPrimaryGreenLight = Color(0xFF34D399); // Light Green
const Color kSecondaryTeal = Color(0xFF14B8A6); // Teal
const Color kAccentOrange = Color(0xFFF59E0B); // Warm Amber/Orange
const Color kAccentOrangeDark = Color(0xFFD97706); // Dark Orange
const Color kDark = Color(0xFF1F2937); // Modern Dark Gray
const Color kDarkLight = Color(0xFF374151); // Lighter Dark Gray
const Color kBackground = Color(0xFFF9FAFB); // Soft Gray Background
const Color kSurface = Colors.white;
const Color kError = Color(0xFFEF4444); // Modern Red
const Color kSuccess = Color(0xFF10B981); // Green for success

// Gradient Colors
const LinearGradient kPrimaryGradient = LinearGradient(
  colors: [kPrimaryGreen, kSecondaryTeal],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kAccentGradient = LinearGradient(
  colors: [kAccentOrange, Color(0xFFF97316)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kCardGradient = LinearGradient(
  colors: [Colors.white, Color(0xFFF0FDF4)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  primaryColor: kPrimaryGreen,
  scaffoldBackgroundColor:
      Colors.transparent, // Changed to transparent for gradient
  colorScheme: const ColorScheme.light(
    primary: kPrimaryGreen,
    primaryContainer: kPrimaryGreenLight,
    secondary: kSecondaryTeal,
    secondaryContainer: Color(0xFF5EEAD4),
    tertiary: kAccentOrange,
    surface: kSurface,
    surfaceContainerHighest: Color(0xFFF3F4F6),
    error: kError,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: kDark,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: kDark,
    elevation: 0,
    centerTitle: true,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black.withOpacity(0.05),
    titleTextStyle: const TextStyle(
      color: kDark,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    iconTheme: const IconThemeData(color: kDark),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return kPrimaryGreen.withOpacity(0.5);
          }
          return kPrimaryGreen;
        },
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kPrimaryGreen,
      side: const BorderSide(color: kPrimaryGreen, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPrimaryGreen, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kError, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kError, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    labelStyle: const TextStyle(color: kDarkLight),
    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shadowColor: Colors.black.withOpacity(0.05),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFF3F4F6), width: 1),
    ),
    margin: EdgeInsets.zero,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: kPrimaryGreen,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFF3F4F6),
    selectedColor: kPrimaryGreen,
    labelStyle: const TextStyle(color: kDark),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: kDark,
      fontWeight: FontWeight.w800,
      fontSize: 32,
      letterSpacing: -1,
    ),
    displayMedium: TextStyle(
      color: kDark,
      fontWeight: FontWeight.w700,
      fontSize: 28,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      color: kDark,
      fontWeight: FontWeight.w700,
      fontSize: 24,
    ),
    headlineLarge: TextStyle(
      color: kDark,
      fontWeight: FontWeight.w700,
      fontSize: 22,
    ),
    headlineMedium: TextStyle(
      color: kDark,
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    titleLarge: TextStyle(
      color: kDark,
      fontWeight: FontWeight.w700,
      fontSize: 18,
    ),
    titleMedium: TextStyle(
      color: kDark,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    bodyLarge: TextStyle(
      color: kDark,
      fontSize: 16,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      color: kDark,
      fontSize: 14,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      color: kDarkLight,
      fontSize: 12,
    ),
    labelLarge: TextStyle(
      color: kDark,
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
  ),
  iconTheme: const IconThemeData(
    color: kDark,
    size: 24,
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE5E7EB),
    thickness: 1,
    space: 1,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: kPrimaryGreen,
  colorScheme: const ColorScheme.dark(
    primary: kPrimaryGreen,
    secondary: kSecondaryTeal,
    tertiary: kAccentOrange,
    surface: Color(0xFF111827),
    error: kError,
  ),
  scaffoldBackgroundColor: Colors.transparent,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF020617),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF111827),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kPrimaryGreen,
    foregroundColor: Colors.black,
  ),
);
