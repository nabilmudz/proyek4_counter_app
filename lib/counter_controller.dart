class CounterController {
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
  }

  void decrement() {
    if (_counter - _step >= 0) {
      _counter -= _step;
    }
    addHistory("Mengurangi sebesar $_step", "minus");
  }

  void reset() {
    _counter = 0;
    _step = 1;
    _history.clear();
    addHistory("Melakukan reset", "reset");
  }

  void setStep(int newStep) {
    _step = newStep;
  }
}
