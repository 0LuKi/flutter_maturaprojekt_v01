import 'package:cloud_firestore/cloud_firestore.dart';

class FarmTask {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final String category;  // Add this field

  FarmTask({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    required this.category,  // Add this parameter
  });

  factory FarmTask.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FarmTask(
      id: doc.id,
      title: data['title'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      category: data['category'] ?? '',
    );
  }

  // If using JSON serialization (e.g., with json_serializable), update fromJson and toJson accordingly
  factory FarmTask.fromJson(Map<String, dynamic> json) {
    return FarmTask(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      category: json['category'] as String? ?? 'General',  // Add this
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'category': category,  // Add this
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
    };
  }
}