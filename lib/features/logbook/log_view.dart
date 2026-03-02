import 'package:counter_app/features/auth/login_view.dart';
import 'package:counter_app/features/logbook/counter_view.dart';
import 'package:counter_app/features/logbook/log_controller.dart';
import 'package:flutter/material.dart';
import './models/log_model.dart';

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});
  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  LogCategory? _logCategory;
  late final _controller = LogController(widget.username);

  Color getCardColor(LogCategory category) {
    switch (category) {
      case LogCategory.pekerjaan:
        return Colors.blue.shade200;

      case LogCategory.pribadi:
        return Colors.green.shade100;

      case LogCategory.urgent:
        return Colors.red.shade100;
    }
  }

  void _handleCounter() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CounterView(username: widget.username),
      ),
    );
  }

  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (context) {
        LogCategory? tempCategory = _logCategory;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Tambah Catatan Baru"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: "Judul Catatan",
                    ),
                  ),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: "Isi Deskripsi",
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButton<LogCategory>(
                      value: tempCategory,
                      hint: const Text("Pilih Kategori"),
                      isExpanded: true,
                      items: LogCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setStateDialog(() {
                          tempCategory = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (tempCategory == null) return;

                    _controller.addLog(
                      _titleController.text,
                      _contentController.text,
                      tempCategory!,
                    );
                    _titleController.clear();
                    _contentController.clear();
                    _logCategory = null;

                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    _logCategory = log.category;
    showDialog(
      context: context,
      builder: (context) {
        LogCategory? tempCategory = _logCategory;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Edit Catatan"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _titleController),
                  TextField(controller: _contentController),

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButton<LogCategory>(
                      value: tempCategory,
                      hint: const Text("Pilih Kategori"),
                      isExpanded: true,
                      items: LogCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setStateDialog(() {
                          tempCategory = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (tempCategory != null) {
                      _controller.updateLog(
                        index,
                        _titleController.text,
                        _contentController.text,
                        tempCategory!,
                      );
                    }
                    _titleController.clear();
                    _contentController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                onChanged: (value) => _controller.searchLog(value),
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ValueListenableBuilder<List<LogModel>>(
                  valueListenable: _controller.filteredLogs,
                  builder: (context, currentLogs, child) {
                    if (currentLogs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/empty-folder.png',
                              width: 160,
                              height: 160,
                            ),
                            SizedBox(height: 16),
                            Text("Belum ada catatan."),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: currentLogs.length,
                      itemBuilder: (context, index) {
                        final log = currentLogs[index];
                        return Dismissible(
                          key: Key(log.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            _controller.removeLog(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Catatan dihapus")),
                            );
                          },
                          child: Card(
                            color: getCardColor(log.category),
                            child: ListTile(
                              leading: const Icon(Icons.note_rounded),
                              title: Text(log.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(log.description),
                                  Text(log.date),
                                ],
                              ),
                              trailing: Wrap(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () =>
                                        _showEditLogDialog(index, log),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(
                                        () => _controller.removeLog(index),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.amberAccent,
            onPressed: _handleCounter,
            child: const Icon(Icons.format_list_numbered),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _showAddLogDialog,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
