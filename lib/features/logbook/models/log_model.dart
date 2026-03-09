import 'package:mongo_dart/mongo_dart.dart';

enum LogCategory {
  pekerjaan("Pekerjaan"),
  pribadi("Pribadi"),
  urgent("Urgent");

  final String value;
  const LogCategory(this.value);

  static LogCategory fromString(String value) {
    return LogCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LogCategory.pekerjaan,
    );
  }
}

class LogModel {
  final ObjectId? id;
  final String title;
  final DateTime date;
  final String description;
  final LogCategory category;

  LogModel({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.category,
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: (map['_id'] ?? map['id']) as ObjectId?,
      title: map['title'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      description: map['description'] ?? '',
      category: LogCategory.fromString(map['category']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'date': date.toIso8601String(),
      'description': description,
      'category': category.value,
    };
  }
}
