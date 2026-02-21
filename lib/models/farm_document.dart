import 'package:cloud_firestore/cloud_firestore.dart';

class FarmDocument {
  final String id;
  final String title;
  final String category;
  final String
  storageUrl; // Hier steht jetzt der lokale Dateipfad (z.B. /data/user/.../scan.jpg)
  final DateTime createdAt;

  FarmDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.storageUrl,
    required this.createdAt,
  });

  factory FarmDocument.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    // Sicherstellen, dass das Datum richtig umgewandelt wird
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
    );
  }

  // Um Daten in Firestore zu schreiben
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'storageUrl': storageUrl,
      'createdAt': createdAt,
    };
  }
}
