import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feed_item.dart';

class FeedService {
  final CollectionReference _feedCollection = FirebaseFirestore.instance
      .collection('feeds');

  // Stream aller Futterarten abrufen (Perfekt für StreamBuilder)
  Stream<List<FeedItem>> getFeedsStream() {
    return _feedCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FeedItem.fromDocument(doc)).toList();
    });
  }

  // Futterbestand aktualisieren (Auffüllen)
  Future<void> addStock(String feedId, double amount) async {
    try {
      await _feedCollection.doc(feedId).update({
        'currentStock': FieldValue.increment(amount),
      });
    } catch (e) {
      throw Exception('Fehler beim Auffüllen des Bestands: $e');
    }
  }

  // Verbrauch eintragen und Historie aktualisieren
  Future<void> consumeStock(String feedId, double amount) async {
    try {
      final today = DateTime.now()
          .toIso8601String()
          .split('T')
          .first; // YYYY-MM-DD

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docRef = _feedCollection.doc(feedId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) throw Exception("Futter nicht gefunden!");

        final currentStock =
            (snapshot.data() as Map<String, dynamic>)['currentStock'] ?? 0.0;
        if (currentStock < amount) {
          throw Exception("Nicht genügend Bestand vorhanden!");
        }

        transaction.update(docRef, {
          'currentStock': FieldValue.increment(-amount),
          'consumptionHistory.$today': FieldValue.increment(amount),
        });
      });
    } catch (e) {
      throw Exception('Fehler beim Eintragen des Verbrauchs: $e');
    }
  }

  // --- Diese Methode NEU hinzufügen ---
  Future<void> createNewFeed({
    required String name,
    required double initialStock,
    required double dailyConsumption,
    required String unit,
    required double minThreshold,
  }) async {
    try {
      // Erstellt ein neues leeres Dokument, um eine ID zu generieren
      final docRef = _feedCollection.doc();

      final newFeed = FeedItem(
        id: docRef.id,
        name: name,
        currentStock: initialStock,
        dailyConsumption: dailyConsumption,
        unit: unit,
        minThreshold: minThreshold,
        consumptionHistory: {}, // Beginnt mit leerer Historie
      );

      // Speichert die Daten in Firestore
      await docRef.set(newFeed.toMap());
    } catch (e) {
      throw Exception('Fehler beim Erstellen der Futterart: $e');
    }
  }
}
