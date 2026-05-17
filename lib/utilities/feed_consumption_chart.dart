import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FeedConsumptionChart extends StatelessWidget {
  final Map<String, double> history;

  const FeedConsumptionChart({Key? key, required this.history})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generiere Daten für die letzten 7 Tage
    final spots = <FlSpot>[];
    final today = DateTime.now();
    double maxY = 0;

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateString = date.toIso8601String().split('T').first;

      final amount = history[dateString] ?? 0.0;
      if (amount > maxY) maxY = amount;

      // X-Achse: 0 = vor 6 Tagen, 6 = Heute
      spots.add(FlSpot((6 - i).toDouble(), amount));
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 10 : maxY * 1.2, // Puffer nach oben
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // X-Achsen Beschriftung
                if (value.toInt() == 0)
                  return const Text('Vor 6T', style: TextStyle(fontSize: 10));
                if (value.toInt() == 6)
                  return const Text('Heute', style: TextStyle(fontSize: 10));
                return const Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
