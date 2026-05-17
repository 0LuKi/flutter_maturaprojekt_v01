import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/animal.dart';
import '../models/calving_history.dart';
import '../services/database_service.dart';

class EditCalvingPage extends StatefulWidget {
  final Animal animal;
  final DatabaseService dbService;
  final CalvingHistory? record; // Wenn null, wird ein neuer Eintrag erstellt

  const EditCalvingPage({
    super.key,
    required this.animal,
    required this.dbService,
    this.record,
  });

  @override
  State<EditCalvingPage> createState() => _EditCalvingPageState();
}

class _EditCalvingPageState extends State<EditCalvingPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Formular-Felder
  late DateTime _selectedDate;
  late String _selectedCourse;
  late TextEditingController _calfCountCtrl;
  late TextEditingController _notesCtrl;

  final List<String> _courses = ['Normal', 'Schwer', 'Kaiserschnitt', 'Fehlgeburt'];

  @override
  void initState() {
    super.initState();
    // Initialisierung mit bestehenden Daten (beim Bearbeiten) oder Standardwerten
    _selectedDate = widget.record?.date ?? DateTime.now();
    _selectedCourse = widget.record?.calvingCourse ?? 'Normal';
    
    // Sicherstellen, dass der Kurs in der Liste existiert
    if (!_courses.contains(_selectedCourse)) {
      _selectedCourse = 'Normal';
    }

    _calfCountCtrl = TextEditingController(text: widget.record?.calfCount ?? '1');
    _notesCtrl = TextEditingController(); // Platz für spätere Erweiterungen (Notizen)
  }

  @override
  void dispose() {
    _calfCountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newRecord = CalvingHistory(
        id: widget.record?.id ?? '', // ID wird beim Update benötigt
        date: _selectedDate,
        calvingCourse: _selectedCourse,
        calfCount: _calfCountCtrl.text,
      );

      if (widget.record == null) {
        // Neuen Eintrag hinzufügen (Erhöht automatisch Laktationsnummer)
        widget.dbService.addCalvingEvent(widget.animal.id, newRecord);
      } else {
        // Bestehenden Eintrag aktualisieren
        widget.dbService.updateCalvingHistory(widget.animal.id, newRecord);
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEdit = widget.record != null;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(isEdit ? 'Kalbung bearbeiten' : 'Kalbung erfassen'),
        centerTitle: true,
        actions: [
          if (isEdit)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: () => _confirmDelete(),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info-Karte
            _buildInfoBox(colorScheme),
            const SizedBox(height: 24),

            _buildSectionHeader('Datum & Verlauf', colorScheme),
            
            // Datum Auswahl
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Kalbedatum'),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 16),

            // Geburtsverlauf Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCourse,
              decoration: _inputDecoration('Geburtsverlauf', Icons.speed),
              items: _courses
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCourse = val!),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Nachkommen', colorScheme),
            
            // Anzahl Kälber
            TextFormField(
              controller: _calfCountCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Anzahl Kälber', Icons.numbers),
              validator: (val) => val == null || val.isEmpty ? 'Pflichtfeld' : null,
            ),
            
            const SizedBox(height: 40),

            // Speichern Button
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(isEdit ? 'Änderungen speichern' : 'Ereignis speichern'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: const Text('Möchten Sie dieses Kalbeereignis wirklich löschen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () {
              widget.dbService.deleteCalvingHistory(widget.animal.id, widget.record!.id);
              Navigator.pop(ctx); // Dialog zu
              Navigator.pop(context); // Seite zu
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          color: colorScheme.primary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildInfoBox(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Das Erfassen einer Kalbung erhöht automatisch die Laktationsnummer von ${widget.animal.name}.',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}