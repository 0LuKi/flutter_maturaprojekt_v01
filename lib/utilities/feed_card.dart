import 'package:flutter/material.dart';
import '../models/feed_item.dart';
import 'feed_edit_dialog.dart';
import 'feed_consumption_chart.dart';

class FeedCard extends StatelessWidget {
  final FeedItem feed;

  const FeedCard({Key? key, required this.feed}) : super(key: key);

  Color _getReachColor(int days) {
    if (days < 10) return Colors.red;
    if (days <= 30) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final reachColor = _getReachColor(feed.daysRemaining);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0, // Schatten entfernt
      color: colorScheme.surfaceContainer, // Exakt wie bei den Terminen
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Ein feiner Rand zur Abgrenzung ohne harten Schatten
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Theme(
        // Verhindert die Standard-Trennlinien des ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            feed.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            'Bestand: ${feed.currentStock.toStringAsFixed(1)} ${feed.unit}',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: reachColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: reachColor, width: 1.5),
            ),
            child: Text(
              '${feed.daysRemaining} Tage',
              style: TextStyle(
                color: reachColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Warnschwelle: ${feed.minThreshold} ${feed.unit}'),
                      Text('Ø: ${feed.dailyConsumption} ${feed.unit}/Tag'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: FeedConsumptionChart(
                      history: feed.consumptionHistory,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilledButton.icon(
                        onPressed: () =>
                            _showEditDialog(context, isConsumption: false),
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        label: const Text('Auffüllen'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green.withOpacity(0.8),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () =>
                            _showEditDialog(context, isConsumption: true),
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        label: const Text('Verbrauch'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, {required bool isConsumption}) {
    showDialog(
      context: context,
      builder: (context) =>
          FeedEditDialog(feed: feed, isConsumption: isConsumption),
    );
  }
}
