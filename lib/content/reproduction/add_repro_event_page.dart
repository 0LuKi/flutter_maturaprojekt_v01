import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reproduction_event.dart';
import '../../services/reproduction_service.dart';
import '../../services/notification_service.dart';
import '../../utilities/reproduction_calculator.dart';

class AddReproEventPage extends StatefulWidget {
  final String animalId;
  final String animalName;
  final ReproductionEvent? initialEvent; // Optional für den Bearbeitungsmodus

  const AddReproEventPage({
    super.key,
    required this.animalId,
    required this.animalName,
    this.initialEvent,
  });

  @override
  State<AddReproEventPage> createState() => _AddReproEventPageState();
}

class _AddReproEventPageState extends State<AddReproEventPage> {
  late TextEditingController _noteController;
  late ReproEventType _selectedType;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialisierung mit bestehenden Werten, falls wir bearbeiten
    _noteController = TextEditingController(
      text: widget.initialEvent?.note ?? '',
    );
    _selectedType = widget.initialEvent?.type ?? ReproEventType.brunst;
    _selectedDate = widget.initialEvent?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final event = ReproductionEvent(
        id: widget.initialEvent?.id ?? '', // Behalte ID beim Bearbeiten
        type: _selectedType,
        date: _selectedDate,
        note: _noteController.text.trim(),
      );

      if (widget.initialEvent == null) {
        // 1. Neu anlegen
        await ReproductionService().addEvent(widget.animalId, event);
        // 2. Erinnerungen nur bei neuem Ereignis planen
        await _scheduleAutomatedReminders();
      } else {
        // 1. Bestehendes aktualisieren
        await ReproductionService().updateEvent(widget.animalId, event);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler beim Speichern: $e')));
    }
  }

  Future<void> _scheduleAutomatedReminders() async {
    final ns = NotificationService.instance;

    if (_selectedType == ReproEventType.besamung) {
      // Erinnerung für nächste Brunst (nach 21 Tagen)
      final nextHeat = ReproductionCalculator.calculateNextHeat(_selectedDate);
      await ns.scheduleTaskNotification(
        taskId: '${widget.animalId}_heat_check',
        title: 'Brunstkontrolle: ${widget.animalName}',
        scheduledDate: nextHeat.subtract(const Duration(days: 1)),
      );

      // Info über voraussichtlichen Kalbetermin
      final calving = ReproductionCalculator.calculateExpectedCalving(
        _selectedDate,
      );
      await ns.scheduleTaskNotification(
        taskId: '${widget.animalId}_calving_warn',
        title: 'Kalbung in 7 Tagen: ${widget.animalName}',
        scheduledDate: calving.subtract(const Duration(days: 7)),
      );
    } else if (_selectedType == ReproEventType.kalbung) {
      // Nach Kalbung: Alte Erinnerungen löschen
      await ns.cancelTaskNotification('${widget.animalId}_heat_check');
      await ns.cancelTaskNotification('${widget.animalId}_calving_warn');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditMode = widget.initialEvent != null;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(isEditMode ? 'Ereignis bearbeiten' : 'Ereignis erfassen'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          if (!_isSaving)
            TextButton(onPressed: _saveEvent, child: const Text('Speichern')),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Hinweis-Text
            if (!isEditMode)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'Erfasse ein Ereignis für ${widget.animalName}. Der Reproduktionsstatus wird automatisch angepasst.',
                  style: TextStyle(color: colorScheme.outline, fontSize: 14),
                ),
              ),

            // Ereignistyp Dropdown
            DropdownButtonFormField<ReproEventType>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Typ des Ereignisses',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.event_note),
              ),
              items: ReproEventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: isEditMode
                  ? null
                  : (val) {
                      // Typ im Bearbeitungsmodus sperren
                      if (val != null) setState(() => _selectedType = val);
                    },
            ),
            const SizedBox(height: 20),

            // Datum Auswahl
            Text(
              'Datum des Ereignisses',
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notizen
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Notiz / Bemerkung',
                hintText: 'z.B. Stiername oder Besonderheiten',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit_note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Speichern Button
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveEvent,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(isEditMode ? Icons.check : Icons.save),
              label: Text(
                _isSaving
                    ? 'Speichert...'
                    : (isEditMode
                          ? 'Änderungen übernehmen'
                          : 'Ereignis speichern'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
