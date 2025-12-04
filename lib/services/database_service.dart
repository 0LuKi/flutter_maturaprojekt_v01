import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_maturaprojekt_v01/models/animal.dart';
import 'package:flutter_maturaprojekt_v01/models/calving_history.dart';
import 'package:flutter_maturaprojekt_v01/models/farm_task.dart';
import 'package:flutter_maturaprojekt_v01/models/medical_record.dart';
import 'package:flutter_maturaprojekt_v01/models/milk_yield.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  DatabaseService({required this.userId}) {
    // Optional: Explicit offline persistence — safe guard in case already set.
    try {
      _db.settings = const Settings(persistenceEnabled: true);
    } catch (e) {
      // Persistence already set or not supported; ignore.
      // debugPrint('Could not set Firestore settings: $e');
    }
  }

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
                // Falls Ihr Model keine ID hat, lassen Sie das Feld weg
                date: (data['date'] as Timestamp).toDate(),
                amountLiters: (data['amountLiters'] as num).toDouble(),
                session: data['session'] ?? '',
              );
            }).toList());
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
                calfCount: data['calfCount'] ?? 1,
              );
            }).toList());
  }

  // Tiere

  // Alle Tiere laden
  Stream<List<Animal>> getAnimals() {
    return _db
        .collection('animals')
        .where('ownerId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Animal.fromFirestore(doc))
            .toList());
  }

  Stream<Animal> getAnimal(String animalId) {
    return _db
        .collection('animals')
        .doc(animalId)
        .snapshots()
        .map((doc) => Animal.fromFirestore(doc));
  }

  // Tier hinzufügen
  Future<void> addAnimal(Animal animal) {
    var data = animal.toMap();
    data['ownerId'] = userId;
    return _db.collection('animals').add(data);
  }

  Future<void> updateAnimal(String animalId, Map<String, dynamic> data) {
    return _db.collection('animals').doc(animalId).update(data);
  }

  // Histore des Tiers
  Future<void> addMilkYield(String animalId, MilkYield record) {
    return _db
        .collection('animals')
        .doc(animalId)
        .collection('milk_yields')
        .add(record.toMap());
  }

  Future<void> addMedicalRecord(String animalId, MedicalRecord record) {
    return _db
        .collection('animals')
        .doc(animalId)
        .collection('medical_records')
        .add(record.toMap());
  }

  Future<void> deleteAnimal(String animalId) {
    return _db
        .collection('animals')
        .doc(animalId)
        .delete();
  }

  // Kalbung hinzufügen und Laktationsnummer erhöhen
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

  // AUFGABEN

  Stream<List<FarmTask>> getTask() {
    return _db
        .collection('tasks')
        .where('ownerId', isEqualTo: userId) // ensure user-specific tasks
        .where('isCompleted', isEqualTo: false)
        .orderBy('dueDate')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => FarmTask.fromFirestore(doc)).toList());
  }

  Future<void> addTask(FarmTask task) {
    var data = task.toMap();
    data['ownerId'] = userId;
    return _db.collection('tasks').add(data);
  }

  Future<void> toggleTaskStatus(String taskId, bool currentStatus) {
    return _db.collection('tasks').doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }
}











