import 'package:flutter/material.dart';

/// App color palette derived directly from the official Ramar's Academy brand logo:
/// - Academic Deep Navy (#0B2545): Lower gear & NEET/JEE Physics emblem
/// - Ramar Crimson (#C23025): "RAMAR'S ACADEMY" headline
/// - Caduceus Gold (#D4AF37): Medical / Hermes staff wings & serpents
/// - Doctor Blue (#2563EB): Medical silhouette
/// - Crisp Slate & Clean White surfaces
class AppColors {
  AppColors._();

  // Primary Brand Colors (Academic Navy)
  static const Color primary = Color(0xFF0B2545);
  static const Color primaryDark = Color(0xFF061528);
  static const Color primaryLight = Color(0xFFE2EAF4);
  static const Color primarySubtle = Color(0xFFF1F5F9);

  // Secondary Accent Colors (Ramar Crimson Red)
  static const Color secondary = Color(0xFFC23025);
  static const Color secondaryDark = Color(0xFF991B1B);
  static const Color secondaryLight = Color(0xFFFEE2E2);
  static const Color secondarySubtle = Color(0xFFFEF2F2);

  // Brand Distinctive Accents
  static const Color brandGold = Color(0xFFD4AF37); // Caduceus Gold
  static const Color brandGoldDark = Color(0xFFB45309);
  static const Color brandGoldLight = Color(0xFFFEF3C7);

  static const Color doctorBlue = Color(0xFF2563EB); // Medical Blue
  static const Color doctorBlueLight = Color(0xFFDBEAFE);

  // Neutral Palette
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textWhite = Colors.white;

  // Background & Surface Tokens
  static const Color background = Color(0xFFF8FAFC); // Clean Crisp White
  static const Color backgroundWarm = Color(0xFFF8FAFC); // Clean White/Slate (replaces legacy peach)
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color cardBorderFocus = Color(0xFF93C5FD);

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF2563EB);

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B2545), Color(0xFF174276)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
  );

  static const LinearGradient crimsonGradient = secondaryGradient;

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9), Color(0xFFE2EAF4)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFFAFAFA)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B2545), Color(0xFF061528)],
  );

  // Soft Ambient Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF0B2545).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: const Color(0xFF0B2545).withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.28),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> secondaryShadow = [
    BoxShadow(
      color: secondary.withValues(alpha: 0.28),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}
