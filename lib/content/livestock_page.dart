// lib/content/livestock_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/add_animal_page.dart';
import 'package:flutter_maturaprojekt_v01/content/cow_list.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';

class LivestockPage extends StatefulWidget {
  final DatabaseService dbService;

  const LivestockPage({super.key, required this.dbService});

  @override
  State<LivestockPage> createState() => _LivestockPageState();
}

class _LivestockPageState extends State<LivestockPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Viehbestand',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  ),
                ],
              ),
            ),
            // Suchleiste (Farbe angepasst)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tier suchen (Name oder Nr.)',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor:
                      colorScheme.surfaceContainer, // Hellerer Hintergrund
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Liste
            Expanded(
              child: CowList(
                dbService: widget.dbService,
                searchQuery: _searchQuery, // Suchanfrage weitergeben
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddAnimalPage(dbService: widget.dbService),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tier hinzufügen'),
      ),
    );
  }
}
