import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseSeeder {
  // ... Deine bestehende seedTwentyCows() Funktion bleibt hier ...

  /// NEU: Generiert 5 Kälber und verknüpft sie mit bestehenden Kühen
  static Future<void> seedFiveCalves() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ Fehler: Du musst eingeloggt sein!');
      return;
    }
    final userId = user.uid;
    final firestore = FirebaseFirestore.instance;

    // 1. Hole 5 bestehende, ausgewachsene Kühe des Users
    final cowsSnapshot = await firestore
        .collection('animals')
        .where('ownerId', isEqualTo: userId)
        .where('isCalf', isEqualTo: false)
        .limit(5)
        .get();

    if (cowsSnapshot.docs.isEmpty) {
      print('❌ Keine Mütter gefunden! Bitte zuerst Kühe generieren.');
      return;
    }

    final batch = firestore.batch();
    final random = Random();
    
    // Typische Kälbernamen
    final maleNames = ['Bubi', 'Ferdinand', 'Leo', 'Max', 'Moritz', 'Samson'];
    final femaleNames = ['Mia', 'Lilly', 'Flora', 'Susi', 'Stella', 'Luna'];

    for (var cowDoc in cowsSnapshot.docs) {
      final motherData = cowDoc.data();
      final motherId = cowDoc.id;
      final motherBreed = motherData['breed'] ?? 'Unbekannt';

      // 2. Kalb-Daten vorbereiten
      final isFemale = random.nextBool(); // Zufällig männlich oder weiblich
      final name = isFemale 
          ? femaleNames[random.nextInt(femaleNames.length)] 
          : maleNames[random.nextInt(maleNames.length)];
          
      final tag = 'AT ${100 + random.nextInt(899)} ${random.nextInt(1000).toString().padLeft(3, '0')} ${random.nextInt(1000).toString().padLeft(3, '0')}';
      
      // Geboren in den letzten 14 Tagen
      final birthDate = DateTime.now().subtract(Duration(days: random.nextInt(14)));

      final calfRef = firestore.collection('animals').doc();
      final calfData = {
        'id': calfRef.id,
        'name': name,
        'breed': motherBreed, // Kalb hat meist die gleiche Rasse wie die Mutter
        'earTagNumber': tag,
        'birthDate': Timestamp.fromDate(birthDate),
        'gender': isFemale ? 'Weiblich' : 'Männlich',
        'isCalf': true, // WICHTIG: Als Kalb markieren
        'motherId': motherId, // WICHTIG: Die Verknüpfung zur Mutter!
        'ownerId': userId,
      };

      // Kalb zum Batch hinzufügen
      batch.set(calfRef, calfData);

      // 3. Kalbeverlauf (Historie) bei der Mutter eintragen
      final historyRef = firestore
          .collection('animals')
          .doc(motherId)
          .collection('calving_history') // Subcollection bei der Mutter
          .doc();

      final historyData = {
        'date': Timestamp.fromDate(birthDate),
        'calvingCourse': 'Leicht (ohne Hilfe)', // Könnte man auch per Random variieren
        'calfCount': '1',
      };

      batch.set(historyRef, historyData);

      // 4. Laktationsnummer der Mutter updaten (+1)
      batch.update(cowDoc.reference, {
        'lactationNumber': FieldValue.increment(1),
      });
    }

    try {
      await batch.commit(); // Alles auf einmal an Firebase senden
      print('✅ 5 Kälber wurden erfolgreich generiert und mit den Müttern verknüpft!');
    } catch (e) {
      print('❌ Fehler beim Seeding der Kälber: $e');
    }
  }
}