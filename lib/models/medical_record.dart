import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecord {
  final String id;
  final DateTime date;
  final String diagnosis;
  final String treatment;
  final double cost; // Neu
  final String veterinarian; // Neu
  final DateTime? followUpDate; // Neu (Nachuntersuchung)
  final String notes; // Neu

  MedicalRecord({
    required this.id,
    required this.date,
    required this.diagnosis,
    required this.treatment,
    this.cost = 0.0,
    this.veterinarian = '',
    this.followUpDate,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'diagnosis': diagnosis,
      'treatment': treatment,
      'cost': cost,
      'veterinarian': veterinarian,
      'followUpDate': followUpDate != null ? Timestamp.fromDate(followUpDate!) : null,
      'notes': notes,
    };
  }
}