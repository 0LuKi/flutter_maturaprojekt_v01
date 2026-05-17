import 'package:cloud_firestore/cloud_firestore.dart';

class FarmDocument {
  final String id;
  final String title;
  final String category;
  final String storageUrl;
  final DateTime createdAt;
  final String? animalId; // NEU: Optionale Tier-ID

  FarmDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.storageUrl,
    required this.createdAt,
    this.animalId, // NEU
  });

  factory FarmDocument.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    DateTime parsedDate = DateTime.now();
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        parsedDate = (data['createdAt'] as Timestamp).toDate();
      }
    }

    return FarmDocument(
      id: documentId,
      title: data['title']?.toString() ?? 'Ohne Titel',
      category: data['category']?.toString() ?? 'Unsortiert',
      storageUrl: data['storageUrl']?.toString() ?? '',
      createdAt: parsedDate,
      animalId: data['animalId']?.toString(), // NEU
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'storageUrl': storageUrl,
      'createdAt': createdAt,
      'animalId': animalId, // NEU
    };
  }
}
