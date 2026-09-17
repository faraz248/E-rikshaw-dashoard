import 'package:flutter/material.dart';

class AppColors {
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color emerald600 = Color(0xFF0F766E);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color red500 = Color(0xFFEF4444);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color cardBorder = Color(0xFFE2E8F0);
}

class AppText {
  static const TextStyle heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.slate900,
    letterSpacing: -0.3,
  );
  static const TextStyle subHeading = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.slate800,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.slate500,
  );
}
