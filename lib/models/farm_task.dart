import 'package:cloud_firestore/cloud_firestore.dart';

class FarmTask {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;

  FarmTask({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
  });

  factory FarmTask.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FarmTask(
      id: doc.id,
      title: data['title'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
    };
  }
}