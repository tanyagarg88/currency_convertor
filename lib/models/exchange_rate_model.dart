class ExchangeRate {
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final DateTime timestamp;

  ExchangeRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.timestamp,
  });
}
