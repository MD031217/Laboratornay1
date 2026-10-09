import 'package:flutter/material.dart';
import '../state/converter_state.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});
  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _amountController = TextEditingController();
  late ConverterState _state;
  @override
  void initState() {
    super.initState();
    _state = ConverterState();
    _state.addListener(_onStateChanged);
    _state.loadRates();
    _amountController.addListener(() {
      _state.setAmount(_amountController.text);
    });
  }

  void _onStateChanged() => setState(() {});
  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _state.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Конвертер валют')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Сумма',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildCurrencyDropdown(true)),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: _state.swapCurrencies,
                  tooltip: 'Поменять местами',
                ),
                Expanded(child: _buildCurrencyDropdown(false)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _state.convert(_amountController.text),
              child: const Text('Конвертировать'),
            ),
            const SizedBox(height: 24),
            _buildStatusWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(bool isFrom) {
    return DropdownButtonFormField<String>(
      value: isFrom ? _state.fromCurrency : _state.toCurrency,
      items: _state.availableCurrencies
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (val) {
        if (val != null) {
          isFrom ? _state.setFromCurrency(val) : _state.setToCurrency(val);
        }
      },
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget _buildStatusWidget() {
    switch (_state.status) {
      case ConverterStatus.loading:
        return const CircularProgressIndicator();
      case ConverterStatus.error:
        return Text(
          _state.errorMessage,
          style: const TextStyle(color: Colors.red),
        );
      case ConverterStatus.success:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '${_amountController.text} ${_state.fromCurrency} = ${_state.result.toStringAsFixed(2)} ${_state.toCurrency}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Обновлено: ${_state.updateTime}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        );
      case ConverterStatus.initial:
        return const SizedBox.shrink();
    }
  }
}