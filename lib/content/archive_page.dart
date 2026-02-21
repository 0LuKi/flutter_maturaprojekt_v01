import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // NEU: Für die Galerie
import 'package:path_provider/path_provider.dart'; // NEU: Zum lokalen Speichern
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'package:flutter_maturaprojekt_v01/models/farm_document.dart';
import 'document_scan_page.dart';

class ArchivePage extends StatefulWidget {
  final DatabaseService dbService;

  const ArchivePage({super.key, required this.dbService});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  String _searchQuery = '';
  final ImagePicker _picker = ImagePicker(); // Der Picker für die Galerie

  // NEU: Dialog zum Eingeben des Namens beim Importieren
  Future<String?> _askForDocumentName() async {
    final TextEditingController nameController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dokument benennen'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'z.B. Lieferschein',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim().isEmpty
                    ? 'Importiertes Dokument'
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

  // NEU: Bild aus der Galerie importieren
  Future<void> _importFromGallery() async {
    try {
      // 1. Bild aus der Galerie auswählen
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Auch hier leicht komprimieren
      );

      if (picked == null) return; // Abgebrochen

      // 2. Nach dem Namen fragen
      final documentName = await _askForDocumentName();
      if (documentName == null) return; // Wenn kein Name, dann abbrechen

      // Ladekreis anzeigen, während kopiert und gespeichert wird
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 3. Bild in den sicheren App-Ordner kopieren
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'import_${timestamp}_${picked.name}';
      final localPath = '${directory.path}/$fileName';

      final File savedImage = await File(picked.path).copy(localPath);

      // 4. In der Datenbank speichern (Kategorie: Import)
      await widget.dbService.addFarmDocument(
        title: documentName,
        category: 'Import', // Eigene Kategorie für importierte Bilder!
        storageUrl: savedImage.path,
      );

      // Ladekreis schließen
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dokument erfolgreich importiert!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Ladekreis schließen bei Fehler
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Importieren: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteDocument(FarmDocument document) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Löschen?'),
            content: const Text(
              'Möchtest du dieses Dokument wirklich löschen?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Löschen',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      final file = File(document.storageUrl);
      if (await file.exists()) await file.delete();
      await widget.dbService.deleteFarmDocument(document.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gelöscht'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archiv')),

      // NEU: Eine Column für ZWEI Floating Action Buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end, // Unten ausrichten
        crossAxisAlignment: CrossAxisAlignment.end, // Rechtsbündig
        children: [
          // 1. Button: Importieren
          FloatingActionButton.extended(
            heroTag:
                'importBtn', // WICHTIG: Wenn es zwei FABs gibt, brauchen sie einen eigenen heroTag
            onPressed: _importFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('Importieren'),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(height: 16), // Abstand zwischen den Buttons
          // 2. Button: Scannen
          FloatingActionButton.extended(
            heroTag: 'scanBtn',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DocumentScanPage(dbService: widget.dbService),
                ),
              );
            },
            icon: const Icon(Icons.document_scanner),
            label: const Text('Neuer Scan'),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Nach Dokumenten suchen...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FarmDocument>>(
              stream: widget.dbService.getFarmDocuments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Fehler beim Laden: ${snapshot.error}'),
                  );
                }

                final documents = snapshot.data ?? [];

                final filteredDocuments = documents.where((doc) {
                  return doc.title.toLowerCase().contains(_searchQuery);
                }).toList();

                if (documents.isEmpty) {
                  return const Center(
                    child: Text('Keine Dokumente im Archiv.'),
                  );
                }

                if (filteredDocuments.isEmpty) {
                  return const Center(child: Text('Keine Dokumente gefunden.'));
                }

                Map<String, List<FarmDocument>> folders = {};
                for (var doc in filteredDocuments) {
                  final category = doc.category;
                  if (!folders.containsKey(category)) {
                    folders[category] = [];
                  }
                  folders[category]!.add(doc);
                }

                return ListView.builder(
                  itemCount: folders.keys.length,
                  itemBuilder: (context, index) {
                    String categoryName = folders.keys.elementAt(index);
                    List<FarmDocument> docsInFolder = folders[categoryName]!;

                    return ExpansionTile(
                      initiallyExpanded: _searchQuery.isNotEmpty,
                      leading: const Icon(
                        Icons.folder,
                        color: Colors.blueAccent,
                        size: 36,
                      ),
                      title: Text(
                        categoryName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text('${docsInFolder.length} Dokument(e)'),
                      children: docsInFolder.map((doc) {
                        return ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(doc.title),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteDocument(doc),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DocumentViewerPage(
                                  imagePath: doc.storageUrl,
                                  title: doc.title,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentViewerPage extends StatelessWidget {
  final String imagePath;
  final String title;

  const DocumentViewerPage({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Bilddatei lokal nicht gefunden.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
