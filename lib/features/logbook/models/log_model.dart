import 'package:uuid/uuid.dart';

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
  final String id;
  final String title;
  final String date;
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
      id: map['id'] ?? const Uuid().v4(),
      title: map['title'],
      date: map['date'],
      description: map['description'],
      category: LogCategory.fromString(map['category']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'description': description,
      'category': category.value,
    };
  }
}
