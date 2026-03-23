import 'package:flutter/material.dart';

/// Shared radii, shadows, and motion for a consistent premium feel.
abstract final class AppDimens {
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;

  static const List<BoxShadow> shadowSoft = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> shadowCard = [
    BoxShadow(color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> shadowElevated = [
    BoxShadow(color: Color(0x12000000), blurRadius: 28, offset: Offset(0, 14)),
  ];

  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 320);
}
