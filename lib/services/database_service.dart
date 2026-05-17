import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_maturaprojekt_v01/models/farm_document.dart';
import 'package:intl/intl.dart';
import '../models/animal.dart';
import '../models/calving_history.dart';
import '../models/milk_yield.dart';
import '../models/medical_record.dart';
import '../models/farm_task.dart';
import '../models/event.dart';
import '../models/insemination.dart';

class DatabaseService {
  // --- 6. EVENTS (Brunst, Besamung, Krankheit) ---
  Stream<List<Event>> getEvents(String animalId) {
    return _db
        .collection('animals')
        .doc(animalId)
        .collection('events')
        .orderBy('date', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Event.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addEvent(String animalId, Event event) {
    return _db
        .collection('animals')
        .doc(animalId)
        .collection('events')
        .add(event.toMap());
  }

  // --- 5. FARM DOCUMENTS ---
  Future<void> addFarmDocument({
    required String title,
    required String category,
    required String storageUrl,
  }) {
    return _db.collection('farm_documents').add({
      'title': title,
      'category': category,
      'storageUrl': storageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. Beim ABRUFEN anpassen (Ich habe .orderBy auch wieder hinzugefügt, damit die neuesten oben stehen)
  Stream<List<FarmDocument>> getFarmDocuments() {
    // HIER GEÄNDERT: 'farm_documents'
    return _db
        .collection('farm_documents')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print(
            '🔥 FIREBASE ANTWORT: ${snapshot.docs.length} Dokumente gefunden!',
          );
          return snapshot.docs.map((doc) {
            return FarmDocument.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> deleteFarmDocument(String documentId) {
    return _db.collection('farm_documents').doc(documentId).delete();
  }

  // --- 4. BESAMUNG (INSEMINATION) ---
  Stream<List<Insemination>> getInseminations(String animalId) {
    return _db
        .collection('animals')
        .doc(animalId)
        .collection('inseminations')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            return Insemination(
              id: doc.id,
              cowId: data['cowId'] ?? '',
              date: (data['date'] as Timestamp).toDate(),
              success: data['success'] ?? false,
              note: data['note'] ?? '',
            );
          }).toList(),
        );
  }

  Future<void> addInsemination(String animalId, Insemination record) {
    return _db
        .collection('animals')
        .doc(animalId)
        .collection('inseminations')
        .add(record.toMap());
  }

  Future<double> calculateBesamungsindex(String animalId) async {
    final snap = await _db
        .collection('animals')
        .doc(animalId)
        .collection('inseminations')
        .get();
    final records = snap.docs
        .map((doc) => Insemination.fromFirestore(doc))
        .toList();
    if (records.isEmpty) return 0.0;
    int attempts = records.length;
    int successful = records.where((r) => r.success).length;
    return attempts / (successful == 0 ? 1 : successful);
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  DatabaseService({required this.userId}) {
    _db.settings = const Settings(persistenceEnabled: true);
  }

  // --- 1. TIERE (ANIMALS) ---

  Stream<List<Animal>> getAnimals() {
    return _db
        .collection('animals')
        .where('ownerId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Animal.fromFirestore(doc)).toList(),
        );
  }

  Stream<Animal> getAnimal(String animalId) {
    return _db
        .collection('animals')
        .doc(animalId)
        .snapshots()
        .map((doc) => Animal.fromFirestore(doc));
  }

  Future<void> addAnimal(Animal animal) {
    var data = animal.toMap();
    data['ownerId'] = userId;
    return _db.collection('animals').add(data);
  }

  Future<void> deleteAnimal(String animalId) {
    return _db.collection('animals').doc(animalId).delete();
  }

  // --- NEU: INTELLIGENTE KALB-ERSTELLUNG ---
  // Erstellt ein Kalb und aktualisiert GLEICHZEITIG die Mutter, falls gefunden.
  Future<void> addCalfWithMotherLink({
    required Animal calf,
    required String motherIdentifier, // Name oder Ohrmarke der Mutter
    required CalvingHistory calvingDetails,
  }) async {
    WriteBatch batch = _db.batch();

    // 1. Kalb erstellen
    DocumentReference calfRef = _db.collection('animals').doc();
    var calfData = calf.toMap();
    calfData['ownerId'] = userId;
    batch.set(calfRef, calfData);

    // 2. Mutter suchen (nach Name oder Ohrmarke)
    if (motherIdentifier.isNotEmpty) {
      // Wir suchen zuerst nach Name
      var motherQuery = await _db
          .collection('animals')
          .where('ownerId', isEqualTo: userId)
          .where('name', isEqualTo: motherIdentifier)
          .limit(1)
          .get();

      // Wenn nicht gefunden, suchen wir nach Ohrmarke
      if (motherQuery.docs.isEmpty) {
        motherQuery = await _db
            .collection('animals')
            .where('ownerId', isEqualTo: userId)
            .where('earTagNumber', isEqualTo: motherIdentifier)
            .limit(1)
            .get();
      }

      // Wenn Mutter gefunden wurde:
      if (motherQuery.docs.isNotEmpty) {
        var motherDoc = motherQuery.docs.first;
        DocumentReference motherRef = motherDoc.reference;

        // a) Kalbeverlauf bei der Mutter hinzufügen
        DocumentReference historyRef = motherRef
            .collection('calving_history')
            .doc();
        batch.set(historyRef, calvingDetails.toMap());

        // b) Laktationsnummer der Mutter erhöhen
        batch.update(motherRef, {
          'lactationNumber': FieldValue.increment(1),
          // Optional: Letztes Kalbedatum setzen, falls im Animal Model vorhanden
        });
      }
    }

    return batch.commit();
  }

  Future<void> updateAnimal(String animalId, Map<String, dynamic> data) {
    return _db.collection('animals').doc(animalId).update(data);
  }

  // --- 2. SUB-COLLECTIONS (Historie) ---

  Stream<List<MilkYield>> getMilkYields(String animalId) {
    return _db
        .collection('animals')
        .doc(animalId)
        .collection('milk_yields')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            return MilkYield(
              id: doc.id, // Jetzt mit ID
              date: (data['date'] as Timestamp).toDate(),
              amountLiters: (data['amountLiters'] as num).toDouble(),
              session: data['session'] ?? '',
            );
          }).toList(),
        );
  }

  Future<void> addMilkYield(String animalId, MilkYield record) {
    return _db
        .collection('animals')
        .doc(animalId)
        .collection('milk_yields')
        .add(record.toMap());
  }

  Stream<List<MedicalRecord>> getMedicalRecords(String animalId) {
    return _db
        .collection('animals')
        .doc(animalId)
        .collection('medical_records')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            return MedicalRecord(
              id: doc.id, // ID zum Bearbeiten/Löschen
              date: (data['date'] as Timestamp).toDate(),
              diagnosis: data['diagnosis'] ?? '',
              treatment: data['treatment'] ?? '',
              // Neue Felder:
              cost: (data['cost'] ?? 0.0).toDouble(),
              veterinarian: data['veterinarian'] ?? '',
              followUpDate: data['followUpDate'] != null
                  ? (data['followUpDate'] as Timestamp).toDate()
                  : null,
              notes: data['notes'] ?? '',
            );
          }).toList(),
        );
  }

  Future<void> addMedicalRecord(String animalId, MedicalRecord record) {
    return _db
        .collection('animals')
        .doc(animalId)
        .collection('medical_records')
        .add(record.toMap());
  }

  Stream<List<CalvingHistory>> getCalvingHistory(String animalId) {
    return _db
        .collection('animals')
        .doc(animalId)
        .collection('calving_history')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            return CalvingHistory(
              id: doc.id, // ID hinzugefügt
              date: (data['date'] as Timestamp).toDate(),
              calvingCourse: data['calvingCourse'] ?? '',
              calfCount: data['calfCount'] ?? '1',
            );
          }).toList(),
        );
  }

  // Diese Methode bleibt für manuelle Einträge ohne Kalb-Erstellung erhalten
  Future<void> addCalvingEvent(String animalId, CalvingHistory event) {
    final animalRef = _db.collection('animals').doc(animalId);
    final historyRef = animalRef.collection('calving_history').doc();

    WriteBatch batch = _db.batch();
    batch.set(historyRef, event.toMap());
    batch.update(animalRef, {'lactationNumber': FieldValue.increment(1)});

    return batch.commit();
  }

  // --- 3. AUFGABEN (TASKS) ---

  Stream<List<FarmTask>> getTasks() {
    return _db
        .collection('tasks')
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => FarmTask.fromFirestore(doc)).toList(),
        );
  }

  Future<String> addTask(FarmTask task) async {
    final doc = await _db.collection('tasks').add(task.toMap());
    return doc.id;
  }

  Future<void> updateTask(FarmTask task) {
    return _db.collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> toggleTaskStatus(String taskId, bool currentStatus) {
    return _db.collection('tasks').doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }

  Future<void> deleteTask(String taskId) {
    return _db.collection('tasks').doc(taskId).delete();
  }

  // Füge dies zu deiner DatabaseService Klasse hinzu

  // 1. Alle Milchdaten aller Tiere abrufen (erfordert einen Index in Firebase!)
  Stream<List<MilkYield>> getAllMilkYields() {
    return _db
        .collectionGroup(
          'milk_yields',
        ) // Sucht in allen 'milk_yields' Unterkollektionen
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            return MilkYield(
              date: (data['date'] as Timestamp).toDate(),
              amountLiters: (data['amountLiters'] as num).toDouble(),
              session: data['session'] ?? '',
              id: doc.id, // ID hinzugefügt
            );
          }).toList(),
        );
  }

  // 2. Die Gesamtmenge für den Hof speichern
  Future<void> setFarmMilkTotal(DateTime date, double amount) {
    String dateId = DateFormat('yyyy-MM-dd').format(date);
    return _db.collection('farm_milk_totals').doc(dateId).set({
      'date': Timestamp.fromDate(date),
      'totalAmount': amount,
      'ownerId': userId, // Wichtig für die Sicherheit
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 3. (Optional) Abruf der manuell eingetragenen Hof-Gesamtmengen
  // In der Klasse DatabaseService hinzufügen:
  Stream<List<Map<String, dynamic>>> getFarmMilkTotals() {
    return _db
        .collection('farm_milk_totals')
        .orderBy('date', descending: true)
        .limit(14) // Wir holen etwas mehr, um sicherzugehen
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  // --- MILCH ---
  Future<void> updateMilkYield(String animalId, MilkYield record) {
    return _db.collection('animals').doc(animalId).collection('milk_yields').doc(record.id).update(record.toMap());
  }

  Future<void> deleteMilkYield(String animalId, String recordId) {
    return _db.collection('animals').doc(animalId).collection('milk_yields').doc(recordId).delete();
  }

  // --- GESUNDHEIT (MEDICAL) ---
  Future<void> updateMedicalRecord(String animalId, MedicalRecord record) {
    return _db.collection('animals').doc(animalId).collection('medical_records').doc(record.id).update(record.toMap());
  }

  Future<void> deleteMedicalRecord(String animalId, String recordId) {
    return _db.collection('animals').doc(animalId).collection('medical_records').doc(recordId).delete();
  }

  // --- KALBUNG ---
  Future<void> updateCalvingHistory(String animalId, CalvingHistory record) {
    return _db.collection('animals').doc(animalId).collection('calving_history').doc(record.id).update(record.toMap());
  }

  Future<void> deleteCalvingHistory(String animalId, String recordId) {
    return _db.collection('animals').doc(animalId).collection('calving_history').doc(recordId).delete();
  }
}
