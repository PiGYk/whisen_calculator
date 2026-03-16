import 'dart:convert';

class SavedCalculation {
  final String id;
  final String projectName;
  final String objectType;
  final double area;
  final double height;
  final int people;
  final String glazing;
  final String insulation;
  final bool sunnySide;
  final String climate;
  final String mode;
  final double tariff;
  final double hoursPerDay;
  final int daysPerMonth;
  final double coolingKw;
  final double heatingKw;
  final double monthlyKwh;
  final double monthlyCost;
  final String recommendation;
  final String summary;
  final DateTime createdAt;

  const SavedCalculation({
    required this.id,
    required this.projectName,
    required this.objectType,
    required this.area,
    required this.height,
    required this.people,
    required this.glazing,
    required this.insulation,
    required this.sunnySide,
    required this.climate,
    required this.mode,
    required this.tariff,
    required this.hoursPerDay,
    required this.daysPerMonth,
    required this.coolingKw,
    required this.heatingKw,
    required this.monthlyKwh,
    required this.monthlyCost,
    required this.recommendation,
    required this.summary,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectName': projectName,
      'objectType': objectType,
      'area': area,
      'height': height,
      'people': people,
      'glazing': glazing,
      'insulation': insulation,
      'sunnySide': sunnySide,
      'climate': climate,
      'mode': mode,
      'tariff': tariff,
      'hoursPerDay': hoursPerDay,
      'daysPerMonth': daysPerMonth,
      'coolingKw': coolingKw,
      'heatingKw': heatingKw,
      'monthlyKwh': monthlyKwh,
      'monthlyCost': monthlyCost,
      'recommendation': recommendation,
      'summary': summary,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String toJson() => jsonEncode(toMap());

  factory SavedCalculation.fromMap(Map<String, dynamic> map) {
    return SavedCalculation(
      id: map['id'] ?? '',
      projectName: map['projectName'] ?? 'Без назви',
      objectType: map['objectType'] ?? 'Квартира',
      area: (map['area'] ?? 0).toDouble(),
      height: (map['height'] ?? 2.7).toDouble(),
      people: map['people'] ?? 0,
      glazing: map['glazing'] ?? 'Середнє',
      insulation: map['insulation'] ?? 'Середнє',
      sunnySide: map['sunnySide'] ?? false,
      climate: map['climate'] ?? 'Помірний',
      mode: map['mode'] ?? 'Охолодження',
      tariff: (map['tariff'] ?? 0).toDouble(),
      hoursPerDay: (map['hoursPerDay'] ?? 0).toDouble(),
      daysPerMonth: map['daysPerMonth'] ?? 0,
      coolingKw: (map['coolingKw'] ?? 0).toDouble(),
      heatingKw: (map['heatingKw'] ?? 0).toDouble(),
      monthlyKwh: (map['monthlyKwh'] ?? 0).toDouble(),
      monthlyCost: (map['monthlyCost'] ?? 0).toDouble(),
      recommendation: map['recommendation'] ?? '',
      summary: map['summary'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  factory SavedCalculation.fromJson(String source) =>
      SavedCalculation.fromMap(jsonDecode(source));

  SavedCalculation copyWith({
    String? id,
    String? projectName,
    String? objectType,
    double? area,
    double? height,
    int? people,
    String? glazing,
    String? insulation,
    bool? sunnySide,
    String? climate,
    String? mode,
    double? tariff,
    double? hoursPerDay,
    int? daysPerMonth,
    double? coolingKw,
    double? heatingKw,
    double? monthlyKwh,
    double? monthlyCost,
    String? recommendation,
    String? summary,
    DateTime? createdAt,
  }) {
    return SavedCalculation(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      objectType: objectType ?? this.objectType,
      area: area ?? this.area,
      height: height ?? this.height,
      people: people ?? this.people,
      glazing: glazing ?? this.glazing,
      insulation: insulation ?? this.insulation,
      sunnySide: sunnySide ?? this.sunnySide,
      climate: climate ?? this.climate,
      mode: mode ?? this.mode,
      tariff: tariff ?? this.tariff,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      daysPerMonth: daysPerMonth ?? this.daysPerMonth,
      coolingKw: coolingKw ?? this.coolingKw,
      heatingKw: heatingKw ?? this.heatingKw,
      monthlyKwh: monthlyKwh ?? this.monthlyKwh,
      monthlyCost: monthlyCost ?? this.monthlyCost,
      recommendation: recommendation ?? this.recommendation,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
