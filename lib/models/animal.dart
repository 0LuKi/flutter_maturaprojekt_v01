import 'package:cloud_firestore/cloud_firestore.dart';

class Animal {
  final String id;
  final String name;
  final String earTagNumber;
  final DateTime birthDate;
  final String breed;
  final String gender;
  final bool isCalf;
  final String? motherId;
  final String? fatherId; // NEU: Vater
  final DateTime? weaningDate;
  final int lactationNumber;
  final DateTime? lastInseminationDate;
  final DateTime? nextPregnancyCheckDate;

  Animal({
    required this.id,
    required this.name,
    required this.earTagNumber,
    required this.birthDate,
    this.breed = '',
    this.gender = 'Weiblich',
    this.isCalf = false,
    this.motherId,
    this.fatherId, // NEU
    this.weaningDate,
    this.lactationNumber = 0,
    this.lastInseminationDate,
    this.nextPregnancyCheckDate,
  });

  factory Animal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Animal(
      id: doc.id,
      name: data['name'] ?? '',
      earTagNumber: data['earTagNumber'] ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      breed: data['breed'] ?? '',
      gender: data['gender'] ?? 'Weiblich',
      isCalf: data['isCalf'] ?? false,
      motherId: data['motherId'],
      fatherId: data['fatherId'], // NEU
      weaningDate: data['weaningDate'] != null 
          ? (data['weaningDate'] as Timestamp).toDate() 
          : null,
      lactationNumber: data['lactationNumber'] ?? 0,
      lastInseminationDate: data['lastInseminationDate'] != null
          ? (data['lastInseminationDate'] as Timestamp).toDate()
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
      'breed': breed,
      'gender': gender,
      'isCalf': isCalf,
      'motherId': motherId,
      'fatherId': fatherId, // NEU
      'weaningDate': weaningDate != null ? Timestamp.fromDate(weaningDate!) : null,
      'lactationNumber': lactationNumber,
      'lastInseminationDate': lastInseminationDate != null
          ? Timestamp.fromDate(lastInseminationDate!)
          : null,
      'nextPregnancyCheckDate': nextPregnancyCheckDate != null
          ? Timestamp.fromDate(nextPregnancyCheckDate!)
          : null,
    };
  }
}