import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/models/animal.dart';
import 'package:flutter_maturaprojekt_v01/models/medical_record.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';

class EditMedicalPage extends StatefulWidget {
  final Animal animal;
  final DatabaseService dbService;
  final MedicalRecord? record; // Wenn null -> neu anlegen, sonst bearbeiten

  const EditMedicalPage({super.key, required this.animal, required this.dbService, this.record});

  @override
  State<EditMedicalPage> createState() => _EditMedicalPageState();
}

class _EditMedicalPageState extends State<EditMedicalPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _diagnosisCtrl;
  late TextEditingController _treatmentCtrl;
  late TextEditingController _costCtrl;
  late TextEditingController _vetCtrl;
  late TextEditingController _notesCtrl;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _diagnosisCtrl = TextEditingController(text: widget.record?.diagnosis);
    _treatmentCtrl = TextEditingController(text: widget.record?.treatment);
    _costCtrl = TextEditingController(text: widget.record?.cost.toString() ?? '0.0');
    _vetCtrl = TextEditingController(text: widget.record?.veterinarian);
    _notesCtrl = TextEditingController(text: widget.record?.notes);
    if (widget.record != null) _selectedDate = widget.record!.date;
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newRecord = MedicalRecord(
        id: widget.record?.id ?? '',
        date: _selectedDate,
        diagnosis: _diagnosisCtrl.text,
        treatment: _treatmentCtrl.text,
        cost: double.tryParse(_costCtrl.text) ?? 0.0,
        veterinarian: _vetCtrl.text,
        notes: _notesCtrl.text,
      );

      if (widget.record == null) {
        widget.dbService.addMedicalRecord(widget.animal.id, newRecord);
      } else {
        widget.dbService.updateMedicalRecord(widget.animal.id, newRecord);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.record == null ? 'Behandlung erfassen' : 'Behandlung bearbeiten')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
             // Hier die TextFields für Diagnose, Behandlung, Kosten, Tierarzt...
             TextFormField(controller: _diagnosisCtrl, decoration: const InputDecoration(labelText: 'Diagnose')),
             TextFormField(controller: _costCtrl, decoration: const InputDecoration(labelText: 'Kosten (€)'), keyboardType: TextInputType.number),
             TextFormField(controller: _vetCtrl, decoration: const InputDecoration(labelText: 'Tierarzt')),
             // ...
             const SizedBox(height: 20),
             FilledButton(onPressed: _save, child: const Text('Speichern'))
          ],
        ),
      ),
    );
  }
}