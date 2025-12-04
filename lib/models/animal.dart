// DATEN MODFELLE


import 'package:cloud_firestore/cloud_firestore.dart';

class Animal {
  final String id;
  final String name;
  final String earTagNumber;
  final DateTime birthDate;
  final bool isCalf;
  final int lactationNumber;
  final DateTime? lastInseminationDate;
  final DateTime? nextPregnancyCheckDate;

  Animal({
    required this.id,
    required this.name,
    required this.earTagNumber,
    required this.birthDate,
    this.isCalf = false,
    this.lactationNumber = 0,
    this.lastInseminationDate,
    this.nextPregnancyCheckDate,
  });

  factory Animal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Animal(
      id: doc.id,
      name: data['name'] ?? '',
      earTagNumber: data['earTagNumber'] ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      isCalf: data['isCalf'] ?? false,
      lactationNumber: data['lactationNumber'] ?? 0,
      lastInseminationDate: data['lastInsemnationDate'] != null
          ? (data['lastInsemnationDate'] as Timestamp).toDate()
          : null,
      nextPregnancyCheckDate: data['nextPregnancyCheckDate'] != null
          ? (data['nextPregnancyCheckDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'earTagNumber': earTagNumber,
      'birthDate': Timestamp.fromDate(birthDate),
      'isCalf': isCalf,
      'lactationNumber': lactationNumber,
      'lastInsemnationDate': lastInseminationDate != null
          ? Timestamp.fromDate(lastInseminationDate!)
          : null,
      'nextPregnancyCheckDate': nextPregnancyCheckDate != null
          ? Timestamp.fromDate(nextPregnancyCheckDate!)
          : null,
    };
  }
}