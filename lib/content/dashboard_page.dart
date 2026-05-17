import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_maturaprojekt_v01/content/archive_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';
import 'package:flutter_maturaprojekt_v01/services/auth_service.dart';

import '../services/database_service.dart';
import '../models/animal.dart';
import '../models/farm_task.dart';
import 'livestock_page.dart';
import 'cow_list.dart';
import 'appointments_page.dart';
import 'document_scan_page.dart';
import 'ear_tag_scanner_page.dart';

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
                        _buildBarChart(colorScheme),
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

  Widget _buildBarChart(ColorScheme colorScheme) {
    // WRAP THE CHART IN A SIZED BOX:
    return SizedBox(
      height: 300, // You can adjust this height to look good on your UI
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: 200,
          maxY: 500,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: 50,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'Mo';
                      break;
                    case 1:
                      text = 'Di';
                      break;
                    case 2:
                      text = 'Mi';
                      break;
                    case 3:
                      text = 'Do';
                      break;
                    case 4:
                      text = 'Fr';
                      break;
                    case 5:
                      text = 'Sa';
                      break;
                    case 6:
                      text = 'So';
                      break;
                    default:
                      text = '';
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4.0,
                    child: Text(text, style: style),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            _makeGroupData(0, 445, colorScheme),
            _makeGroupData(1, 453, colorScheme),
            _makeGroupData(2, 438, colorScheme),
            _makeGroupData(3, 443, colorScheme),
            _makeGroupData(4, 460, colorScheme),
            _makeGroupData(5, 455, colorScheme),
            _makeGroupData(6, 448, colorScheme),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, ColorScheme colors) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: colors.primary,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 500,
            color: colors.surface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusGrid(ColorScheme colorScheme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
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
                if (widget.changeTab != null) {
                  widget.changeTab!(1);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LivestockPage(),
                    ),
                  );
                }
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
                if (widget.changeTab != null) {
                  widget.changeTab!(2);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppointmentsPage(),
                    ),
                  );
                }
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
                if (widget.changeTab != null) {
                  widget.changeTab!(1);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LivestockPage(),
                    ),
                  );
                }
              },
            );
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
          value: '',
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
      stream: _dbService?.getTasks(), // Provide the stream
      builder: (context, snapshot) {
        // Provide the builder logic
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No tasks available');
        } else {
          final tasks = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true, // ADD THIS
            physics: const NeverScrollableScrollPhysics(), // ADD THIS
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.dueDate.toString()),
              );
            },
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
              if (controller.text.isNotEmpty) {
                _dbService!.addTask(
                  FarmTask(
                    id: '',
                    title: controller.text,
                    dueDate: DateTime.now(),
                    category: 'Allgemein',
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
