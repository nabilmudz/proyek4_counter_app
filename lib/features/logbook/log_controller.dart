import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logbook/models/log_model.dart';
import 'package:uuid/uuid.dart';

class LogController {
  final String username;
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

  LogController(this.username) {
    loadFromDisk();

    logsNotifier.addListener(() {
      filteredLogs.value = logsNotifier.value;
    });
  }
  String get _storageKey => 'logs_data_$username';

  void addLog(String title, String desc, LogCategory category) {
    final newLog = LogModel(
      id: Uuid().v4(),
      title: title,
      date: DateTime.now().toString().substring(0, 16),
      description: desc,
      category: category,
    );
    logsNotifier.value = [...logsNotifier.value, newLog];
    filteredLogs.value = logsNotifier.value;
    saveToDisk();
  }

  void updateLog(int index, String title, String desc, LogCategory category) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];
    currentLogs[index] = LogModel(
      id: oldLog.id,
      title: title,
      date: DateTime.now().toString().substring(0, 16),
      description: desc,
      category: category,
    );
    logsNotifier.value = currentLogs;
    saveToDisk();
  }

  void removeLog(int index) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    saveToDisk();
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final List decodedData = jsonDecode(data);
      logsNotifier.value = decodedData.map((e) => LogModel.fromMap(e)).toList();
      filteredLogs.value = logsNotifier.value;
    }
  }

  Future<void> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    String? rawJson = prefs.getString('saved_logs');

    if (rawJson != null) {
      Iterable decoded = jsonDecode(rawJson);
      logsNotifier.value = decoded
          .map((item) => LogModel.fromMap(item))
          .toList();
    }
  }

  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      logsNotifier.value.map((e) => e.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}
