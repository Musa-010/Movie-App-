import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_text_styles.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: AppColors.primaryColor,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.primaryColor,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      foregroundColor: Colors.black,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      labelStyle: AppTextStyles.labelStyle,
      unselectedLabelStyle: AppTextStyles.unselectedLabelStyle,
      indicatorSize: TabBarIndicatorSize.label,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
    ),
    iconTheme: const IconThemeData(
      color: Colors.black87,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.black),
    ),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: AppColors.primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.primaryColor,
      surface: Color(0xFF1E1E1E),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey.shade500,
      labelStyle: AppTextStyles.labelStyle,
      unselectedLabelStyle: AppTextStyles.unselectedLabelStyle,
      indicatorSize: TabBarIndicatorSize.label,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 2,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white70,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white),
    ),
  );
}
