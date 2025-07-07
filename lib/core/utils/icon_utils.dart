import 'package:flutter/material.dart';

/// Utility class for icon-related operations
class IconUtils {
  const IconUtils._();

  /// Converts a Material Icons string name to IconData
  static IconData getIconData(String iconName) {
    return _materialIconsMap[iconName] ?? Icons.error;
  }

  // Map of Material Icons names to their IconData
  static const Map<String, IconData> _materialIconsMap = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'lightbulb': Icons.lightbulb,
    'sports_esports': Icons.sports_esports,
    'shopping_cart': Icons.shopping_cart,
    'local_hospital': Icons.local_hospital,
    'school': Icons.school,
    'flight': Icons.flight,
    'category': Icons.category,
  };
}
