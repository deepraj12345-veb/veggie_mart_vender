import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Standard & Compact Typography Rules
  
  // Headings
  static TextStyle heading1 = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2 = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle heading3 = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Text (Standard Compact Size: 13px - 14px)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Button & Badge Text
  static TextStyle buttonText = GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle badgeText = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  static TextStyle amountText = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
}
