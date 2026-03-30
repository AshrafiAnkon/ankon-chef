import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFFA63300);
  static const onPrimary = Color(0xFFFFEFEB);
  static const primaryContainer = Color(0xFFFF7949);
  static const onPrimaryContainer = Color(0xFF451000);
  static const primaryDim = Color(0xFF922C00);

  // Secondary
  static const secondary = Color(0xFF006B1B);
  static const onSecondary = Color(0xFFD1FFC8);
  static const secondaryContainer = Color(0xFF91F78E);
  static const onSecondaryContainer = Color(0xFF005E17);
  static const secondaryDim = Color(0xFF005D16);

  // Tertiary
  static const tertiary = Color(0xFF9B3E20);
  static const onTertiary = Color(0xFFFFEFEB);
  static const tertiaryContainer = Color(0xFFFF9472);
  static const onTertiaryContainer = Color(0xFF5E1700);

  // Neutral / Surface
  static const surface = Color(0xFFF7F7F3);
  static const surfaceBright = Color(0xFFF7F7F3);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF1F1ED);
  static const surfaceContainer = Color(0xFFE8E9E4);
  static const surfaceContainerHigh = Color(0xFFE2E3DE);
  static const surfaceContainerHighest = Color(0xFFDCDDD9);
  
  // Background
  static const background = Color(0xFFF7F7F3);
  static const onBackground = Color(0xFF2D2F2D);
  static const onSurface = Color(0xFF2D2F2D);
  static const onSurfaceVariant = Color(0xFF5A5C59);
  
  // Outline
  static const outline = Color(0xFF767774);
  static const outlineVariant = Color(0xFFADADAA);

  // Error
  static const error = Color(0xFFB31B25);
  static const onError = Color(0xFFFFEFEE);
  static const errorContainer = Color(0xFFFB5151);
  static const onErrorContainer = Color(0xFF570008);

  // Keep old names mapped to some equivalents so we don't break existing codebase immediately
  static const border = outlineVariant;
  static const textPrimary = onBackground;
  static const textSecondary = onSurfaceVariant;
  static const textTertiary = outline;
  
  static const primaryLight = primaryContainer;
  static const primaryDark = primaryDim;
  static const secondaryLight = secondaryContainer;
  static const secondaryDark = secondaryDim;
  
  static const accent = tertiary;
  static const accentLight = tertiaryContainer;
  static const accentDark = tertiaryContainer;

  static const success = secondary;
  static const warning = tertiary;
  
  static const backgroundDark = Color(0xFF1E1E1E);
  static const surfaceDark = Color(0xFF2D2F2D);
  static const surfaceVariantDark = Color(0xFF5A5C59);
  static const borderDark = outline;
  static const textWhite = Colors.white;

  static const shadowLight = Color(0x1A000000);
  static const shadowMedium = Color(0x33000000);
  static const shadowDark = Color(0x4D000000);
}
