import 'dart:math' as math;

class CalculatorLogic {
  String calculate(String a, String op, String b) {
    double x = double.tryParse(a) ?? 0;
    double y = double.tryParse(b) ?? 0;
    switch (op) {
      case '+':
        return _fmt(x + y);
      case '−':
        return _fmt(x - y);
      case '×':
        return _fmt(x * y);
      case '÷':
        if (y == 0) {
          return 'Ошибка: деление на 0';
        }
        return _fmt(x / y);
      default:
        return 'Ошибка: неизвестная операция';
    }
  }

   String sqrt(String v) {
      double x = double.tryParse(v) ?? 0;
      if (x < 0) {
        return 'Ошибка: корень из отрицательного';
      }
      return _fmt(math.sqrt(x)); 
    }

  String percent(String v) {
    double x = double.tryParse(v) ?? 0;
    return _fmt(x / 100);
  }

  String _fmt(double x) {
    if (x == x.roundToDouble()) {
      return x.toInt().toString();
    }
    return x
        .toStringAsFixed(10)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}