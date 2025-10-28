import 'package:flutter/material.dart';

class AppColors {
  // Robinhood-inspired color palette
  static const Color primaryGreen = Color(0xFF00C853); // Robinhood green
  static const Color darkGray = Color(0xFF2C2C2E);
  static const Color background = Color(0xFF000000);
  static const Color cardBackground = Color(0xFF1C1C1E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color profitGreen = Color(0xFF00C853);
  static const Color lossRed = Color(0xFFFF3B30);
  static const Color borderGray = Color(0xFF3A3A3C);
  
  // Light theme colors
  static const Color lightBackground = Color(0xFFE0F0FF);
  static const Color lightGreen = Color(0xFFC8F0C8);
}

class AppTextStyles {
  static const TextStyle largeTitle = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}

