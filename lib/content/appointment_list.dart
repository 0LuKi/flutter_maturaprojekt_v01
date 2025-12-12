import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/models/farm_task.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AppointmentList extends StatefulWidget {
  final DatabaseService dbService;  // Add this parameter

  const AppointmentList({
    super.key,
    required this.dbService,  // Make it required
  });

  @override
  State<AppointmentList> createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  // Remove _dbService and _initService, as it's now passed in

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<FarmTask>>(
      stream: widget.dbService.getTasks(),  // Use widget.dbService
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
                Icon(MdiIcons.calendarBlank, size: 64, color: colorScheme.surfaceContainerLow),
                const SizedBox(height: 16),
                Text(loc.no_tasks_found),
              ],
            ),
          );
        }

        final tasks = snapshot.data!;

        return ListView.builder(
          itemCount: tasks.length,
          padding: const EdgeInsets.only(bottom: 80),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              task: task,
              dbService: widget.dbService,  // Pass widget.dbService
            );
          },
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final FarmTask task;
  final DatabaseService? dbService;

  const TaskCard({
    super.key,
    required this.task,
    required this.dbService,
  });

  IconData _getCategoryIcon(String category) {
    if (category.toLowerCase().contains('vet') || category.toLowerCase().contains('arzt')) {
      return Icons.medical_services_outlined;
    }
    if (category.toLowerCase().contains('futter') || category.toLowerCase().contains('feed')) {
      return Icons.restaurant;
    }
    if (category.toLowerCase().contains('machine') || category.toLowerCase().contains('maschine')) {
      return Icons.build_outlined;
    }
    return Icons.calendar_today_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: isOverdue ? Colors.red[50] : colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isOverdue ? Colors.red[200] : colorScheme.primaryContainer,
          child: Icon(
            _getCategoryIcon(task.category),
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? colorScheme.onSurface.withValues(alpha: 0.5) : colorScheme.onSurface,
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
            dbService!.toggleTaskStatus(task.id, task.isCompleted);
          },
        ),
        onTap: () {
          // Optional: Add navigation to task details if needed
        },
      ),
    );
  }
}