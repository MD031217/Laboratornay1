import 'package:flutter/material.dart';
import 'calculator_logic.dart';
void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Калькулятор',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111318),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalcState();
}

class _CalcState extends State<CalculatorScreen> {
  final CalculatorLogic _calc = CalculatorLogic();
  String _num = '0';
  String _first = '';
  String _op = '';
  String _expr = '';
  bool _new = true;

  void _addNum(String n) {
    setState(() {
      if (_num.startsWith('Ошибка')) {
        _num = '0';
        _first = '';
        _op = '';
        _expr = '';
        _new = true;
      }
      if (_new) {
        _num = n;
        _new = false;
        _updExpr();
        return;
      }
      if (_num == '0' && n != '.') {
        _num = n;
      } else if (n == '.' && _num.contains('.')) {
        return;
      } else {
        _num += n;
      }
      _updExpr();
    });
  }

  void _setOp(String op) {
    if (_num.startsWith('Ошибка')) {
      return;
    }
    setState(() {
      if (_op.isNotEmpty && !_new) {
        final res = _calc.calculate(_first, _op, _num);
        if (res.startsWith('Ошибка')) {
          _num = res;
          _first = '';
          _op = '';
          _expr = '';
          _new = true;
          return;
        }
        _first = res;
        _num = res;
      } else {
        _first = _num;
      }
      _op = op;
      _new = true;
      _updExpr();
    });
  }

  void _showRes() {
    if (_op.isEmpty || _first.isEmpty) {
      return;
    }
    final oldExpr = '$_first $_op $_num';
    final res = _calc.calculate(_first, _op, _num);
    setState(() {
      _expr = oldExpr;
      _num = res;
      _first = '';
      _op = '';
      _new = true;
    });
  }


  void _percent() {
    if (_num.startsWith('Ошибка')) {
      return;
    }
    setState(() {
      _num = _calc.percent(_num);
      _new = false;
      _updExpr();
    });
  }

  void _sqrt() {
    if (_num.startsWith('Ошибка')) return;
    setState(() {
      _num = _calc.sqrt(_num);
      _new = true; 
      _updExpr();
    });
  }

  void _del() {
    if (_num.startsWith('Ошибка')) {
      _clear();
      return;
    }
    setState(() {
      if (_num.length <= 1 ||
          (_num.length == 2 && _num.startsWith('-'))) {
        _num = '0';
      } else {
        _num = _num.substring(0, _num.length - 1);
      }
      _updExpr();
    });
  }

  void _clear() {
    _num = '0';
    _first = '';
    _op = '';
    _expr = '';
    _new = true;
  }

  void _updExpr() {
    if (_first.isEmpty || _op.isEmpty) {
      _expr = '';
      return;
    }
    _expr = '$_first $_op $_num';
  }

  void _press(String v) {
    switch (v) {
      case 'C':
        setState(_clear);
        break;
      case '⌫':
        _del();
        break;
      case '%':
        _percent();
        break;
      case '√': 
        _sqrt();
        break;
      case '+':
      case '−':
      case '×':
      case '÷':
        _setOp(v);
        break;
      case '=':
        _showRes();
        break;
      case '.':
      default:
        _addNum(v);
    }
  }

  Widget _btn(String t) {
    final isOp = ['+', '−', '×', '÷', '%'].contains(t);
    final isAct = ['C', '⌫', '√'].contains(t);
    final isEq = t == '=';
    Color? bc;
    if (isEq) {
      bc = const Color(0xFF7C4DFF);
    } else if (isOp) {
      bc = const Color(0xFF3949AB);
    } else if (isAct) {
      bc = const Color(0xFF30343B);
    }
    return LayoutBuilder(
      builder: (ctx, size) {
        final fs = (size.maxWidth * 0.28).clamp(14.0, 25.0);
        return ElevatedButton(
          onPressed: () => _press(t),
          style: ElevatedButton.styleFrom(
            backgroundColor: bc,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              t,
              style: TextStyle(
                fontSize: fs,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _makeRow(List<String> values) {
    return Expanded(
      child: Row(
        children: [
          for (int i = 0; i < values.length; i++) ...[
            Expanded(
              child: _btn(values[i]),
            ),
            if (i < values.length - 1)
              const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        toolbarHeight: 44,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1E24),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _expr,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _num,
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _makeRow(['C', '%', '√', '÷']),
                    const SizedBox(height: 8),
                    _makeRow(['7', '8', '9', '×']),
                    const SizedBox(height: 8),
                    _makeRow(['4', '5', '6', '−']),
                    const SizedBox(height: 8),
                    _makeRow(['1', '2', '3', '+']),
                    const SizedBox(height: 8),
                    _makeRow(['0', '.', '⌫', '=']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
