/// Одна модель зовнішнього блоку LG Multi V
class EquipmentModel {
  final String id;
  final String brand;
  final String seriesId;
  final String seriesName;
  final String tier;
  final String seriesTagline;
  final List<String> seriesFeatures;
  final List<String> seriesApplication;

  final int    hp;
  final double coolingKw;
  final double? heatingKw;
  final double? eer;
  final double? cop;
  final double? seer;
  final double? scop;
  final double? powerCoolingKw;
  final double? powerHeatingKw;
  final double? noiseCoolingDb;
  final double? noiseHeatingDb;
  final int?   maxIndoorUnits;
  final String voltage;
  final String refrigerant;

  /// Шлях до зображення в assets (може бути null)
  final String? imagePath;

  const EquipmentModel({
    required this.id,
    required this.brand,
    required this.seriesId,
    required this.seriesName,
    required this.tier,
    required this.seriesTagline,
    required this.seriesFeatures,
    required this.seriesApplication,
    required this.hp,
    required this.coolingKw,
    this.heatingKw,
    this.eer,
    this.cop,
    this.seer,
    this.scop,
    this.powerCoolingKw,
    this.powerHeatingKw,
    this.noiseCoolingDb,
    this.noiseHeatingDb,
    this.maxIndoorUnits,
    required this.voltage,
    required this.refrigerant,
    this.imagePath,
  });

  /// Повна назва для відображення
  String get displayName => '$brand $seriesName $id';

  /// Потужність охолодження відформатована
  String get coolingLabel => '${coolingKw.toStringAsFixed(1)} кВт';

  /// Потужність опалення відформатована
  String get heatingLabel => heatingKw != null
      ? '${heatingKw!.toStringAsFixed(1)} кВт'
      : '—';

  /// Чи є зображення
  bool get hasImage => imagePath != null;
}
