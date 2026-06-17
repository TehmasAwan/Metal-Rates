import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../hex_color.dart';
import '../../viewmodels/settings_viewmodel.dart';

class AppColors {
  static bool get isDark {
    try {
      return Get.find<SettingsViewModel>().isDarkMode.value;
    } catch (_) {
      return Get.isDarkMode;
    }
  }

  // Hex Constants (Light / Dark)
  static final Color bgDark = HexColor('#000000'); // Perfect OLED Black
  static final Color bgLight = HexColor('#F8FAFC');

  static final Color cardBgDark = HexColor('#121212'); // Sleek Charcoal Card
  static final Color cardBgLight = HexColor('#FFFFFF');

  static final Color borderDark = HexColor('#262626'); // Elegant Border for Black theme
  static final Color borderLight = HexColor('#E2E8F0');

  static final Color textPrimaryDark = HexColor('#F8FAFC');
  static final Color textPrimaryLight = HexColor('#0F172A');

  static final Color textSecondaryDark = HexColor('#94A3B8');
  static final Color textSecondaryLight = HexColor('#475569');

  static final Color textMutedDark = HexColor('#64748B');
  static final Color textMutedLight = HexColor('#94A3B8');

  // Dynamic Getters based on theme mode
  static Color get background => isDark ? bgDark : bgLight;
  static Color get cardBackground => isDark ? cardBgDark : cardBgLight;
  static Color get cardBorder => isDark ? borderDark : borderLight;

  // Brand Accent Colors
  static final Color primary = HexColor('#C5A059'); // Muted Gold Accent
  static final Color accent = HexColor('#38BDF8');  // Teal/Sky Blue Accent

  // Metal Styling Colors
  static final Color gold = HexColor('#FFD700');
  static final Color goldDark = HexColor('#B8860B');
  static final Color goldGlow = HexColor('#F59E0B');

  static final Color silver = HexColor('#E2E8F0');
  static final Color silverDark = HexColor('#94A3B8');
  static final Color silverGlow = HexColor('#CBD5E1');

  static final Color platinum = HexColor('#F8FAFC');
  static final Color platinumDark = HexColor('#64748B');
  static final Color platinumGlow = HexColor('#E2E8F0');

  // Market Direction Colors
  static final Color bullish = HexColor('#10B981'); // Emerald Green
  static final Color bearish = HexColor('#EF4444'); // Rose Red

  // Dynamic Text Colors
  static Color get textPrimary => isDark ? textPrimaryDark : textPrimaryLight;
  static Color get textSecondary => isDark ? textSecondaryDark : textSecondaryLight;
  static Color get textMuted => isDark ? textMutedDark : textMutedLight;

  // Premium Gradients
  static Gradient get goldGradient => LinearGradient(
    colors: [HexColor('#FFE082'), HexColor('#FFB300')],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient get silverGradient => LinearGradient(
    colors: [HexColor('#F1F5F9'), HexColor('#94A3B8')],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient get platinumGradient => LinearGradient(
    colors: [HexColor('#FFFFFF'), HexColor('#CBD5E1')],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient get cardGradient => LinearGradient(
    colors: isDark 
      ? [HexColor('#1E1E1E').withOpacity(0.4), HexColor('#121212').withOpacity(0.8)]
      : [HexColor('#FFFFFF'), HexColor('#F1F5F9')],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient get bgGradient => LinearGradient(
    colors: isDark 
      ? [HexColor('#121212'), HexColor('#000000')]
      : [HexColor('#F8FAFC'), HexColor('#F1F5F9')],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
