import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';

class DocumentScanPage extends StatefulWidget {
  final DatabaseService dbService;
  const DocumentScanPage({super.key, required this.dbService});

  @override
  State<DocumentScanPage> createState() => _DocumentScanPageState();
}

class _DocumentScanPageState extends State<DocumentScanPage> {
  final ImagePicker picker = ImagePicker();
  bool _isSaving = false;

  // NEU: Dialog zum Eingeben des Namens
  Future<String?> _askForDocumentName() async {
    final TextEditingController nameController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false, // Man muss einen Button drücken
      builder: (context) {
        return AlertDialog(
          title: const Text('Dokument benennen'),
          content: TextField(
            controller: nameController,
            autofocus: true, // Tastatur öffnet sich sofort
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'z.B. Tierarzt Rechnung',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, null), // Abbrechen gibt null zurück
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                // Wenn das Feld leer ist, einen Standardnamen vergeben
                final name = nameController.text.trim().isEmpty
                    ? 'Unbenanntes Dokument'
                    : nameController.text.trim();
                Navigator.pop(context, name);
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _scanAndSaveLocally() async {
    try {
      // 1. Foto aufnehmen
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (picked == null) return;

      // 2. NEU: Nach dem Namen fragen BEVOR gespeichert wird
      final documentName = await _askForDocumentName();

      // Wenn der Nutzer "Abbrechen" drückt, brechen wir den ganzen Vorgang ab
      if (documentName == null) return;

      setState(() => _isSaving = true);

      // 3. Bild lokal speichern
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'scan_${timestamp}_${picked.name}';
      final localPath = '${directory.path}/$fileName';
      final File savedImage = await File(picked.path).copy(localPath);

      // 4. In die Datenbank mit dem EINGEGEBENEN Namen speichern
      await widget.dbService.addFarmDocument(
        title: documentName, // <-- Hier nutzen wir jetzt die Eingabe
        category: 'Scan',
        storageUrl: savedImage.path,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dokument gespeichert!'),
          backgroundColor: Colors.green,
        ),
      );

      // Nach erfolgreichem Speichern gehen wir automatisch zurück zum Archiv
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dokument einscannen')),
      body: Center(
        child: _isSaving
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Dokument wird gespeichert...'),
                ],
              )
            : ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Kamera öffnen'),
                onPressed: _scanAndSaveLocally,
              ),
      ),
    );
  }
}
