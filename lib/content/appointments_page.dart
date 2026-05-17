import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_maturaprojekt_v01/content/add_task_page.dart';
import 'package:flutter_maturaprojekt_v01/content/task_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'package:flutter_maturaprojekt_v01/models/farm_task.dart';
import 'package:flutter_maturaprojekt_v01/services/auth_service.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  DatabaseService? _dbService;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _dbService = DatabaseService(userId: user.uid);
    }
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // --- MODERN HEADER ---
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc?.appointments ?? 'Aufgaben',
                    style: TextStyle(
                      fontSize: 28,
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

              const SizedBox(height: 20),

              const SizedBox(height: 15),

              // --- CONTENT ---
              Expanded(
                child: _dbService == null
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<List<FarmTask>>(
                        stream: _dbService!.getTasks(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return _buildEmptyState(colorScheme);
                          }

                          final allTasks = snapshot.data!;
                          // Filter tasks into two lists
                          final incompleteTasks = allTasks
                              .where((t) => !t.isCompleted)
                              .toList();
                          final completedTasks = allTasks
                              .where((t) => t.isCompleted)
                              .toList();

                          if (incompleteTasks.isEmpty &&
                              completedTasks.isEmpty) {
                            return _buildEmptyState(colorScheme);
                          }

                          return ListView(
                            padding: const EdgeInsets.only(bottom: 80),
                            children: [
                              // 1. Unchecked Tasks
                              ...incompleteTasks.map(
                                (t) => _buildTaskCard(t, colorScheme),
                              ),

                              // Optional "All Done" message if no incomplete tasks exist but completed ones do
                              if (incompleteTasks.isEmpty &&
                                  completedTasks.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Alles erledigt! 🎉",
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                              // 2. Divider & Header for Completed Tasks
                              if (completedTasks.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: colorScheme.outlineVariant,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        "Erledigt (${completedTasks.length})",
                                        style: TextStyle(
                                          color: colorScheme.outline,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: colorScheme.outlineVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // 3. Completed Tasks
                                ...completedTasks.map(
                                  (t) => _buildTaskCard(t, colorScheme),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'appointments_fab',
        onPressed: _dbService == null
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddTaskPage(dbService: _dbService!),
                  ),
                );
              },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Neue Aufgabe'),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Keine Aufgaben",
            style: TextStyle(color: colorScheme.outline, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(FarmTask task, ColorScheme colorScheme) {
    final isOverdue =
        task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;
    final isCompleted = task.isCompleted;

    // Dim the completed tasks slightly
    final cardOpacity = isCompleted ? 0.6 : 1.0;

    return Opacity(
      opacity: cardOpacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: isOverdue
              ? Border.all(color: colorScheme.error.withOpacity(0.5))
              : null,
        ),
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    TaskDetailPage(task: task, dbService: _dbService!),
              ),
            );
          },
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
            child: Icon(
              _getCategoryIcon(task.category),
              color: isOverdue
                  ? colorScheme.error
                  : (isCompleted ? colorScheme.secondary : colorScheme.primary),
              size: 20,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted
                  ? colorScheme.onSurface.withOpacity(0.6)
                  : colorScheme.onSurface,
            ),
          ),
          subtitle: Row(
            children: [
              if (isOverdue)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: colorScheme.error,
                  ),
                ),
              Text(
                DateFormat('dd.MM.yyyy HH:mm').format(task.dueDate),
                style: TextStyle(
                  color: isOverdue
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: task.isCompleted,
                activeColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (val) {
                  _dbService!.toggleTaskStatus(task.id, task.isCompleted);
                },
              ),

              IconButton(
                icon: Icon(Icons.delete_outline),
                color: colorScheme.error.withOpacity(0.7),
                onPressed: () {
                  _confirmDeleteTask(context, task);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteTask(BuildContext context, FarmTask task) {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc!.delete_task),
          content: Text(loc.delete_task_conf),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _dbService?.deleteTask(task.id);
              },
              child: Text(
                loc.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.toLowerCase().contains('vet') ||
        category.toLowerCase().contains('arzt'))
      return Icons.medical_services_outlined;
    if (category.toLowerCase().contains('futter') ||
        category.toLowerCase().contains('feed'))
      return Icons.restaurant;
    if (category.toLowerCase().contains('machine') ||
        category.toLowerCase().contains('maschine'))
      return Icons.build_outlined;
    return Icons.calendar_today_outlined;
  }
}
