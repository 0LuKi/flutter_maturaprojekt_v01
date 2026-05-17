import 'package:cloud_firestore/cloud_firestore.dart';

class FeedItem {
  final String id;
  final String name;
  final double currentStock;
  final double dailyConsumption; // Geschätzter Tagesverbrauch zur Prognose
  final String unit;
  final double minThreshold;
  final Map<String, double>
  consumptionHistory; // Datum (YYYY-MM-DD) -> Verbrauch

  FeedItem({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.dailyConsumption,
    required this.unit,
    required this.minThreshold,
    required this.consumptionHistory,
  });

  // Automatische Berechnung der Reichweite in Tagen
  int get daysRemaining {
    if (dailyConsumption <= 0)
      return 999; // Unendliche Reichweite, falls kein Verbrauch
    return (currentStock / dailyConsumption).floor();
  }

  factory FeedItem.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedItem(
      id: doc.id,
      name: data['name'] ?? '',
      currentStock: (data['currentStock'] ?? 0).toDouble(),
      dailyConsumption: (data['dailyConsumption'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'kg',
      minThreshold: (data['minThreshold'] ?? 0).toDouble(),
      consumptionHistory: Map<String, double>.from(
        data['consumptionHistory'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'currentStock': currentStock,
      'dailyConsumption': dailyConsumption,
      'unit': unit,
      'minThreshold': minThreshold,
      'consumptionHistory': consumptionHistory,
    };
  }

  FeedItem copyWith({
    String? id,
    String? name,
    double? currentStock,
    double? dailyConsumption,
    String? unit,
    double? minThreshold,
    Map<String, double>? consumptionHistory,
  }) {
    return FeedItem(
      id: id ?? this.id,
      name: name ?? this.name,
      currentStock: currentStock ?? this.currentStock,
      dailyConsumption: dailyConsumption ?? this.dailyConsumption,
      unit: unit ?? this.unit,
      minThreshold: minThreshold ?? this.minThreshold,
      consumptionHistory: consumptionHistory ?? this.consumptionHistory,
    );
  }
}
