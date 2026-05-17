import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/models/animal.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'package:intl/intl.dart';

class EditAnimalPage extends StatefulWidget {
  final Animal animal;
  final DatabaseService dbService;

  const EditAnimalPage({
    super.key,
    required this.animal,
    required this.dbService,
  });

  @override
  State<EditAnimalPage> createState() => _EditAnimalPageState();
}

class _EditAnimalPageState extends State<EditAnimalPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _earTagCtrl;
  late final TextEditingController _breedCtrl;
  late final TextEditingController _motherCtrl;
  late final TextEditingController _fatherCtrl;
  late final TextEditingController _lactationCtrl;

  late DateTime _birthDate;
  late String _gender;
  late bool _isCalf;

  DateTime? _weaningDate;
  DateTime? _lastInseminationDate;
  DateTime? _nextCheckDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    _nameCtrl = TextEditingController(text: a.name);
    _earTagCtrl = TextEditingController(text: a.earTagNumber);
    _breedCtrl = TextEditingController(text: a.breed);
    _motherCtrl = TextEditingController(text: a.motherId ?? '');
    _fatherCtrl = TextEditingController(text: a.fatherId ?? '');
    _lactationCtrl = TextEditingController(text: '${a.lactationNumber}');
    _birthDate = a.birthDate;
    _gender = a.gender;
    _isCalf = a.isCalf;
    _weaningDate = a.weaningDate;
    _lastInseminationDate = a.lastInseminationDate;
    _nextCheckDate = a.nextPregnancyCheckDate;
  }

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

  Future<void> _save() async {
    if (_isSaving || _nameCtrl.text.isEmpty) return;
    setState(() => _isSaving = true);

    final updated = Animal(
      id: widget.animal.id,
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

    await widget.dbService.updateAnimal(widget.animal.id, updated.toMap());

    if (mounted) {
      Navigator.pop(context, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tier bearbeiten'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: const Text('Speichern'),
          ),
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
                        initialDate:
                            _weaningDate ??
                            DateTime.now().add(const Duration(days: 90)),
                        firstDate: DateTime(2000),
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
                        initialDate: _lastInseminationDate ?? DateTime.now(),
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
                        initialDate:
                            _nextCheckDate ??
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _nextCheckDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
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
