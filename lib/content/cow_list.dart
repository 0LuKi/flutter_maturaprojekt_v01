import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/cow_detail.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/models/animal.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CowList extends StatefulWidget {
  final DatabaseService dbService;

  const CowList({
    super.key,
    required this.dbService,
  });

  @override
  State<CowList> createState() => _CowListState();
}

class _CowListState extends State<CowList> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<Animal>>(
      stream: widget.dbService.getAnimals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("${loc.error}: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(MdiIcons.cowOff, size: 64, color: colorScheme.surfaceContainerLow),
                const SizedBox(height: 16),
                Text(loc.no_cows_found, style: TextStyle(color: colorScheme.outline, fontSize: 16)),
              ],
            ),
          );
        }

        final animals = snapshot.data!;

        return ListView.builder(
          itemCount: animals.length,
          padding: const EdgeInsets.only(bottom: 80),
          itemBuilder: (context, index) {
            final animal = animals[index];
            return CowCard(
              animal: animal,
              dbService: widget.dbService,
            );
          },
        );
      },
    );
  }
}

class CowCard extends StatelessWidget {
  final Animal animal;
  final DatabaseService? dbService;

  const CowCard({
    super.key,
    required this.animal,
    required this.dbService,
  });

  void _confirmDelete(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.delete_cow),
          content: Text("${loc.delete_cow_conf}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); 
                await dbService?.deleteAnimal(animal.id);
              },
              child: Text(loc.delete, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    // Design matches the AppointmentList/TaskCard logic
    // Highlight if calf (similar to overdue in tasks), otherwise standard surface
    final isSpecial = animal.isCalf;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6), // Align with modern flat lists
      color: isSpecial ? Colors.orange[50] : colorScheme.surfaceContainerHigh.withOpacity(0.3),
      elevation: 0, // Flat design preferred in modern M3
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSpecial ? Colors.orange[200] : colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            animal.isCalf ? MdiIcons.babyCarriage : MdiIcons.cow,
            color: isSpecial ? Colors.deepOrange : colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          animal.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              animal.earTagNumber.isNotEmpty
                  ? '${loc.et}: ${animal.earTagNumber}'
                  : loc.no_eartag,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!animal.isCalf)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${animal.lactationNumber}. Lakt.',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error.withOpacity(0.7)),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CowDetail(
                animal: animal,
                dbService: dbService!,
              ),
            ),
          );
        },
      ),
    );
  }
}