import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecord {
  final DateTime date;
  final String diagnosis;
  final String treatment;

  MedicalRecord({required this.date, required this.diagnosis, required this.treatment});

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'diagnosis': diagnosis,
      'treatment': treatment,
    };
  }
}