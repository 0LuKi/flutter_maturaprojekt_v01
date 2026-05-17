import 'package:flutter/material.dart';
import '../models/feed_item.dart';
import '../services/feed_service.dart';
import '../utilities/feed_card.dart';
import 'add_feed_page.dart';

class FeedOverviewPage extends StatefulWidget {
  const FeedOverviewPage({Key? key}) : super(key: key);

  @override
  State<FeedOverviewPage> createState() => _FeedOverviewPageState();
}

class _FeedOverviewPageState extends State<FeedOverviewPage> {
  final FeedService _feedService = FeedService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Listener hinzufügen, um die Liste bei jeder Eingabe zu aktualisieren
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
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Futterverwaltung',
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
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // --- SUCHLEISTE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Futter suchen...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: colorScheme.surfaceContainer, // HELLER gemacht
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- LISTEN-BEREICH ---
            Expanded(
              child: StreamBuilder<List<FeedItem>>(
                stream: _feedService.getFeedsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Fehler: ${snapshot.error}'));
                  }

                  final allFeeds = snapshot.data ?? [];

                  // Filtern der Liste basierend auf der Suchanfrage
                  final filteredFeeds = allFeeds.where((feed) {
                    return feed.name.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredFeeds.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Keine Futterdaten vorhanden.'
                            : 'Kein Futter mit dem Namen "$_searchQuery" gefunden.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    );
                  }

                  final criticalFeeds = filteredFeeds
                      .where((f) => f.currentStock < f.minThreshold)
                      .toList();

                  return Column(
                    children: [
                      if (criticalFeeds.isNotEmpty && _searchQuery.isEmpty)
                        _buildWarningBanner(context, criticalFeeds),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 90),
                          itemCount: filteredFeeds.length,
                          itemBuilder: (context, index) =>
                              FeedCard(feed: filteredFeeds[index]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddFeedPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Neues Futter'),
      ),
    );
  }

  Widget _buildWarningBanner(
    BuildContext context,
    List<FeedItem> criticalFeeds,
  ) {
    final names = criticalFeeds.map((f) => f.name).join(', ');
    return MaterialBanner(
      padding: const EdgeInsets.all(16),
      content: Text(
        'Achtung! Kritischer Bestand bei: $names',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      backgroundColor: Colors.redAccent,
      actions: [
        TextButton(
          onPressed: () =>
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          child: const Text(
            'VERSTANDEN',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
