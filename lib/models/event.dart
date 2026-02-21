import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String cowId;
  final String type; // Brunst, Besamung, Krankheit, etc.
  final DateTime date;
  final String note;

  Event({
    required this.id,
    required this.cowId,
    required this.type,
    required this.date,
    this.note = '',
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      cowId: data['cowId'] ?? '',
      type: data['type'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cowId': cowId,
      'type': type,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }
}
