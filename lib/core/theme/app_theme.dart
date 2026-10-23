import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.daun,
    onPrimary: Colors.white,
    primaryContainer: AppColors.daunMuda,
    onPrimaryContainer: AppColors.daunTua,
    secondary: AppColors.biruTruk,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.biruTrukMuda,
    onSecondaryContainer: AppColors.tinta,
    error: AppColors.bata,
    onError: Colors.white,
    errorContainer: AppColors.bataMuda,
    onErrorContainer: AppColors.tinta,
    surface: AppColors.permukaan,
    onSurface: AppColors.tinta,
    onSurfaceVariant: AppColors.abuTinta,
    outline: AppColors.garis,
    surfaceTint: Colors.transparent,
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.kertas,
      fontFamily: 'Barlow',
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.daunTua,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.daun,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.permukaan,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.garis, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.garis, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.daun, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.bata, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.bata, width: 2),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.permukaan,
        indicatorColor: AppColors.daunMuda,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.daun);
          }
          return const IconThemeData(color: AppColors.abuTinta);
        }),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.garis,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
