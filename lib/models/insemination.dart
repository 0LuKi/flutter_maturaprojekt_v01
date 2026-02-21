import 'package:cloud_firestore/cloud_firestore.dart';

class Insemination {
  final String id;
  final String cowId;
  final DateTime date;
  final bool success;
  final String note;

  Insemination({
    required this.id,
    required this.cowId,
    required this.date,
    this.success = false,
    this.note = '',
  });

  factory Insemination.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Insemination(
      id: doc.id,
      cowId: data['cowId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      success: data['success'] ?? false,
      note: data['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cowId': cowId,
      'date': Timestamp.fromDate(date),
      'success': success,
      'note': note,
    };
  }
}
