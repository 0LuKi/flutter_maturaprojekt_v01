import 'package:flutter/material.dart';
import '../../models/reproduction_event.dart';
import '../../services/reproduction_service.dart';
import '../../utilities/reproduction_calculator.dart';
import 'add_repro_event_page.dart';
import 'package:intl/intl.dart';

class ReproductionTab extends StatelessWidget {
  final String animalId;
  final String animalName;
  final String currentStatus;
  final ReproductionService _reproService = ReproductionService();

  ReproductionTab({
    super.key,
    required this.animalId,
    required this.animalName,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 1. Status-Anzeige (Oben)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Aktueller Status",
                style: TextStyle(
                  color: colorScheme.outline,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                backgroundColor: _getStatusColor(currentStatus),
                side: BorderSide.none,
                label: Text(
                  ReproductionCalculator.mapStatusToGerman(currentStatus),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // 2. Zeitstrahl / Historie
        Expanded(
          child: StreamBuilder<List<ReproductionEvent>>(
            stream: _reproService.getReproHistory(animalId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Noch keine Ereignisse erfasst",
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ),
                );
              }

              final events = snapshot.data!;
              return ListView.builder(
                itemCount: events.length,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  80,
                ), // Padding unten für FAB
                itemBuilder: (context, index) {
                  final e = events[index];
                  return _buildTimelineItem(
                    context,
                    e,
                    colorScheme,
                    index == events.length - 1,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    ReproductionEvent e,
    ColorScheme colorScheme,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linke Seite: Icon und vertikale Linie
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: _getIconForType(e.type, colorScheme),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                )
              else
                const SizedBox(height: 24),
            ],
          ),
          const SizedBox(width: 16),

          // Rechte Seite: Inhalts-Karte
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _mapTypeToGerman(e.type),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Aktions-Menü für jedes Ereignis
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddReproEventPage(
                                  animalId: animalId,
                                  animalName: animalName,
                                  initialEvent:
                                      e, // Übergabe des Events zum Bearbeiten
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _confirmDeleteEvent(context, e.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('dd.MM.yyyy').format(e.date),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (e.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        e.note,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bestätigungsdialog für das Löschen
  void _confirmDeleteEvent(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ereignis löschen?"),
        content: const Text(
          "Möchtest du diesen Eintrag wirklich dauerhaft aus der Historie entfernen?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Abbrechen"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _reproService.deleteEvent(animalId, eventId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Löschen"),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'offen':
        return Colors.redAccent;
      case 'belegt':
        return Colors.orange;
      case 'traechtig':
        return Colors.green;
      case 'trocken':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  Icon _getIconForType(ReproEventType type, ColorScheme colorScheme) {
    switch (type) {
      case ReproEventType.besamung:
        return Icon(Icons.science, color: colorScheme.primary, size: 18);
      case ReproEventType.brunst:
        return const Icon(Icons.favorite, color: Colors.red, size: 18);
      case ReproEventType.kalbung:
        return const Icon(Icons.child_care, color: Colors.blue, size: 18);
      case ReproEventType.trockenstellen:
        return const Icon(
          Icons.water_drop_outlined,
          color: Colors.blueGrey,
          size: 18,
        );
    }
  }

  String _mapTypeToGerman(ReproEventType type) {
    switch (type) {
      case ReproEventType.besamung:
        return "Besamung";
      case ReproEventType.brunst:
        return "Brunst beobachtet";
      case ReproEventType.kalbung:
        return "Kalbung";
      case ReproEventType.trockenstellen:
        return "Trockenstellen";
    }
  }
}
