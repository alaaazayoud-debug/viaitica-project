import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // ✅ Splash Gradient (Premium Midnight)
  static const splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.midnightGradient,
  );

  // ✅ Splash Title Style
  static const splashTitleTextStyle = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    fontFamily: 'Tajawal',
    letterSpacing: -1,
  );

  // ═══ Text Styles الموحدة ═══
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    fontFamily: 'Tajawal',
    color: AppColors.text,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    fontFamily: 'Tajawal',
    color: AppColors.text,
    letterSpacing: -0.5,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    fontFamily: 'Tajawal',
    color: AppColors.text,
    letterSpacing: -0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    fontFamily: 'Tajawal',
    color: AppColors.text,
    letterSpacing: -0.5,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    fontFamily: 'Tajawal',
    color: AppColors.text,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFamily: 'Tajawal',
    color: AppColors.textLight,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    fontFamily: 'Tajawal',
    color: AppColors.textLight,
  );

  static const TextStyle labelBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    fontFamily: 'Tajawal',
    color: AppColors.text,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    fontFamily: 'Tajawal',
    color: AppColors.textLight,
  );

  // ═══ SnackBar Themes ═══
  static SnackBarThemeData get successSnackBar => SnackBarThemeData(
    backgroundColor: AppColors.emerald,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static SnackBarThemeData get errorSnackBar => SnackBarThemeData(
    backgroundColor: AppColors.danger,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  // ✅ ThemeData الموحد لكل التطبيق (Elite)
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'Tajawal',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.white,
          onPrimary: Colors.white,
          error: AppColors.danger,
        ),
        // ═══ SnackBar ═══
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentTextStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.text,
          elevation: 0,
          centerTitle: false, // More modern
          titleTextStyle: TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'Tajawal',
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.grey),
          ),
          color: AppColors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: AppColors.primary.withAlpha(77),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.danger, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.danger, width: 2),
          ),
          contentPadding: const EdgeInsets.all(20),
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
          labelStyle: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
          errorStyle: const TextStyle(
            color: AppColors.danger,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        // ═══ Divider ═══
        dividerTheme: DividerThemeData(
          color: AppColors.grey.withValues(alpha: 0.5),
          space: 1,
        ),
        // ═══ Bottom Sheet ═══
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
      );
}
