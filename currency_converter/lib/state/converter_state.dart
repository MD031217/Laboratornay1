import 'package:flutter/foundation.dart';
import '../models/currency_rate.dart';
import '../repositories/currency_repository.dart';

enum ConverterStatus { initial, loading, success, error }
class ConverterState extends ChangeNotifier {
  final CurrencyRepository _repository;
  ConverterState({CurrencyRepository? repository})
      : _repository = repository ?? CurrencyRepository();
  ConverterStatus _status = ConverterStatus.initial;
  ConverterStatus get status => _status;
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  CurrencyRate? _currencyRate;
  CurrencyRate? get currencyRate => _currencyRate;
  double _result = 0.0;
  double get result => _result;
  String _fromCurrency = 'USD';
  String get fromCurrency => _fromCurrency;
  String _toCurrency = 'RUB';
  String get toCurrency => _toCurrency;
  String _updateTime = '';
  String get updateTime => _updateTime;
  String _amountText = '';
  String get amountText => _amountText;
  List<String> get availableCurrencies {
    if (_currencyRate == null) return ['USD', 'EUR', 'RUB'];
    return _currencyRate!.rates.keys.toList()..sort();
  }

  Future<void> loadRates() async {
    _status = ConverterStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _currencyRate = await _repository.getRates();
      _updateTime = _currencyRate!.timeLastUpdateUtc;
      _status = ConverterStatus.success;
    } catch (e) {
      _status = ConverterStatus.error;
      _errorMessage = 'Не удалось загрузить курсы: $e';
    }
    notifyListeners();
  }

  void setFromCurrency(String currency) {
    _fromCurrency = currency;
    _autoRecalculate(); 
    notifyListeners();
  }

  void setToCurrency(String currency) {
    _toCurrency = currency;
    _autoRecalculate(); 
    notifyListeners();
  }

  void swapCurrencies() {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    _autoRecalculate();
    notifyListeners();
  }

  void setAmount(String amount) {
    _amountText = amount;
  }

  void convert(String amountStr) {
    _amountText = amountStr;
    if (amountStr.trim().isEmpty) {
      _errorMessage = 'Введите сумму';
      _status = ConverterStatus.error;
      notifyListeners();
      return;
    }
    final amount = double.tryParse(amountStr);
    if (amount == null || amount < 0) {
      _errorMessage = 'Некорректная сумма';
      _status = ConverterStatus.error;
      notifyListeners();
      return;
    }
    if (_currencyRate == null) {
      _errorMessage = 'Курсы ещё не загружены';
      _status = ConverterStatus.error;
      notifyListeners();
      return;
    }
    final rates = _currencyRate!.rates;
    final fromRate = rates[_fromCurrency];
    final toRate = rates[_toCurrency];
    if (fromRate == null || toRate == null) {
      _errorMessage = 'Курс для выбранной валюты не найден';
      _status = ConverterStatus.error;
      notifyListeners();
      return;
    }
    final amountInBase = amount / fromRate;
    _result = amountInBase * toRate;
    _status = ConverterStatus.success;
    _errorMessage = '';
    notifyListeners();
  }

  void _autoRecalculate() {
    if (_amountText.trim().isEmpty) return;
    if (_currencyRate == null) return;
    final amount = double.tryParse(_amountText);
    if (amount == null || amount < 0) return;
    final rates = _currencyRate!.rates;
    final fromRate = rates[_fromCurrency];
    final toRate = rates[_toCurrency];
    if (fromRate == null || toRate == null) return;
    final amountInBase = amount / fromRate;
    _result = amountInBase * toRate;
    _status = ConverterStatus.success;
    _errorMessage = '';
  }
}