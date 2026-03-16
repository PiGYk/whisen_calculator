import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'equipment_model.dart';

/// Результат підбору — кілька варіантів LG + опційний AUX-аналог
class SelectionResult {
  /// Варіанти LG (до 3, з різних серій)
  final List<SelectionOption> primaryOptions;

  /// Варіант AUX (якщо є в каталозі)
  final SelectionOption? analog;

  const SelectionResult({this.primaryOptions = const [], this.analog});

  /// Перший LG-варіант (для сумісності з _ComparisonHint)
  SelectionOption? get primary => primaryOptions.isNotEmpty ? primaryOptions.first : null;

  bool get isEmpty => primaryOptions.isEmpty && analog == null;

  List<SelectionOption> get options => [...primaryOptions, ?analog];
}

class SelectionOption {
  final String brand;
  final EquipmentModel model;
  final String matchReason;
  final double oversize;

  const SelectionOption({
    required this.brand,
    required this.model,
    required this.matchReason,
    required this.oversize,
  });

  /// Колір: для LG залежить від tier, для AUX — фіксований
  Color get color {
    if (brand.toUpperCase() == 'AUX') return AppColors.tierOptimal;
    switch (model.tier) {
      case 'premium':  return AppColors.accentDark;    // малиновий — LG premium/brand
      case 'optimal':  return AppColors.tierPremium;   // золотий — оптимальний вибір
      case 'standard': return AppColors.tierStandard;  // зелений — базовий
      default:         return AppColors.accentDark;
    }
  }

  String get brandLabel => brand;
}
