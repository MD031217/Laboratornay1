import '../models/currency_rate.dart';
import '../services/api_client.dart';

class CurrencyRepository {
  final ApiClient _apiClient;
  CurrencyRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();
  Future<CurrencyRate> getRates() async {
    return await _apiClient.fetchRates();
  }
}