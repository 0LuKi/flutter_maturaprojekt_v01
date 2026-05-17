import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/animal.dart';
import '../../services/database_service.dart';
import '../../utilities/reproduction_calculator.dart';
import '../cow_detail.dart';

class ReproductionOverviewPage extends StatefulWidget {
  const ReproductionOverviewPage({super.key});

  @override
  State<ReproductionOverviewPage> createState() =>
      _ReproductionOverviewPageState();
}

class _ReproductionOverviewPageState extends State<ReproductionOverviewPage> {
  String _activeFilter = 'alle';

  // Hilfsmethode für die Status-Farben (konsistent mit CowList)
  Color _getReproColor(String status) {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      // Hintergrundfarbe wie im Dashboard und Livestock-Bereich
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Reproduktion Dashboard'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor:
            Colors.transparent, // Verhindert Verfärbung beim Scrollen
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _filterChip('Alle', 'alle'),
                _filterChip('Brünstig', 'brunst'),
                _filterChip('Kalbung', 'kalbung'),
                _filterChip('Trockenstellen', 'trocken'),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('animals').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Fehler: ${snapshot.error}"));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          // Kälber ausblenden
          var animals = snapshot.data!.docs
              .map((doc) => Animal.fromFirestore(doc))
              .where((a) => !a.isCalf)
              .toList();

          // Filter-Logik
          if (_activeFilter == 'brunst') {
            animals = animals.where((a) => a.reproStatus == 'offen').toList();
          } else if (_activeFilter == 'kalbung') {
            animals = animals
                .where((a) => a.expectedCalvingDate != null)
                .toList();
          } else if (_activeFilter == 'trocken') {
            animals = animals
                .where(
                  (a) =>
                      a.reproStatus == 'traechtig' ||
                      a.reproStatus == 'trocken',
                )
                .toList();
          }

          if (animals.isEmpty) {
            return Center(
              child: Text(
                "Keine Tiere gefunden.",
                style: TextStyle(color: colorScheme.outline),
              ),
            );
          }

          // Sortierung
          animals.sort((a, b) {
            if (a.expectedCalvingDate == null) return 1;
            if (b.expectedCalvingDate == null) return -1;
            return a.expectedCalvingDate!.compareTo(b.expectedCalvingDate!);
          });

          return ListView.builder(
            itemCount: animals.length,
            // Einrückung (20) wie in CowList und Appointments
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemBuilder: (context, index) {
              final animal = animals[index];
              final statusColor = _getReproColor(animal.reproStatus);

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                // ANPASSUNG: Gleiche Farbe und Transparenz wie in der CowList
                color: colorScheme.surfaceContainerHigh.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(MdiIcons.cow, color: statusColor, size: 20),
                  ),
                  title: Text(
                    animal.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    ReproductionCalculator.mapStatusToGerman(
                      animal.reproStatus,
                    ),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  trailing: _buildTrailingInfo(animal, colorScheme),
                  onTap: () {
                    if (userId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CowDetail(
                            animal: animal,
                            dbService: DatabaseService(userId: userId),
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, String filterValue) {
    final isSelected = _activeFilter == filterValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _activeFilter = filterValue);
        },
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildTrailingInfo(Animal animal, ColorScheme colorScheme) {
    // Wenn ein Kalbetermin feststeht (Status belegt, trächtig, trocken)
    if (animal.expectedCalvingDate != null) {
      final days = animal.expectedCalvingDate!
          .difference(DateTime.now())
          .inDays;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "Kalbung",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          Text(
            days < 0 ? "Überfällig" : "in $days Tg.",
            style: TextStyle(
              color: days < 14 ? Colors.red : colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    if (animal.reproStatus == 'offen') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "Status",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const Text(
            "Bereit",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return const Icon(Icons.chevron_right, size: 20, color: Colors.grey);
  }
}
