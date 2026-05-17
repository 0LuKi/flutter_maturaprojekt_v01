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
  final String? fatherId;
  final DateTime? weaningDate;
  final int lactationNumber;
  final String reproStatus; // "offen", "belegt", "trächtig", "trocken"
  final DateTime? lastInseminationDate;
  final DateTime? expectedCalvingDate;
  final DateTime? dryOffDate;
  final DateTime? nextPregnancyCheckDate;
  final int age;

  Animal({
    required this.id,
    required this.name,
    required this.earTagNumber,
    required this.birthDate,
    this.breed = '',
    this.gender = 'Weiblich',
    this.isCalf = false,
    this.motherId,
    this.fatherId,
    this.weaningDate,
    this.lactationNumber = 0,
    this.reproStatus = 'offen',
    this.lastInseminationDate,
    this.expectedCalvingDate,
    this.dryOffDate,
    this.nextPregnancyCheckDate,
    required this.age,
  });

  factory Animal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Hilfsfunktion für sicheres Datum-Parsing
    DateTime? toDate(dynamic value) {
      if (value == null) return null;
      return (value as Timestamp).toDate();
    }

    return Animal(
      id: doc.id,
      name: data['name'] ?? '',
      earTagNumber: data['earTagNumber'] ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      breed: data['breed'] ?? '',
      gender: data['gender'] ?? 'Weiblich',
      isCalf: data['isCalf'] ?? false,
      motherId: data['motherId'],
      fatherId: data['fatherId'],
      weaningDate: toDate(data['weaningDate']),
      lactationNumber: data['lactationNumber'] ?? 0,
      // Neue Felder auslesen
      reproStatus: data['reproStatus'] ?? 'offen',
      lastInseminationDate: toDate(data['lastInseminationDate']),
      expectedCalvingDate: toDate(data['expectedCalvingDate']),
      dryOffDate: toDate(data['dryOffDate']),
      nextPregnancyCheckDate: toDate(data['nextPregnancyCheckDate']),
      age: data['age'] ?? 0,
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
      'fatherId': fatherId,
      'weaningDate': weaningDate != null
          ? Timestamp.fromDate(weaningDate!)
          : null,
      'lactationNumber': lactationNumber,
      'reproStatus': reproStatus,
      'lastInseminationDate': lastInseminationDate != null
          ? Timestamp.fromDate(lastInseminationDate!)
          : null,
      'expectedCalvingDate': expectedCalvingDate != null
          ? Timestamp.fromDate(expectedCalvingDate!)
          : null,
      'dryOffDate': dryOffDate != null ? Timestamp.fromDate(dryOffDate!) : null,
      'nextPregnancyCheckDate': nextPregnancyCheckDate != null
          ? Timestamp.fromDate(nextPregnancyCheckDate!)
          : null,
      'age': age,
    };
  }
}
