import 'package:flutter/material.dart';

class ResponsiveLayout {
  static EdgeInsets getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 900) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 16);
    } else if (width >= 600) {
      return const EdgeInsets.symmetric(horizontal: 28, vertical: 14);
    } else {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
  }

  static double getSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 900) {
      return 22;
    } else if (width >= 600) {
      return 18;
    } else {
      return 14;
    }
  }

  static double getFontSize(BuildContext context, {required double base}) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 900) {
      return base + 4;
    } else if (width >= 600) {
      return base + 2;
    } else {
      return base;
    }
  }
}
