import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/models/animal.dart';
import 'package:flutter_maturaprojekt_v01/models/calving_history.dart';
import 'package:flutter_maturaprojekt_v01/models/medical_record.dart';
import 'package:flutter_maturaprojekt_v01/models/milk_yield.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CowDetail extends StatefulWidget {
  final Animal animal;
  final DatabaseService? dbService;

  const CowDetail({
    super.key, 
    required this.animal, 
    required this.dbService
  });

  @override
  State<CowDetail> createState() => _CowDetailState();
}

class _CowDetailState extends State<CowDetail> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();

    // 4 Tabs: Info, Milch, Medizin, Kalbungen
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animal.name),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: loc.dashboard, icon: Icon(Icons.info_outline)),
            Tab(text: loc.milk, icon: Icon(MdiIcons.bucketOutline)),
            Tab(text: loc.health, icon: Icon(Icons.medical_services_outlined)),
            Tab(text: loc.calving, icon: Icon(MdiIcons.cow))
          ]
        )
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildMilkTab(),
          _buildMedicalTab(),
          _buildCalvingTab(),
        ]
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }






  // TODO - NUR DEMO




  // --- 1. INFO TAB ---
  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(widget.animal.isCalf ? MdiIcons.babyCarriage : MdiIcons.cow, size: 60, color: Colors.green),
                const SizedBox(height: 10),
                Text(
                  widget.animal.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'Ohrmarke: ${widget.animal.earTagNumber}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildInfoRow('Geburtsdatum', _dateFormat.format(widget.animal.birthDate)),
        _buildInfoRow('Laktationsnummer', '${widget.animal.lactationNumber}'),
        if (widget.animal.lastInseminationDate != null)
          _buildInfoRow('Letzte Besamung', _dateFormat.format(widget.animal.lastInseminationDate!)),
        if (widget.animal.nextPregnancyCheckDate != null)
          _buildInfoRow('Nächster Trächtigkeitscheck', _dateFormat.format(widget.animal.nextPregnancyCheckDate!), isHighlight: true),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. MILCH TAB ---
  Widget _buildMilkTab() {
    return StreamBuilder<List<MilkYield>>(
      stream: widget.dbService?.getMilkYields(widget.animal.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        if (list.isEmpty) return const Center(child: Text('Keine Milchdaten vorhanden'));

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return ListTile(
              leading: Icon(MdiIcons.water),
              title: Text('${item.amountLiters} Liter'),
              subtitle: Text(item.session),
              trailing: Text(_dateFormat.format(item.date)),
            );
          },
        );
      },
    );
  }

  // --- 3. MEDICAL TAB ---
  Widget _buildMedicalTab() {
    return StreamBuilder<List<MedicalRecord>>(
      stream: widget.dbService?.getMedicalRecords(widget.animal.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        if (list.isEmpty) return const Center(child: Text('Keine Einträge vorhanden'));

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return ListTile(
              leading: const Icon(Icons.healing, color: Colors.red),
              title: Text(item.diagnosis),
              subtitle: Text(item.treatment),
              trailing: Text(_dateFormat.format(item.date)),
            );
          },
        );
      },
    );
  }

  // --- 4. CALVING TAB ---
  Widget _buildCalvingTab() {
    return StreamBuilder<List<CalvingHistory>>(
      stream: widget.dbService?.getCalvingHistory(widget.animal.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        if (list.isEmpty) return const Center(child: Text('Keine Kalbungen verzeichnet'));

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return ListTile(
              leading: Icon(MdiIcons.babyCarriage, color: Colors.brown),
              title: Text('${item.calfCount} Kalb(er)'),
              subtitle: Text('Verlauf: ${item.calvingCourse}'),
              trailing: Text(_dateFormat.format(item.date)),
            );
          },
        );
      },
    );
  }

  // --- FLOATING ACTION BUTTON ---
  Widget? _buildFloatingActionButton() {
    // Zeige FAB nur auf Tabs 1, 2, 3 (nicht auf Übersicht)
    // Wir müssen den Index vom Controller abhören, 
    // aber standardmäßig baut Flutter den FAB nicht neu bei Tab-Wechsel.
    // Workaround: Wir verwenden AnimatedBuilder oder setState beim Tab-Listener.
    // Für Einfachheit hier: Ein generischer "Add"-Button, der ein Menü öffnet,
    // oder wir lassen es simpel und zeigen ihn immer an.
    
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        if (_tabController.index == 1) _showAddMilkDialog();
        else if (_tabController.index == 2) _showAddMedicalDialog();
        else if (_tabController.index == 3) _showAddCalvingDialog();
        else {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte wählen Sie einen Tab (Milch, Gesundheit...)')));
        }
      },
    );
  }

  // --- DIALOGS ---
  
  void _showAddMilkDialog() {
    final amountController = TextEditingController();
    String session = 'Morgens';
    
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Milchmenge erfassen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Liter'),
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: session,
            isExpanded: true,
            items: ['Morgens', 'Abends', 'Mittags'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => session = val!,
          )
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        FilledButton(onPressed: () {
          if (amountController.text.isEmpty) return;
          final record = MilkYield(
            date: DateTime.now(),
            amountLiters: double.tryParse(amountController.text) ?? 0.0,
            session: session,
          );
          widget.dbService?.addMilkYield(widget.animal.id, record);
          Navigator.pop(context);
        }, child: const Text('Speichern'))
      ],
    ));
  }

  void _showAddMedicalDialog() {
    final diagnosisCtrl = TextEditingController();
    final treatmentCtrl = TextEditingController();
    
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Krankheit / Behandlung'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: diagnosisCtrl, decoration: const InputDecoration(labelText: 'Diagnose / Grund')),
          TextField(controller: treatmentCtrl, decoration: const InputDecoration(labelText: 'Behandlung / Medikament')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        FilledButton(onPressed: () {
          if (diagnosisCtrl.text.isEmpty) return;
          final record = MedicalRecord(
            date: DateTime.now(),
            diagnosis: diagnosisCtrl.text,
            treatment: treatmentCtrl.text,
          );
          widget.dbService?.addMedicalRecord(widget.animal.id, record);
          Navigator.pop(context);
        }, child: const Text('Speichern'))
      ],
    ));
  }

  void _showAddCalvingDialog() {
    final countCtrl = TextEditingController(text: '1');
    String course = 'Normal';

    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Kalbung erfassen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           const Text('Achtung: Erhöht automatisch die Laktationsnummer der Kuh!'),
           const SizedBox(height: 10),
           TextField(controller: countCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Anzahl Kälber')),
           const SizedBox(height: 10),
           DropdownButton<String>(
            value: course,
            isExpanded: true,
            items: ['Normal', 'Schwer', 'Kaiserschnitt'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => course = val!,
          )
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        FilledButton(onPressed: () {
          final record = CalvingHistory(
            date: DateTime.now(),
            calvingCourse: course,
            calfCount: (int.tryParse(countCtrl.text) ?? 1).toString(),
          );
          widget.dbService?.addCalvingEvent(widget.animal.id, record);
          Navigator.pop(context);
        }, child: const Text('Speichern'))
      ],
    ));
  }

}