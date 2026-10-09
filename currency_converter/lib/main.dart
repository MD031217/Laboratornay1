import 'package:flutter/material.dart';
import 'ui/converter_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Конвертер валют',
      theme: ThemeData(useMaterial3: true),
      home: const ConverterScreen(),
    );
  }
}