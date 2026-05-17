import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/models/animal.dart';
import 'package:flutter_maturaprojekt_v01/models/calving_history.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'package:intl/intl.dart';

class AddAnimalPage extends StatefulWidget {
  final DatabaseService dbService;

  const AddAnimalPage({super.key, required this.dbService});

  @override
  State<AddAnimalPage> createState() => _AddAnimalPageState();
}

class _AddAnimalPageState extends State<AddAnimalPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _earTagCtrl = TextEditingController();
  final TextEditingController _breedCtrl = TextEditingController();
  final TextEditingController _motherCtrl = TextEditingController();
  final TextEditingController _fatherCtrl = TextEditingController();
  final TextEditingController _lactationCtrl = TextEditingController(text: '0');

  DateTime _birthDate = DateTime.now();
  String _gender = 'Weiblich';
  bool _isCalf = false;

  DateTime? _weaningDate;
  DateTime? _lastInseminationDate;
  DateTime? _nextCheckDate;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _earTagCtrl.dispose();
    _breedCtrl.dispose();
    _motherCtrl.dispose();
    _fatherCtrl.dispose();
    _lactationCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAnimal() async {
    if (_nameCtrl.text.isEmpty) return;

    final newAnimal = Animal(
      id: '',
      name: _nameCtrl.text,
      earTagNumber: _earTagCtrl.text,
      birthDate: _birthDate,
      breed: _breedCtrl.text,
      gender: _gender,
      isCalf: _isCalf,
      age: DateTime.now().difference(_birthDate).inDays ~/ 365,
      motherId: _motherCtrl.text.isNotEmpty ? _motherCtrl.text : null,
      fatherId: _fatherCtrl.text.isNotEmpty ? _fatherCtrl.text : null,
      weaningDate: _isCalf ? _weaningDate : null,
      lactationNumber: _isCalf ? 0 : (int.tryParse(_lactationCtrl.text) ?? 0),
      lastInseminationDate: !_isCalf ? _lastInseminationDate : null,
      nextPregnancyCheckDate: !_isCalf ? _nextCheckDate : null,
    );

    if (_isCalf && _motherCtrl.text.isNotEmpty) {
      await widget.dbService.addCalfWithMotherLink(
        calf: newAnimal,
        motherIdentifier: _motherCtrl.text,
        calvingDetails: CalvingHistory(
          date: _birthDate,
          calvingCourse: 'Normal',
          calfCount: '1',
          id: '', // ID wird in der Datenbank generiert //HIERHIERHIER
        ),
      );
    } else {
      await widget.dbService.addAnimal(newAnimal);
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
        title: const Text('Neues Tier erfassen'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          TextButton(onPressed: _saveAnimal, child: const Text('Speichern')),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle('Allgemein', colorScheme),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: _inputDeco('Name / Rufname', Icons.edit),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _earTagCtrl,
              decoration: _inputDeco(
                'Ohrmarkennummer',
                Icons.confirmation_number,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildDatePickerField(
              label: 'Geburtsdatum',
              value: _birthDate,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _birthDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _birthDate = picked);
              },
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Eigenschaften & Abstammung', colorScheme),
            const SizedBox(height: 8),
            TextField(
              controller: _breedCtrl,
              decoration: _inputDeco('Rasse', Icons.pets),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _motherCtrl,
                    decoration: _inputDeco('Mutter', Icons.female),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _fatherCtrl,
                    decoration: _inputDeco('Vater', Icons.male),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: InputDecoration(
                labelText: 'Geschlecht',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.wc),
              ),
              items: [
                'Weiblich',
                'Männlich',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _gender = val!),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Ist es ein Kalb?'),
              subtitle: const Text('Aktiviert Kälber-spezifische Felder'),
              secondary: Icon(_isCalf ? Icons.child_care : Icons.grass),
              value: _isCalf,
              activeColor: colorScheme.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _isCalf = val),
            ),
            const SizedBox(height: 10),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isCalf
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Aufzucht', colorScheme),
                  const SizedBox(height: 8),
                  _buildDatePickerField(
                    label: 'Geplantes Absetzdatum',
                    value: _weaningDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 90),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _weaningDate = picked);
                    },
                  ),
                ],
              ),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Produktion', colorScheme),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _lactationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco('Laktationsnummer', Icons.numbers),
                  ),
                  const SizedBox(height: 12),
                  _buildDatePickerField(
                    label: 'Letzte Besamung',
                    value: _lastInseminationDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _lastInseminationDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDatePickerField(
                    label: 'Nächster Trächtigkeitscheck',
                    value: _nextCheckDate,
                    isHighlight: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 30),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null)
                        setState(() => _nextCheckDate = picked);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saveAnimal,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              icon: const Icon(Icons.save),
              label: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colors.primary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    DateTime? value,
    required VoidCallback onTap,
    bool isHighlight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            Icons.calendar_today,
            size: 20,
            color: isHighlight ? Colors.red : null,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          enabledBorder: isHighlight
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                )
              : null,
          fillColor: isHighlight ? Colors.red.withOpacity(0.05) : null,
          filled: isHighlight,
        ),
        child: Text(
          value != null ? DateFormat('dd.MM.yyyy').format(value) : '',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
