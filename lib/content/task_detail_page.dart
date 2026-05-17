import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/models/farm_task.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'package:flutter_maturaprojekt_v01/services/notification_service.dart';
import 'package:intl/intl.dart';

class TaskDetailPage extends StatefulWidget {
  final FarmTask task;
  final DatabaseService dbService;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.dbService,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late final TextEditingController _titleController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedCategory;
  late String _selectedNotificationOption;
  TimeOfDay _fixedNotificationTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _selectedDate = widget.task.dueDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.task.dueDate);
    _selectedCategory = widget.task.category.isEmpty
        ? 'General'
        : widget.task.category;
    _selectedNotificationOption = widget.task.notificationOption;

    if (widget.task.notificationTime != null) {
      _fixedNotificationTime = TimeOfDay.fromDateTime(
        widget.task.notificationTime!,
      );
    }
  }

  DateTime? _calculateNotificationTime(DateTime dueDateTime) {
    switch (_selectedNotificationOption) {
      case 'same_day':
        return DateTime(
          dueDateTime.year,
          dueDateTime.month,
          dueDateTime.day,
          8,
        );
      case 'one_day_before':
        final dayBefore = dueDateTime.subtract(const Duration(days: 1));
        return DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 8);
      case 'one_hour_before':
        return dueDateTime.subtract(const Duration(hours: 1));
      case 'fixed_time':
        return DateTime(
          dueDateTime.year,
          dueDateTime.month,
          dueDateTime.day,
          _fixedNotificationTime.hour,
          _fixedNotificationTime.minute,
        );
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_isSaving || _titleController.text.isEmpty) return;

    setState(() => _isSaving = true);

    final dueDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final notificationTime = _calculateNotificationTime(dueDateTime);
    final updatedTask = FarmTask(
      id: widget.task.id,
      title: _titleController.text,
      dueDate: dueDateTime,
      isCompleted: widget.task.isCompleted,
      category: _selectedCategory,
      notificationOption: _selectedNotificationOption,
      notificationTime: notificationTime,
    );

    await widget.dbService.updateTask(updatedTask);
    await NotificationService.instance.cancelTaskNotification(widget.task.id);

    if (notificationTime != null) {
      await NotificationService.instance.scheduleTaskNotification(
        taskId: widget.task.id,
        title: _titleController.text,
        scheduledDate: notificationTime,
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Termin bearbeiten'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveTask,
            child: const Text('Speichern'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Titel',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            Text(
              'Fälligkeit',
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPickerBox(
                    colorScheme: colorScheme,
                    icon: Icons.calendar_today,
                    text: DateFormat('dd.MM.yyyy').format(_selectedDate),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 2),
                        ),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPickerBox(
                    colorScheme: colorScheme,
                    icon: Icons.access_time,
                    text: _selectedTime.format(context),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (picked != null) setState(() => _selectedTime = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Kategorie',
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildCategoryChip('General', 'Allgemein', Icons.calendar_today, colorScheme),
                _buildCategoryChip('Vet', 'Tierarzt', Icons.medical_services, colorScheme),
                _buildCategoryChip('Feed', 'Futter', Icons.restaurant, colorScheme),
                _buildCategoryChip('Machine', 'Maschine', Icons.build, colorScheme),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Benachrichtigung',
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedNotificationOption,
              decoration: InputDecoration(
                labelText: 'Pushup senden',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.notifications_active),
              ),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Keine Benachrichtigung')),
                DropdownMenuItem(value: 'same_day', child: Text('Am selben Tag um 08:00')),
                DropdownMenuItem(value: 'one_day_before', child: Text('Einen Tag vorher um 08:00')),
                DropdownMenuItem(value: 'one_hour_before', child: Text('Eine Stunde vorher')),
                DropdownMenuItem(value: 'fixed_time', child: Text('Fixe Uhrzeit am selben Tag')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedNotificationOption = value);
                }
              },
            ),
            if (_selectedNotificationOption == 'fixed_time') ...[
              const SizedBox(height: 12),
              _buildPickerBox(
                colorScheme: colorScheme,
                icon: Icons.access_time,
                text: _fixedNotificationTime.format(context),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _fixedNotificationTime,
                  );
                  if (picked != null) {
                    setState(() => _fixedNotificationTime = picked);
                  }
                },
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveTask,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Speichern...' : 'Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerBox({
    required ColorScheme colorScheme,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Flexible(child: Text(text, style: const TextStyle(fontSize: 13))),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    String id,
    String label,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    final isSelected = id == _selectedCategory;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) setState(() => _selectedCategory = id);
      },
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
      ),
      selectedColor: colorScheme.primaryContainer,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
