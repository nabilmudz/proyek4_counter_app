import 'package:logbook_app_021/features/auth/login_view.dart';
import 'package:logbook_app_021/features/logbook/counter_view.dart';
import 'package:logbook_app_021/features/logbook/log_controller.dart';
import 'package:flutter/material.dart';
import 'package:logbook_app_021/helpers/log_helper.dart';
import 'package:logbook_app_021/services/mongo_service.dart';
import './models/log_model.dart';
import 'package:intl/intl.dart';

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
  late LogController _controller;
  late bool _isLoading = false;
  late Future<List<LogModel>> _logsFuture;
  bool _isOffline = false;
  final DateFormat _indoDateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  Future<List<LogModel>> _loadLogsForUi() async {
    try {
      final logs = await MongoService().getLogs();
      if (mounted) {
        setState(() {
          _isOffline = false;
        });
      }
      return logs;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOffline = true;
        });
      }
      await LogHelper.writeLog(
        "UI: Gagal memuat data cloud - $e",
        source: "log_view.dart",
        level: 1,
      );
      return [];
    }
  }

  Future<void> _refreshLogs() async {
    final logsFuture = _loadLogsForUi();

    if (!mounted) {
      _logsFuture = logsFuture;
      return;
    }

    setState(() {
      _logsFuture = logsFuture;
    });

    await logsFuture;
  }

  Future<void> _handlePullToRefresh() async {
    await _initDatabase();
  }

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

  String _formatLogDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    }

    if (difference.inDays == 1) {
      return 'Kemarin';
    }

    return _indoDateFormat.format(date);
  }

  void _handleCounter() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CounterView(username: widget.username),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = LogController(widget.username);
    _logsFuture = Future.value(const <LogModel>[]);

    Future.microtask(() => _initDatabase());
  }

  Future<void> _initDatabase() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await LogHelper.writeLog(
        "UI: Memulai inisialisasi database...",
        source: "log_view.dart",
      );

      await LogHelper.writeLog(
        "UI: Menghubungi MongoService.connect()...",
        source: "log_view.dart",
      );

      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          "Koneksi Cloud Timeout. Periksa sinyal/IP Whitelist.",
        ),
      );

      await LogHelper.writeLog(
        "UI: Koneksi MongoService BERHASIL.",
        source: "log_view.dart",
      );

      await LogHelper.writeLog(
        "UI: Memanggil controller.loadFromDisk()...",
        source: "log_view.dart",
      );

      await _controller.loadFromDisk();
      await _refreshLogs();

      if (mounted) {
        setState(() {
          _isOffline = false;
        });
      }

      await LogHelper.writeLog(
        "UI: Data berhasil dimuat ke Notifier.",
        source: "log_view.dart",
      );
    } catch (e) {
      setState(() {
        _isOffline = true;
        _isLoading = false;
      });
      await LogHelper.writeLog(
        "UI: Error - $e",
        source: "log_view.dart",
        level: 1,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Masalah: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildOfflineWarning() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.shade700),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.yellow.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Offline Mode Aktif.",
              style: TextStyle(
                color: Colors.yellow.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildOfflineWarning(),
        const SizedBox(height: 24),
        if (_isLoading) ...[
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text("Mencoba reconnect ke database..."),
        ] else ...[
          const Icon(Icons.swipe_down, size: 36, color: Colors.grey),
          const SizedBox(height: 12),
          const Text("Tarik ke bawah untuk reload data"),
        ],
      ],
    );
  }

  Widget _buildPullToRefreshContainer(BuildContext context, Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _handlePullToRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text("Belum ada catatan di Cloud."),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _showAddLogDialog,
          child: const Text("Buat Catatan Pertama"),
        ),
        const SizedBox(height: 16),
        const Text("Tarik ke bawah untuk reload"),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Menghubungkan ke MongoDB Atlas..."),
        ],
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
                  onPressed: () async {
                    if (tempCategory == null) return;

                    await _controller.addLog(
                      _titleController.text,
                      _contentController.text,
                      tempCategory!,
                    );
                    await _refreshLogs();
                    _titleController.clear();
                    _contentController.clear();
                    _logCategory = null;

                    if (!context.mounted) return;
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

  void _showEditLogDialog(LogModel log) {
    final titleController = TextEditingController(text: log.title);
    final contentController = TextEditingController(text: log.description);
    LogCategory tempCategory = log.category;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Edit Catatan"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController),
                  TextField(controller: contentController),
                  const SizedBox(height: 12),
                  DropdownButton<LogCategory>(
                    value: tempCategory,
                    isExpanded: true,
                    items: LogCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        tempCategory = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await MongoService().updateLog(
                      LogModel(
                        id: log.id,
                        title: titleController.text,
                        description: contentController.text,
                        date: DateTime.now(),
                        category: tempCategory,
                      ),
                    );
                    await _refreshLogs();
                    if (!context.mounted) return;
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
                if (!context.mounted) return;
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
          padding: const EdgeInsets.all(16),
          child: _isOffline
              ? _buildPullToRefreshContainer(context, _buildOfflineState())
              : Column(
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
                      child: FutureBuilder<List<LogModel>>(
                        future: _logsFuture,
                        builder: (context, currentLogs) {
                          if (_isLoading) {
                            return _buildLoadingState();
                          }
                          if (currentLogs.data?.isEmpty ?? true) {
                            return _buildPullToRefreshContainer(
                              context,
                              _buildEmptyState(context),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: _handlePullToRefresh,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: currentLogs.data?.length ?? 0,
                              itemBuilder: (context, index) {
                                final log = currentLogs.data![index];
                                return Dismissible(
                                  key: Key(log.id.toString()),
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
                                  confirmDismiss: (direction) async {
                                    await _refreshLogs();
                                    if (!context.mounted) return false;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Catatan dihapus"),
                                      ),
                                    );
                                    return true;
                                  },
                                  child: Card(
                                    color: getCardColor(log.category),
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.cloud_done,
                                        color: Colors.green,
                                      ),
                                      title: Text(log.title),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(log.description),
                                          Text(_formatLogDate(log.date)),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () =>
                                                _showEditLogDialog(log),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              await MongoService().deleteLog(
                                                log.id!,
                                              );
                                              await _refreshLogs();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
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
