import '../models/calculation_result.dart';

class HvacCalculatorService {
  static CalculationResult calculate({
    required String objectType,
    required double area,
    required double height,
    required int people,
    required String glazing,
    required String insulation,
    required bool sunnySide,
    required String climate,
    required String mode,
    required double tariff,
    required double hoursPerDay,
    required int daysPerMonth,
  }) {
    // Base cooling factor by object type
    final double baseCoolingFactor = switch (objectType) {
      'Квартира' => 0.10,
      'Будинок'  => 0.11,
      'Офіс'     => 0.12,
      'Магазин'  => 0.14,
      _          => 0.10,
    };

    final double heightFactor = height / 2.7;

    final double glazingFactor = switch (glazing) {
      'Низьке'  => 0.95,
      'Середнє' => 1.0,
      'Високе'  => 1.15,
      _         => 1.0,
    };

    final (double insulCooling, double insulHeating) = switch (insulation) {
      'Слабке'  => (1.10, 1.20),
      'Середнє' => (1.0,  1.0),
      'Хороше'  => (0.92, 0.85),
      _         => (1.0,  1.0),
    };

    final double solarFactor = sunnySide ? 1.10 : 1.0;

    final double climateHeating = switch (climate) {
      'Теплий'  => 0.90,
      'Помірний' => 1.0,
      'Холодний' => 1.15,
      _          => 1.0,
    };

    final double peopleGain = people * 0.12;

    double coolingKw = area *
        baseCoolingFactor *
        heightFactor *
        glazingFactor *
        insulCooling *
        solarFactor +
        peopleGain;

    final double baseHeatingFactor = switch (objectType) {
      'Будинок' => 0.10,
      'Офіс'    => 0.085,
      'Магазин' => 0.095,
      _         => 0.09,
    };

    double heatingKw = area *
        baseHeatingFactor *
        heightFactor *
        insulHeating *
        climateHeating;

    // Adjust for selected mode
    if (mode == 'Охолодження') {
      heatingKw = 0;
    } else if (mode == 'Опалення') {
      coolingKw = 0;
    }

    final double referenceKw = coolingKw > 0 ? coolingKw : heatingKw;
    final double monthlyKwh = referenceKw * hoursPerDay * daysPerMonth * 0.75;
    final double monthlyCost = monthlyKwh * tariff;

    final String recommendation = switch (referenceKw) {
      <= 2.7 => 'Рекомендовано клас 2.5–2.7 кВт',
      <= 3.6 => 'Рекомендовано клас 3.5 кВт',
      <= 5.4 => 'Рекомендовано клас 5.0–5.2 кВт',
      <= 7.2 => 'Рекомендовано клас 7.0 кВт',
      _      => 'Потрібен потужний варіант або кілька внутрішніх блоків',
    };

    final String summary = switch (referenceKw) {
      <= 3.5 => 'Невелике або помірне навантаження.',
      <= 5.5 => 'Середнє навантаження. Варто дивитися моделі із запасом.',
      _      => 'Високе навантаження. Бажано уважно перевірити скління, утеплення та конфігурацію системи.',
    };

    return CalculationResult(
      coolingKw: coolingKw,
      heatingKw: heatingKw,
      monthlyKwh: monthlyKwh,
      monthlyCost: monthlyCost,
      recommendation: recommendation,
      summary: summary,
    );
  }
}
