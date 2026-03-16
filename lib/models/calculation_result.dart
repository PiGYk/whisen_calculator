class CalculationResult {
  final double coolingKw;
  final double heatingKw;
  final double monthlyKwh;
  final double monthlyCost;
  final String recommendation;
  final String summary;

  const CalculationResult({
    required this.coolingKw,
    required this.heatingKw,
    required this.monthlyKwh,
    required this.monthlyCost,
    required this.recommendation,
    required this.summary,
  });
}
