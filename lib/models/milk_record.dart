import 'package:cloud_firestore/cloud_firestore.dart';

class MilkRecord {
  final String id;
  final String cowId;
  final DateTime date;
  final double morningLiters;
  final double eveningLiters;

  MilkRecord({
    required this.id,
    required this.cowId,
    required this.date,
    required this.morningLiters,
    required this.eveningLiters,
  });

  factory MilkRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MilkRecord(
      id: doc.id,
      cowId: data['cowId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      morningLiters: (data['morningLiters'] ?? 0).toDouble(),
      eveningLiters: (data['eveningLiters'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cowId': cowId,
      'date': Timestamp.fromDate(date),
      'morningLiters': morningLiters,
      'eveningLiters': eveningLiters,
    };
  }
}
