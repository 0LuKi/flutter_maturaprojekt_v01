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
  
  // Hilfsvariable für Logik
  late bool _isCalf;

  @override
  void initState() {
    super.initState();
    _isCalf = widget.animal.isCalf;
    
    // Wenn Kalb: Nur 2 Tabs (Info, Gesundheit). 
    // Wenn Kuh: 4 Tabs (Info, Milch, Gesundheit, Kalbung).
    int tabCount = _isCalf ? 2 : 4;
    
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Helper to prevent text cutoff in Tabs ---
  Tab _buildResponsiveTab(String text, IconData icon) {
    return Tab(
      height: 60, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 2), 
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.animal.name,
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        bottom: TabBar(
          controller: _tabController,
          padding: EdgeInsets.zero,         
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          // Dynamische Tabs basierend auf Tierart
          tabs: _isCalf 
            ? [
                _buildResponsiveTab(loc.dashboard, Icons.info_outline), // Tab 0
                _buildResponsiveTab(loc.health, Icons.medical_services_outlined), // Tab 1
              ]
            : [
                _buildResponsiveTab(loc.dashboard, Icons.info_outline), // Tab 0
                _buildResponsiveTab(loc.milk, MdiIcons.bucketOutline), // Tab 1
                _buildResponsiveTab(loc.health, Icons.medical_services_outlined), // Tab 2
                _buildResponsiveTab(loc.calving, MdiIcons.cow), // Tab 3
              ]
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // Dynamische Views müssen exakt zu den Tabs oben passen
        children: _isCalf
          ? [
              _buildInfoTab(colorScheme),
              _buildMedicalTab(colorScheme),
            ]
          : [
              _buildInfoTab(colorScheme),
              _buildMilkTab(colorScheme),
              _buildMedicalTab(colorScheme),
              _buildCalvingTab(colorScheme),
            ],
      ),
      floatingActionButton: _buildFloatingActionButton(colorScheme),
    );
  }

  // --- 1. INFO TAB ---
  Widget _buildInfoTab(ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.animal.isCalf ? Colors.orange[100] : colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.animal.isCalf ? MdiIcons.babyCarriage : MdiIcons.cow, 
                  size: 48, 
                  color: widget.animal.isCalf ? Colors.deepOrange : colorScheme.onPrimaryContainer
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.animal.name,
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ohrmarke: ${widget.animal.earTagNumber}',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        _buildSectionHeader('Allgemein', colorScheme),
        _buildInfoRow('Geburtsdatum', _dateFormat.format(widget.animal.birthDate), colorScheme),
        if (widget.animal.breed.isNotEmpty)
          _buildInfoRow('Rasse', widget.animal.breed, colorScheme),
        _buildInfoRow('Geschlecht', widget.animal.gender, colorScheme),

        const SizedBox(height: 16),

        if (widget.animal.isCalf) ...[
          _buildSectionHeader('Kälber-Details', colorScheme),
          if (widget.animal.motherId != null && widget.animal.motherId!.isNotEmpty)
            _buildInfoRow('Mutter', widget.animal.motherId!, colorScheme),
          if (widget.animal.weaningDate != null)
            _buildInfoRow('Geplantes Absetzdatum', _dateFormat.format(widget.animal.weaningDate!), colorScheme),
          if (widget.animal.fatherId != null && widget.animal.fatherId!.isNotEmpty)
            _buildInfoRow('Vater', widget.animal.fatherId!, colorScheme),
        ] else ...[
          _buildSectionHeader('Produktion & Reproduktion', colorScheme),
          _buildInfoRow('Laktationsnummer', '${widget.animal.lactationNumber}', colorScheme),
          if (widget.animal.lastInseminationDate != null)
            _buildInfoRow('Letzte Besamung', _dateFormat.format(widget.animal.lastInseminationDate!), colorScheme),
          if (widget.animal.nextPregnancyCheckDate != null)
            _buildInfoRow(
              'Nächster Trächtigkeitscheck', 
              _dateFormat.format(widget.animal.nextPregnancyCheckDate!), 
              colorScheme, 
              isHighlight: true
            ),
        ],
      ],
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
          letterSpacing: 1.2,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme, {bool isHighlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isHighlight ? colorScheme.errorContainer.withOpacity(0.2) : colorScheme.surface,
        border: Border.all(color: isHighlight ? colorScheme.error.withOpacity(0.5) : colorScheme.outlineVariant.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: colorScheme.onSurface)),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isHighlight ? colorScheme.error : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. MILCH TAB ---
  Widget _buildMilkTab(ColorScheme colorScheme) {
    return StreamBuilder<List<MilkYield>>(
      stream: widget.dbService?.getMilkYields(widget.animal.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        if (list.isEmpty) return _buildEmptyState('Keine Milchdaten vorhanden', MdiIcons.bucketOutline, colorScheme);

        return ListView.builder(
          itemCount: list.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final item = list[index];
            return _buildDetailCard(
              title: '${item.amountLiters} Liter',
              subtitle: item.session,
              date: item.date,
              icon: MdiIcons.water,
              iconColor: Colors.blue,
              colorScheme: colorScheme,
            );
          },
        );
      },
    );
  }

  // --- 3. MEDICAL TAB ---
  Widget _buildMedicalTab(ColorScheme colorScheme) {
    return StreamBuilder<List<MedicalRecord>>(
      stream: widget.dbService?.getMedicalRecords(widget.animal.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        if (list.isEmpty) return _buildEmptyState('Keine Einträge vorhanden', Icons.medical_services_outlined, colorScheme);

        return ListView.builder(
          itemCount: list.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final item = list[index];
            return _buildDetailCard(
              title: item.diagnosis,
              subtitle: item.treatment,
              date: item.date,
              icon: Icons.healing,
              iconColor: Colors.red,
              colorScheme: colorScheme,
            );
          },
        );
      },
    );
  }

  // --- 4. CALVING TAB ---
  Widget _buildCalvingTab(ColorScheme colorScheme) {
    return StreamBuilder<List<CalvingHistory>>(
      stream: widget.dbService?.getCalvingHistory(widget.animal.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        if (list.isEmpty) return _buildEmptyState('Keine Kalbungen verzeichnet', MdiIcons.babyCarriageOff, colorScheme);

        return ListView.builder(
          itemCount: list.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final item = list[index];
            return _buildDetailCard(
              title: '${item.calfCount} Kalb(er)',
              subtitle: 'Verlauf: ${item.calvingCourse}',
              date: item.date,
              icon: MdiIcons.babyCarriage,
              iconColor: Colors.brown,
              colorScheme: colorScheme,
            );
          },
        );
      },
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildDetailCard({
    required String title,
    required String subtitle,
    required DateTime date,
    required IconData icon,
    required Color iconColor,
    required ColorScheme colorScheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(
          _dateFormat.format(date),
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: colorScheme.surfaceContainerHighest),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  // --- FLOATING ACTION BUTTON (DYNAMISCH) ---
  Widget? _buildFloatingActionButton(ColorScheme colorScheme) {
    if (_tabController.index == 0) return null;

    if (_isCalf) {
      if (_tabController.index == 1) {
        return _styledFab(colorScheme, () => _showAddMedicalDialog());
      }
      return null;
    } else {
      if (_tabController.index == 1) {
        return _styledFab(colorScheme, () => _showAddMilkDialog());
      } else if (_tabController.index == 2) {
        return _styledFab(colorScheme, () => _showAddMedicalDialog());
      } else if (_tabController.index == 3) {
        // HIER DIE ÄNDERUNG: Statt nur Historie, jetzt volles Kalb anlegen
        return _styledFab(colorScheme, () => _showAddCalfDialog());
      }
      return null;
    }
  }

  Widget _styledFab(ColorScheme colorScheme, VoidCallback onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      child: const Icon(Icons.add),
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
            decoration: InputDecoration(
              labelText: 'Liter',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: session,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
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
          TextField(
            controller: diagnosisCtrl, 
            decoration: InputDecoration(
              labelText: 'Diagnose / Grund',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: treatmentCtrl, 
            decoration: InputDecoration(
              labelText: 'Behandlung / Medikament',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
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

  // --- NEUER DIALOG: KALB ANLEGEN & VERKNÜPFEN ---
  void _showAddCalfDialog() {
    // Controller
    final nameCtrl = TextEditingController();
    final earTagCtrl = TextEditingController();
    final breedCtrl = TextEditingController();
    final fatherCtrl = TextEditingController(); 
    // Mutter ist fixiert auf DIESE Kuh
    final motherName = widget.animal.name;

    // Status
    DateTime birthDate = DateTime.now();
    String gender = 'Weiblich';
    DateTime? weaningDate;
    
    // Zusätzliche Info für den Verlauf
    String calvingCourse = 'Normal';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final colorScheme = Theme.of(context).colorScheme;

            return AlertDialog(
              title: const Text('Kalbung & Neues Kalb'),
              scrollable: true,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dieses Kalb wird automatisch als Kind dieser Kuh gespeichert.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  
                  _buildSectionHeader('Das Kalb', colorScheme),
                  TextField(
                    controller: nameCtrl,
                    decoration: _inputDeco('Name / Rufname des Kalbes', Icons.child_care),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: earTagCtrl,
                    decoration: _inputDeco('Ohrmarkennummer', Icons.confirmation_number),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildDatePickerField(
                    label: 'Geburtsdatum', 
                    value: birthDate, 
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: birthDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                      if (picked != null) setState(() => birthDate = picked);
                    }
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: _inputDeco('Geschlecht', Icons.wc),
                    items: ['Weiblich', 'Männlich'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => gender = val!),
                  ),
                  
                  const SizedBox(height: 16),
                  _buildSectionHeader('Details', colorScheme),
                  TextField(
                    controller: breedCtrl,
                    decoration: _inputDeco('Rasse', Icons.pets),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: fatherCtrl,
                    decoration: _inputDeco('Vater (Name/Ohrmarke)', Icons.male),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: calvingCourse,
                    decoration: _inputDeco('Verlauf der Geburt', Icons.health_and_safety),
                    items: ['Normal', 'Schwer', 'Kaiserschnitt'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => calvingCourse = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty) return;

                    final newCalf = Animal(
                      id: '', 
                      name: nameCtrl.text,
                      earTagNumber: earTagCtrl.text,
                      birthDate: birthDate,
                      breed: breedCtrl.text,
                      gender: gender,
                      isCalf: true, // Ist immer ein Kalb
                      motherId: motherName, // Automatisch gesetzt
                      fatherId: fatherCtrl.text.isNotEmpty ? fatherCtrl.text : null,
                      weaningDate: weaningDate,
                      lactationNumber: 0,
                    );

                    // Spezielle Funktion im Service nutzen
                    widget.dbService?.addCalfWithMotherLink(
                      calf: newCalf, 
                      motherIdentifier: motherName, 
                      calvingDetails: CalvingHistory(
                        date: birthDate,
                        calvingCourse: calvingCourse,
                        calfCount: '1',
                      )
                    );
                    
                    Navigator.pop(context);
                  },
                  child: const Text('Kalb anlegen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- DUPLICATE HELPERS FOR DIALOG (Lokale Kopie um Abhängigkeiten zu vermeiden) ---
  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
  
  Widget _buildDatePickerField({required String label, DateTime? value, required VoidCallback onTap, bool isHighlight = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.calendar_today, size: 20, color: isHighlight ? Colors.red : null),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        child: Text(
          value != null ? DateFormat('dd.MM.yyyy').format(value) : '',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}