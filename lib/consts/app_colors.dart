import 'package:flutter/material.dart';

class AppColors {
  // Primary Green Theme Palette
  static const Color primary = Color(0xFF10B981);      // Emerald Green
  static const Color primaryDark = Color(0xFF047857);  // Deep Emerald
  static const Color primaryLight = Color(0xFFECFDF5); // Mint Tint
  static const Color secondary = Color(0xFF059669);    // Medium Emerald

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC);   // Clean Light Slate
  static const Color surface = Color(0xFFFFFFFF);      // Pure White Card Surface
  static const Color border = Color(0xFFE2E8F0);       // Subtle Gray Border
  static const Color divider = Color(0xFFF1F5F9);      // Light Divider

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A);  // Dark Slate / Almost Black
  static const Color textSecondary = Color(0xFF64748B);// Slate Gray for subtitles
  static const Color textLight = Color(0xFF94A3B8);    // Light Gray for hints & disabled
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Status & Alert Colors (Standardized across app)
  static const Color error = Color(0xFFEF4444);        // Red for Reject / Out of Stock
  static const Color errorLight = Color(0xFFFEF2F2);   // Light Red Badge
  static const Color warning = Color(0xFFF59E0B);      // Orange for Pending / Timer
  static const Color warningLight = Color(0xFFFFFBEB); // Light Orange Badge
  static const Color success = Color(0xFF10B981);      // Green for Ready / In Stock
  static const Color successLight = Color(0xFFECFDF5); // Light Green Badge
  static const Color info = Color(0xFF3B82F6);         // Blue for Call / Info
  static const Color infoLight = Color(0xFFEFF6FF);    // Light Blue Badge
}
