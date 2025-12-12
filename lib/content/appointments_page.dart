import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                  )
                ],
              ),

              const SizedBox(height: 20),

              // --- SEARCH BAR ---
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: loc?.search ?? 'Suche...',
                    prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onChanged: (val) {
                    // Filter logic could go here
                  },
                ),
              ),

              const SizedBox(height: 15),

              // --- CONTENT ---
              Expanded(
                child: _dbService == null
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<List<FarmTask>>(
                        stream: _dbService!.getTasks(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return _buildEmptyState(colorScheme);
                          }

                          final tasks = snapshot.data!;

                          return ListView.builder(
                            itemCount: tasks.length,
                            padding: const EdgeInsets.only(bottom: 80),
                            itemBuilder: (context, index) {
                              return _buildTaskCard(tasks[index], colorScheme);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'appointments_fab',
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64, color: colorScheme.outline.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "Keine offenen Aufgaben",
            style: TextStyle(color: colorScheme.outline, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(FarmTask task, ColorScheme colorScheme) {
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: isOverdue ? Border.all(color: colorScheme.error.withOpacity(0.5)) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getCategoryIcon(task.category), 
            color: isOverdue ? colorScheme.error : colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? colorScheme.onSurface.withOpacity(0.5) : colorScheme.onSurface,
          ),
        ),
        subtitle: Row(
          children: [
            if (isOverdue) 
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Icon(Icons.warning_amber_rounded, size: 14, color: colorScheme.error),
              ),
            Text(
              DateFormat('dd.MM.yyyy HH:mm').format(task.dueDate),
              style: TextStyle(
                color: isOverdue ? colorScheme.error : colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Checkbox(
          value: task.isCompleted,
          activeColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (val) {
            _dbService!.toggleTaskStatus(task.id, task.isCompleted);
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.toLowerCase().contains('vet') || category.toLowerCase().contains('arzt')) return Icons.medical_services_outlined;
    if (category.toLowerCase().contains('futter') || category.toLowerCase().contains('feed')) return Icons.restaurant;
    if (category.toLowerCase().contains('machine') || category.toLowerCase().contains('maschine')) return Icons.build_outlined;
    return Icons.calendar_today_outlined;
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedCategory = 'General';

    showDialog(
      context: context, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final colorScheme = Theme.of(context).colorScheme;
            final loc = AppLocalizations.of(context);

            return AlertDialog(
              title: Text(loc?.add_task ?? 'Neue Aufgabe'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Titel',
                        hintText: 'z.B. Tierarzt rufen',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: true,
                    ),
                    const SizedBox(height: 20),

                    Text('Fälligkeit', style: TextStyle(color: colorScheme.outline, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: colorScheme.outlineVariant),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18, color: colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(DateFormat('dd.MM.yyyy').format(selectedDate), style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setState(() => selectedTime = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: colorScheme.outlineVariant),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time, size: 18, color: colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(selectedTime.format(context), style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text('Kategorie', style: TextStyle(color: colorScheme.outline, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 0,
                      children: [
                        _buildCategoryChip(context, 'General', 'Allgemein', Icons.calendar_today, selectedCategory, colorScheme, (val) => setState(() => selectedCategory = val)),
                        _buildCategoryChip(context, 'Vet', 'Tierarzt', Icons.medical_services, selectedCategory, colorScheme, (val) => setState(() => selectedCategory = val)),
                        _buildCategoryChip(context, 'Feed', 'Futter', Icons.restaurant, selectedCategory, colorScheme, (val) => setState(() => selectedCategory = val)),
                        _buildCategoryChip(context, 'Machine', 'Maschine', Icons.build, selectedCategory, colorScheme, (val) => setState(() => selectedCategory = val)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc?.cancel ?? 'Abbrechen'),
                ),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final dueDateTime = DateTime(
                        selectedDate.year, 
                        selectedDate.month, 
                        selectedDate.day, 
                        selectedTime.hour, 
                        selectedTime.minute
                      );

                      _dbService!.addTask(FarmTask(
                        id: '', 
                        title: titleController.text, 
                        dueDate: dueDateTime,
                        category: selectedCategory,
                        isCompleted: false,
                      ));
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Speichern')
                ),
              ],
            );
          },
        );
      }
    );
  }

  Widget _buildCategoryChip(BuildContext context, String id, String label, IconData icon, String selectedId, ColorScheme colorScheme, Function(String) onSelect) {
    final isSelected = id == selectedId;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, size: 16, color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) onSelect(id);
      },
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
      ),
      selectedColor: colorScheme.primaryContainer,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), 
        side: BorderSide(color: isSelected ? Colors.transparent : colorScheme.outlineVariant)
      ),
    );
  }
}