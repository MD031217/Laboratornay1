class CurrencyRate {
  final String baseCode;
  final Map<String, double> rates;
  final String timeLastUpdateUtc;
  CurrencyRate({
    required this.baseCode,
    required this.rates,
    required this.timeLastUpdateUtc,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    final rawRates = json['conversion_rates'];
    if (rawRates == null || rawRates is! Map) {
      throw Exception('Поле conversion_rates отсутствует или имеет неверный формат');
    }

    final ratesMap = <String, double>{};
    (rawRates as Map<String, dynamic>).forEach((key, value) {
      if (value != null) {
        ratesMap[key] = (value as num).toDouble();
      }
    });
    return CurrencyRate(
      baseCode: json['base_code'] as String? ?? 'USD',
      rates: ratesMap,
      timeLastUpdateUtc: json['time_last_update_utc'] as String? ?? 'Неизвестно',
    );
  }
}