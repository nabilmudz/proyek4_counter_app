import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CounterController {
  final String username;
  CounterController(this.username);

  Future<void> saveLastValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_counter_$username', _counter);
  }

  Future<void> loadLastValue() async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('last_counter_$username') ?? 0;
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(_history);
    await prefs.setString('history_$username', encoded);
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String? encoded = prefs.getString('history_$username');

    if (encoded != null) {
      List decoded = jsonDecode(encoded);
      _history.clear();
      _history.addAll(List<Map<String, dynamic>>.from(decoded));
    }
  }

  int _counter = 0;
  int _step = 1;
  final List<Map<String, dynamic>> _history = [];

  int get value => _counter;
  int get stepValue => _step;
  List<Map<String, dynamic>> get history => _history;

  void addHistory(String message, String type) {
    final time = DateTime.now().toString();

    _history.add({"message": message, "time": time, "type": type});

    if (_history.length > 5) {
      _history.removeAt(0);
    }
  }

  void increment() {
    _counter += _step;
    addHistory("Menambah sebesar $_step", "add");
    saveLastValue();
    saveHistory();
  }

  void decrement() {
    if (_counter - _step >= 0) {
      _counter -= _step;
    }
    addHistory("Mengurangi sebesar $_step", "minus");
    saveLastValue();
    saveHistory();
  }

  void reset() {
    _counter = 0;
    _step = 1;
    _history.clear();
    addHistory("Melakukan reset", "reset");
    saveLastValue();
    saveHistory();
  }

  void setStep(int newStep) {
    _step = newStep;
  }
}
