import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/animal.dart';
import '../models/calving_history.dart';
import '../models/milk_yield.dart';
import '../models/medical_record.dart';
import '../models/farm_task.dart';

class DatabaseService {
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
        .map((snapshot) =>
            snapshot.docs.map((doc) => Animal.fromFirestore(doc)).toList());
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
        DocumentReference historyRef = motherRef.collection('calving_history').doc();
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
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              return MilkYield(
                date: (data['date'] as Timestamp).toDate(),
                amountLiters: (data['amountLiters'] as num).toDouble(),
                session: data['session'] ?? '',
              );
            }).toList());
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
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              return MedicalRecord(
                date: (data['date'] as Timestamp).toDate(),
                diagnosis: data['diagnosis'] ?? '',
                treatment: data['treatment'] ?? '',
              );
            }).toList());
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
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              return CalvingHistory(
                date: (data['date'] as Timestamp).toDate(),
                calvingCourse: data['calvingCourse'] ?? '',
                calfCount: data['calfCount'] ?? '1', // String handling safe
              );
            }).toList());
  }

  // Diese Methode bleibt für manuelle Einträge ohne Kalb-Erstellung erhalten
  Future<void> addCalvingEvent(String animalId, CalvingHistory event) {
    final animalRef = _db.collection('animals').doc(animalId);
    final historyRef = animalRef.collection('calving_history').doc();

    WriteBatch batch = _db.batch();
    batch.set(historyRef, event.toMap());
    batch.update(animalRef, {
      'lactationNumber': FieldValue.increment(1),
    });

    return batch.commit();
  }
  
  // --- 3. AUFGABEN (TASKS) ---
  
  Stream<List<FarmTask>> getTasks() {
    return _db
        .collection('tasks')
        .orderBy('dueDate')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => FarmTask.fromFirestore(doc)).toList());
  }
  
  Future<void> addTask(FarmTask task) {
    return _db.collection('tasks').add(task.toMap());
  }
  
  Future<void> toggleTaskStatus(String taskId, bool currentStatus) {
    return _db.collection('tasks').doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }
  
  Future<void> deleteTask(String taskId) {
    return _db.collection('tasks').doc(taskId).delete();
  }
}