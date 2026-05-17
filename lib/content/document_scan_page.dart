import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'package:flutter_maturaprojekt_v01/models/animal.dart'; // NEU importiert

class DocumentScanPage extends StatefulWidget {
  final DatabaseService dbService;
  final String?
  defaultAnimalId; // NEU: Falls man von einer Tier-Detailseite kommt

  const DocumentScanPage({
    super.key,
    required this.dbService,
    this.defaultAnimalId,
  });

  @override
  State<DocumentScanPage> createState() => _DocumentScanPageState();
}

class _DocumentScanPageState extends State<DocumentScanPage> {
  final ImagePicker picker = ImagePicker();
  bool _isSaving = false;

  // Gibt jetzt eine Map mit dem Namen und der optionalen Tier-ID zurück
  Future<Map<String, dynamic>?> _askForDocumentName() async {
    final TextEditingController nameController = TextEditingController();
    String? selectedAnimalId = widget.defaultAnimalId;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // StatefulBuilder, damit sich das Dropdown im Dialog aktualisieren lässt
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Dokument speichern'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'z.B. Tierarzt Rechnung',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // NEU: Dropdown zur Tierauswahl
                  StreamBuilder<List<Animal>>(
                    stream: widget.dbService.getAnimals(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      final animals = snapshot.data ?? [];

                      return DropdownButtonFormField<String?>(
                        value: selectedAnimalId,
                        isExpanded:
                            true, // <-- NEU: Zwingt das Dropdown, in der Box zu bleiben
                        decoration: const InputDecoration(
                          labelText: 'Tier zuordnen (optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text(
                              'Kein Tier (Allgemein)',
                              overflow: TextOverflow
                                  .ellipsis, // <-- NEU: Verhindert Text-Überlauf
                            ),
                          ),
                          ...animals.map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(
                                '${a.name} (${a.earTagNumber})',
                                overflow: TextOverflow
                                    .ellipsis, // <-- NEU: Kürzt lange Namen mit "..."
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setStateDialog(() {
                            selectedAnimalId = val;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim().isEmpty
                        ? 'Unbenanntes Dokument'
                        : nameController.text.trim();

                    Navigator.pop(context, {
                      'name': name,
                      'animalId': selectedAnimalId,
                    });
                  },
                  child: const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _scanAndSaveLocally() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (picked == null) return;

      // Map mit Namen und Tier-ID abrufen
      final result = await _askForDocumentName();

      if (result == null) return;

      setState(() => _isSaving = true);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'scan_${timestamp}_${picked.name}';
      final localPath = '${directory.path}/$fileName';
      final File savedImage = await File(picked.path).copy(localPath);

      // Daten inklusive animalId an Firebase senden
      await widget.dbService.addFarmDocument(
        title: result['name'],
        category: 'Scan',
        storageUrl: savedImage.path,
        animalId: result['animalId'], // NEU: Speichert die Tierzuordnung
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dokument gespeichert!'),
          backgroundColor: Colors.green,
        ),
      );

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
