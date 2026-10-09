import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency_rate.dart';

class ApiClient {
  static const _baseUrl = 'https://v6.exchangerate-api.com/v6/6d070d548ccef94eaeaa2cb3/latest/USD';
  static const _fallbackUrl = 'https://v6.exchangerate-api.com/v6/6d070d548ccef94eaeaa2cb3/latest/USD';
  Future<CurrencyRate> fetchRates() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Превышено время ожидания'),
      );
      print('Статус ответа: ${response.statusCode}');
      print('Тело ответа: ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json == null || json is! Map<String, dynamic>) {
          throw Exception('Некорректный формат ответа сервера');
        }
        if (json['result'] == 'error') {
          throw Exception('API вернул ошибку: ${json['error-type'] ?? 'неизвестная ошибка'}');
        }
        return CurrencyRate.fromJson(json);
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      print('Основной API недоступен, пробую резервный...');
      return _fetchFromFallback();
    }
  }

  Future<CurrencyRate> _fetchFromFallback() async {
    final response = await http.get(Uri.parse(_fallbackUrl)).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Превышено время ожидания'),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CurrencyRate.fromJson(json);
    } else {
      throw Exception('Ошибка резервного сервера: ${response.statusCode}');
    }
  }
}