class VolatilityResult {
  final double percentChange;
  final bool isIncrease;
  final DateTime time;

  VolatilityResult({
    required this.percentChange,
    required this.isIncrease,
    required this.time,
  });
}
