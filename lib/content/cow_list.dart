import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/cow_detail.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/models/animal.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CowList extends StatefulWidget {
  const CowList({super.key});

  @override
  State<CowList> createState() => _CowListState();
}

class _CowListState extends State<CowList> {
  DatabaseService? _dbService;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  void _initService() {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      setState(() {
        _dbService = DatabaseService(userId: user.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final colorScheme = Theme.of(context).colorScheme;

    // Ladekreis, wenn Service nicht bereit
    if (_dbService == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: StreamBuilder<List<Animal>>(
        stream: _dbService?.getAnimals(),
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
                  Text(loc.no_cows_found),
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
                dbService: _dbService
              );
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAnimalDialog(context, loc, _dbService),
        label: Text(loc.add_cow),
        icon: const Icon(Icons.add),
        backgroundColor: colorScheme.primaryContainer,
      ),
    );
  }
}


void _showAddAnimalDialog(BuildContext context, AppLocalizations loc, DatabaseService? dbService) {
  final nameController = TextEditingController();
  final earTagController = TextEditingController();
  bool isCalf = false;

  showDialog(
    context: context, 
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(loc.add_cow),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: loc.cow_name,
                      prefixIcon: Icon(MdiIcons.cow),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: earTagController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: loc.eartagnumber,
                      prefixIcon: const Icon(Icons.confirmation_num),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: isCalf, 
                    onChanged: (val) => setState(() => isCalf = val),
                    title: Text("${loc.calf}?"),
                    secondary: Icon(isCalf ? MdiIcons.babyCarriage : MdiIcons.cow)
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: Text(loc.cancel),
              ),
              FilledButton(
                onPressed: () {
                  if (nameController.text.isEmpty) return;

                  final newAnimal = Animal(
                    id: '',
                    name: nameController.text,
                    earTagNumber: earTagController.text,
                    birthDate: DateTime.now(), // NUR FÜR DEMO
                    isCalf: isCalf,
                    lactationNumber: 0
                  );

                  dbService!.addAnimal(newAnimal);
                  Navigator.pop(context);
                }, 
                child: Text(loc.save)
              )
            ],
          );
        }
      );
    }
  );
}

class CowCard extends StatelessWidget {
  final Animal animal;
  final DatabaseService? dbService;

  const CowCard({
    super.key, 
    required this.animal, 
    required this.dbService
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
              Navigator.pop(context); // close dialog first
              
              await dbService?.deleteAnimal(animal.id);
            },
            child: Text(loc.delete, style: TextStyle(color: Colors.red)),
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: animal.isCalf ? Colors.orange[50] : colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: animal.isCalf ? Colors.orange[200] : colorScheme.primaryContainer,
          child: Icon(
            animal.isCalf ? MdiIcons.babyCarriage : MdiIcons.cow,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          animal.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          animal.earTagNumber.isNotEmpty 
            ? '${loc.et}: ${animal.earTagNumber}' 
            : loc.no_eartag,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!animal.isCalf)
              Chip(
                label: Text('${animal.lactationNumber}'),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                backgroundColor: Colors.white54,
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
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
                dbService: dbService,
              )
            )
          );
        },
      ),
    );
  }
}