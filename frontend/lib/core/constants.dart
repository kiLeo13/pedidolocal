import 'package:flutter/material.dart';

abstract final class AppConstants {
  static const String appName = 'Pedido Local';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const Duration apiTimeout = Duration(seconds: 30);

  static const Color primaryGreen = Color(0xFF5FD138);
  static const Color darkGreen = Color(0xFF1E650D);
  static const Color mutedGreen = Color(0xFFEAF7E4);
  static const Color ink = Color(0xFF222222);
  static const Color mutedInk = Color(0xFF727272);
  static const Color pageGray = Color(0xFFF6F6F6);
  static const Color line = Color(0xFFE7E7E7);
  static const Color warning = Color(0xFFF6AE2D);
  static const Color danger = Color(0xFFD64545);
  static const Color white = Color(0xFFFFFFFF);

  static const Color lightGreen = mutedGreen;
  static const Color darkText = ink;
  static const Color secondaryText = mutedInk;
  static const Color errorRed = danger;
  static const Color warningOrange = warning;
  static const Color dividerColor = line;

  static const double radiusSmall = 6;
  static const double radiusMedium = 8;
  static const double radiusLarge = 16;

  static const double cardRadius = radiusMedium;
  static const double buttonRadius = radiusMedium;
  static const double chipRadius = radiusMedium;
  static const double inputRadius = radiusMedium;
  static const double imageRadius = radiusMedium;

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  static const double tinyPadding = spacingXs;
  static const double smallPadding = spacingSm;
  static const double defaultPadding = spacingMd;
  static const double largePadding = spacingLg;
  static const double extraLargePadding = spacingXl;

  static const double bottomNavHeight = 64;
  static const double bottomNavBarHeight = bottomNavHeight;
  static const double productImageHeight = 210;

  static const double iconSizeSmall = 20;
  static const double iconSizeMedium = 24;
  static const double iconSizeLarge = 32;

  static const String tokenStorageKey = 'auth_access_token';
  static const int passwordMinLength = 8;
  static const int phoneMinLength = 8;
}
