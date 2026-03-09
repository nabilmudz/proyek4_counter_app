import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logbook_app_021/helpers/log_helper.dart';
import 'package:logbook_app_021/services/mongo_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logbook/models/log_model.dart';
import 'package:mongo_dart/mongo_dart.dart';

class LogController {
  final String username;
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

  String get _storageKey => 'logs_data_$username';
  List<LogModel> get logs => logsNotifier.value;

  LogController(this.username) {
    loadFromDisk();

    logsNotifier.addListener(() {
      filteredLogs.value = logsNotifier.value;
    });
  }

  Future<void> addLog(String title, String desc, LogCategory category) async {
    final newLog = LogModel(
      id: ObjectId(),
      title: title,
      date: DateTime.now(),
      description: desc,
      category: category,
    );

    try {
      await MongoService().insertLog(newLog);
      final currentLogs = List<LogModel>.from(logsNotifier.value);
      currentLogs.add(newLog);
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Tambah data dengan ID lokal",
        source: "log_controller.dart",
      );
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Add - $e", level: 1);
    }
  }

  Future<void> updateLog(
    LogModel targetLog,
    String newTitle,
    String newDesc,
    LogCategory category,
  ) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final index = currentLogs.indexWhere((log) => log.id == targetLog.id);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id,
      title: newTitle,
      description: newDesc,
      date: DateTime.now(),
      category: category,
    );

    try {
      await MongoService().updateLog(updatedLog);
      currentLogs[index] = updatedLog;
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update '${oldLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Update - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> removeLog(LogModel targetLog) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final index = currentLogs.indexWhere((log) => log.id == targetLog.id);
    if (index == -1) {
      await LogHelper.writeLog(
        "ERROR: Data yang akan dihapus tidak ditemukan.",
        source: "log_controller.dart",
        level: 1,
      );
    }

    try {
      if (targetLog.id == null) {
        throw Exception(
          "ID Log tidak ditemukan, tidak bisa menghapus di Cloud.",
        );
      }
      await MongoService().deleteLog(targetLog.id!);
      currentLogs.removeAt(index);
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Hapus '${targetLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Hapus - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> loadFromDisk() async {
    final cloudData = await MongoService().getLogs();
    logsNotifier.value = cloudData;
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
      logsNotifier.value.map((log) => log.toMap()).toList(),
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
