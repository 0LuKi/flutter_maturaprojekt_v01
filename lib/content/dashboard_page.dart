import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_maturaprojekt_v01/content/archive_page.dart';
import 'package:flutter_maturaprojekt_v01/models/milk_yield.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';
import 'package:flutter_maturaprojekt_v01/services/auth_service.dart';

import '../services/database_service.dart';
import '../models/animal.dart';
import '../models/farm_task.dart';
import 'reproduction/reproduction_overview_page.dart'; // NEU: Import für Reproduktion
import 'livestock_page.dart';
import 'cow_list.dart';
import 'appointments_page.dart';
import 'document_scan_page.dart';
import 'ear_tag_scanner_page.dart';
import 'feed_overview_page.dart';

class DashboardPage extends StatefulWidget {
  final Function(int)? changeTab;

  const DashboardPage({super.key, this.changeTab});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DatabaseService? _dbService;
  String _userName = '';
  StreamSubscription<User?>? _authSubscription;
  final AuthService _authService = AuthService();

  final TextEditingController _totalMilkController = TextEditingController();
  DateTime _selectedEntryDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _dbService = DatabaseService(userId: currentUser.uid);
      _userName = currentUser.displayName ?? 'Landwirt';
    }

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          if (user != null) {
            _dbService = DatabaseService(userId: user.uid);
            _userName = user.displayName ?? 'Landwirt';
          } else {
            _dbService = null;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _totalMilkController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: _dbService == null
            ? Center(
                child: FirebaseAuth.instance.currentUser == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 64,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Nicht angemeldet",
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Bitte starten Sie die App neu oder loggen Sie sich ein.",
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.login),
                            label: const Text("Zum Login"),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'EEEE, d. MMMM',
                                    'de_DE',
                                  ).format(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hallo, $_userName',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: isDesktop
                                  ? IconButton(
                                      onPressed: _signOut,
                                      tooltip: loc?.sign_out ?? "Logout",
                                      icon: const Icon(Icons.logout),
                                      color: colorScheme.error,
                                    )
                                  : IconButton(
                                      onPressed: () {
                                        try {
                                          Scaffold.of(context).openEndDrawer();
                                        } catch (e) {
                                          debugPrint("Kein Drawer gefunden");
                                        }
                                      },
                                      tooltip: loc?.menu ?? "Menu",
                                      icon: const Icon(Icons.menu_rounded),
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        _buildRealMilkChart(colorScheme),
                        const SizedBox(height: 10),
                        _buildTotalMilkInput(colorScheme),
                        const SizedBox(height: 30),
                        _buildStatusGrid(colorScheme),
                        const SizedBox(height: 30),
                        _buildUpcomingTasksList(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickTaskDialog(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add_task),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildRealMilkChart(ColorScheme colorScheme) {
    return StreamBuilder<List<MilkYield>>(
      stream: _dbService?.getAllMilkYields(),
      builder: (context, cowSnapshot) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _dbService?.getFarmMilkTotals(),
          builder: (context, farmSnapshot) {
            if (cowSnapshot.connectionState == ConnectionState.waiting ||
                farmSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 380,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            List<double> sums = List.filled(7, 0.0);
            List<bool> hasIndividualData = List.filled(7, false);

            DateTime startOfToday = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            );

            if (cowSnapshot.hasData) {
              for (var record in cowSnapshot.data!) {
                DateTime recordDate = DateTime(
                  record.date.year,
                  record.date.month,
                  record.date.day,
                );
                int diff = startOfToday.difference(recordDate).inDays;

                if (diff >= 0 && diff < 7) {
                  int dayIndex = record.date.weekday - 1;
                  sums[dayIndex] += record.amountLiters;
                  hasIndividualData[dayIndex] = true;
                }
              }
            }

            if (farmSnapshot.hasData) {
              for (var data in farmSnapshot.data!) {
                DateTime date = (data['date'] as Timestamp).toDate();
                DateTime recordDate = DateTime(date.year, date.month, date.day);
                int diff = startOfToday.difference(recordDate).inDays;

                if (diff >= 0 && diff < 7) {
                  int dayIndex = date.weekday - 1;
                  if (!hasIndividualData[dayIndex]) {
                    sums[dayIndex] = (data['totalAmount'] as num).toDouble();
                  }
                }
              }
            }

            double maxVal = sums.reduce((a, b) => a > b ? a : b);
            double axisMax = ((maxVal + 40) / 20).ceil() * 20.0;
            if (axisMax < 100) axisMax = 100;

            return Container(
              height: 380,
              padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: axisMax,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.white,
                      tooltipRoundedRadius: 12,
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        bool isHerd = hasIndividualData[group.x.toInt()];
                        String prefix = isHerd ? "Herde:" : "Tank:";

                        return BarTooltipItem(
                          '$prefix\n${rod.toY.toInt()} L',
                          const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        );
                      },
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
                          if (value >= 0 && value < 7) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 15,
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: List.generate(7, (index) {
                    Color barColor = hasIndividualData[index]
                        ? colorScheme.primary
                        : Colors.blueAccent;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: sums[index],
                          color: barColor,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: axisMax,
                            color: colorScheme.surfaceContainerHighest
                                .withOpacity(0.4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusGrid(ColorScheme colorScheme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        StreamBuilder<List<Animal>>(
          stream: _dbService!.getAnimals(),
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;
            return _DashboardCard(
              title: 'Herde',
              value: '$count Tiere',
              subtitle: 'Alle Tiere',
              icon: MdiIcons.cow,
              color: Colors.green,
              onTap: () {
                if (widget.changeTab != null) widget.changeTab!(1);
              },
            );
          },
        ),
        StreamBuilder<List<FarmTask>>(
          stream: _dbService!.getTasks(),
          builder: (context, snapshot) {
            final count =
                snapshot.data?.where((t) => !t.isCompleted).length ?? 0;
            return _DashboardCard(
              title: 'Aufgaben',
              value: '$count Offen',
              subtitle: 'Termine & Service',
              icon: Icons.task_alt,
              color: Colors.orange,
              onTap: () {
                if (widget.changeTab != null) widget.changeTab!(2);
              },
            );
          },
        ),
        StreamBuilder<List<Animal>>(
          stream: _dbService!.getAnimals(),
          builder: (context, snapshot) {
            final calvesCount =
                snapshot.data?.where((a) => a.isCalf).length ?? 0;
            return _DashboardCard(
              title: 'Kälber',
              value: '$calvesCount',
              subtitle: 'Geburt & Aufzucht',
              icon: MdiIcons.babyCarriage,
              color: Colors.blue,
              onTap: () {
                if (widget.changeTab != null) widget.changeTab!(1);
              },
            );
          },
        ),
        _DashboardCard(
          title: 'Futter',
          value: 'Lager',
          subtitle: 'Futterverwaltung',
          icon: Icons.restaurant_outlined,
          color: Colors.orangeAccent,
          onTap: () {
            if (widget.changeTab != null) widget.changeTab!(3);
          },
        ),
        // NEU: Reproduktions-Card
        _DashboardCard(
          title: 'Reproduktion',
          value: 'Kalender',
          subtitle: 'Brunst & Kalbung',
          icon: Icons.auto_graph,
          color: Colors.pinkAccent,
          onTap: () {
            if (_dbService != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReproductionOverviewPage(),
                ),
              );
            }
          },
        ),
        _DashboardCard(
          title: 'Dokumente',
          value: 'Archiv',
          subtitle: 'Pässe, Rechnungen',
          icon: Icons.folder_open,
          color: Colors.purple,
          onTap: () {
            if (_dbService != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArchivePage(dbService: _dbService!),
                ),
              );
            }
          },
        ),
        _DashboardCard(
          title: 'Scanner',
          value: 'Scanner',
          subtitle: 'Ohrmarke scannen',
          icon: Icons.qr_code_scanner,
          color: Colors.teal,
          onTap: () {
            if (_dbService != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EarTagScannerPage(dbService: _dbService!),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingTasksList() {
    return StreamBuilder<List<FarmTask>>(
      stream: _dbService?.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Keine anstehenden Aufgaben');
        } else {
          final tasks = snapshot.data!
              .where((t) => !t.isCompleted)
              .take(3)
              .toList(); // Nur die nächsten 3
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nächste Aufgaben",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...tasks.map((task) => Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHigh
                        .withOpacity(0.5),
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Text(DateFormat('dd.MM.yyyy').format(task.dueDate)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (widget.changeTab != null) widget.changeTab!(2);
                      },
                    ),
                  )),
            ],
          );
        }
      },
    );
  }

  void _showQuickTaskDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schnelle Aufgabe'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Was ist zu tun?'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty && _dbService != null) {
                _dbService!.addTask(
                  FarmTask(
                    id: '',
                    title: controller.text,
                    dueDate: DateTime.now(),
                    category: 'General',
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalMilkInput(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hof-Gesamtmenge erfassen",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _totalMilkController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Liter (Tank)",
                    prefixIcon: const Icon(Icons.water_drop_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedEntryDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedEntryDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_today),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                double? amount = double.tryParse(_totalMilkController.text);
                if (amount != null && _dbService != null) {
                  _dbService!.setFarmMilkTotal(_selectedEntryDate, amount);
                  _totalMilkController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Menge erfolgreich gespeichert!"),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add_task),
              label: const Text("Speichern"),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    Icon(
                      Icons.arrow_outward,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}