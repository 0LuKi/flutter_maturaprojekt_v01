import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/models/farm_task.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'package:flutter_maturaprojekt_v01/services/notification_service.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends StatefulWidget {
  final DatabaseService dbService;

  const AddTaskPage({super.key, required this.dbService});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'General';
  String _selectedNotificationOption = 'none';
  TimeOfDay _fixedNotificationTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isSaving = false;

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
    final task = FarmTask(
      id: '',
      title: _titleController.text,
      dueDate: dueDateTime,
      category: _selectedCategory,
      isCompleted: false,
      notificationOption: _selectedNotificationOption,
      notificationTime: notificationTime,
    );

    final taskId = await widget.dbService.addTask(task);

    if (notificationTime != null) {
      await NotificationService.instance.scheduleTaskNotification(
        taskId: taskId,
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
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(loc?.add_task ?? 'Neue Aufgabe'),
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
                hintText: 'z.B. Tierarzt rufen',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
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
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 2),
                        ),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
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
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd.MM.yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 13),
                          ),
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
                        initialTime: _selectedTime,
                      );
                      if (picked != null) {
                        setState(() => _selectedTime = picked);
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
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTime.format(context),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
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
              runSpacing: 0,
              children: [
                _buildCategoryChip(
                  'General',
                  'Allgemein',
                  Icons.calendar_today,
                  colorScheme,
                ),
                _buildCategoryChip(
                  'Vet',
                  'Tierarzt',
                  Icons.medical_services,
                  colorScheme,
                ),
                _buildCategoryChip(
                  'Feed',
                  'Futter',
                  Icons.restaurant,
                  colorScheme,
                ),
                _buildCategoryChip(
                  'Machine',
                  'Maschine',
                  Icons.build,
                  colorScheme,
                ),
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
                DropdownMenuItem(
                  value: 'none',
                  child: Text('Keine Benachrichtigung'),
                ),
                DropdownMenuItem(
                  value: 'same_day',
                  child: Text('Am selben Tag um 08:00'),
                ),
                DropdownMenuItem(
                  value: 'one_day_before',
                  child: Text('Einen Tag vorher um 08:00'),
                ),
                DropdownMenuItem(
                  value: 'one_hour_before',
                  child: Text('Eine Stunde vorher'),
                ),
                DropdownMenuItem(
                  value: 'fixed_time',
                  child: Text('Fixe Uhrzeit am selben Tag'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedNotificationOption = value);
                }
              },
            ),
            if (_selectedNotificationOption == 'fixed_time') ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _fixedNotificationTime,
                  );
                  if (picked != null) {
                    setState(() => _fixedNotificationTime = picked);
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
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _fixedNotificationTime.format(context),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
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
        color: isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface,
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
