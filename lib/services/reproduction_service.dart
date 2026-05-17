import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reproduction_event.dart';
import '../utilities/reproduction_calculator.dart';
import 'notification_service.dart';

class ReproductionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Ereignis hinzufügen (bestehend)
  Future<void> addEvent(String animalId, ReproductionEvent event) async {
    final batch = _db.batch();
    final eventRef = _db
        .collection('animals')
        .doc(animalId)
        .collection('reproduction')
        .doc();

    batch.set(eventRef, event.toMap());
    await batch.commit();

    // Nach dem Hinzufügen den Status synchronisieren
    await _syncAnimalStatus(animalId);
  }

  // 2. Ereignis AKTUALISIEREN (Neu mit Sync)
  Future<void> updateEvent(String animalId, ReproductionEvent event) async {
    await _db
        .collection('animals')
        .doc(animalId)
        .collection('reproduction')
        .doc(event.id)
        .update(event.toMap());

    // Nach der Änderung Status neu berechnen
    await _syncAnimalStatus(animalId);
  }

  // 3. Ereignis LÖSCHEN (Neu mit Sync & Notification-Cleanup)
  Future<void> deleteEvent(String animalId, String eventId) async {
    // Falls es eine Besamung war, Benachrichtigungen löschen
    await NotificationService.instance.cancelTaskNotification(
      '${animalId}_heat_check',
    );
    await NotificationService.instance.cancelTaskNotification(
      '${animalId}_calving_warn',
    );

    await _db
        .collection('animals')
        .doc(animalId)
        .collection('reproduction')
        .doc(eventId)
        .delete();

    // Nach dem Löschen Status auf das vorherige Event zurücksetzen
    await _syncAnimalStatus(animalId);
  }

  // Kernlogik: Den Hauptstatus des Tieres basierend auf der Historie neu setzen
  Future<void> _syncAnimalStatus(String animalId) async {
    final animalRef = _db.collection('animals').doc(animalId);

    // Hol das zeitlich letzte Ereignis aus der Subcollection
    final historySnapshot = await _db
        .collection('animals')
        .doc(animalId)
        .collection('reproduction')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (historySnapshot.docs.isEmpty) {
      // Keine Ereignisse mehr vorhanden -> Reset auf Standard
      await animalRef.update({
        'reproStatus': 'offen',
        'lastInseminationDate': null,
        'expectedCalvingDate': null,
        'dryOffDate': null,
      });
      return;
    }

    // Daten des neuesten verbleibenden Ereignisses laden
    final latestDoc = historySnapshot.docs.first;
    final latestEvent = ReproductionEvent.fromMap(
      latestDoc.id,
      latestDoc.data(),
    );

    Map<String, dynamic> updateData = {};

    switch (latestEvent.type) {
      case ReproEventType.brunst:
        updateData = {
          'reproStatus': 'offen',
          'expectedCalvingDate': null,
          'dryOffDate': null,
        };
        break;
      case ReproEventType.besamung:
        final calving = ReproductionCalculator.calculateExpectedCalving(
          latestEvent.date,
        );
        updateData = {
          'reproStatus': 'belegt',
          'lastInseminationDate': Timestamp.fromDate(latestEvent.date),
          'expectedCalvingDate': Timestamp.fromDate(calving),
          'dryOffDate': Timestamp.fromDate(
            ReproductionCalculator.calculateDryOffDate(calving),
          ),
        };
        break;
      case ReproEventType.kalbung:
        updateData = {
          'reproStatus': 'offen',
          'lastInseminationDate': null,
          'expectedCalvingDate': null,
          'dryOffDate': null,
        };
        break;
      case ReproEventType.trockenstellen:
        updateData = {'reproStatus': 'trocken'};
        break;
    }

    await animalRef.update(updateData);
  }

  // Stream für die UI (bestehend)
  Stream<List<ReproductionEvent>> getReproHistory(String animalId) {
    return _db
        .collection('animals')
        .doc(animalId)
        .collection('reproduction')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReproductionEvent.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
