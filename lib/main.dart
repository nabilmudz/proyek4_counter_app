import 'package:flutter/material.dart';
import 'counter_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logbook App',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 0, 255, 98),
        ),
      ),
      home: const CounterView(),
    );
  }
}
