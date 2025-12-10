import 'package:flutter/material.dart';

class AppStyles {
  // Shadow for cards
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      );

  // Shadow for floating buttons or colored items
  static BoxShadow get buttonShadow => BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 20,
        offset: const Offset(0, 6),
      );

  // Shadow for navigation bar container
  static BoxShadow get navShadow => BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 30,
        offset: const Offset(0, -4),
      );
}
