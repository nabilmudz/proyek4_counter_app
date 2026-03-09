import 'package:logbook_app_021/features/auth/login_view.dart';
import 'package:logbook_app_021/features/logbook/log_view.dart';
import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  final String username;
  const CounterView({super.key, required this.username});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late CounterController _controller;
  String get greeting {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      return "Selamat Pagi";
    } else if (hour >= 12 && hour < 15) {
      return "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = CounterController(widget.username);
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadLastValue();
    await _controller.loadHistory();
    setState(() {});
  }

  void _handleLogbook() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LogView(username: widget.username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text("LogBook: ${widget.username}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text(
                      "Apa kamu yakin akan melakukan Logout?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Logout berhasil"),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "$greeting, ${widget.username}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            SizedBox(height: 60),
            Text(
              "Step: ${_controller.stepValue}",
              style: const TextStyle(fontSize: 24),
            ),
            Slider(
              value: _controller.stepValue.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _controller.stepValue.toString(),
              onChanged: (value) {
                setState(() {
                  _controller.setStep(value.toInt());
                });
              },
            ),
            const SizedBox(height: 10),
            Text(
              "Total Counter",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            Text(
              '${_controller.value}',
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  final log = _controller.history[index];

                  Color textColor;
                  switch (log["type"]) {
                    case "add":
                      textColor = Colors.green;
                      break;
                    case "minus":
                      textColor = Colors.orange;
                      break;
                    case "reset":
                      textColor = Colors.red;
                      break;
                    default:
                      textColor = Colors.black;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log["message"],
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          log["time"].toString().split('.').first,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'logbook',
            onPressed: _handleLogbook,
            backgroundColor: Colors.lightBlueAccent,
            child: const Icon(Icons.edit_document),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'decrement',
            onPressed: () {
              setState(() {
                _controller.decrement();
              });
            },
            backgroundColor: Colors.yellowAccent,
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'increment',
            onPressed: () {
              setState(() {
                _controller.increment();
              });
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'reset',
            onPressed: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Reset Counter"),
                    content: const Text(
                      "Apa kamu yakin akan melakukan reset Counter?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                setState(() {
                  _controller.reset();
                });
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Counter berhasil di-reset"),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.delete),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
