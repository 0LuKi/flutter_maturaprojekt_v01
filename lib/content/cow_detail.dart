import 'dart:io'; // NEU: Für das Laden lokaler Bilddateien (File)
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/edit_animal_page.dart';
import 'package:flutter_maturaprojekt_v01/content/edit_calving_page.dart';
import 'package:flutter_maturaprojekt_v01/content/edit_medical_page.dart';
import 'package:flutter_maturaprojekt_v01/content/reproduction/reproduction_tab.dart';
import 'package:flutter_maturaprojekt_v01/content/reproduction/add_repro_event_page.dart';
import 'package:flutter_maturaprojekt_v01/utilities/reproduction_calculator.dart';

import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/models/animal.dart';
import 'package:flutter_maturaprojekt_v01/models/calving_history.dart';
import 'package:flutter_maturaprojekt_v01/models/medical_record.dart';
import 'package:flutter_maturaprojekt_v01/models/milk_yield.dart';
import 'package:flutter_maturaprojekt_v01/models/farm_document.dart'; 
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart'; // NEU: Für das Herunterladen/Teilen

class CowDetail extends StatefulWidget {
  final Animal animal;
  final DatabaseService? dbService;

  const CowDetail({super.key, required this.animal, required this.dbService});

  @override
  State<CowDetail> createState() => _CowDetailState();
}

class _CowDetailState extends State<CowDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  late bool _isCalf;
  late Animal _animal;

  @override
  void initState() {
    super.initState();
    _animal = widget.animal;
    _isCalf = _animal.isCalf;

    // 2 Tabs für Kälber, 5 Tabs für Kühe
    int tabCount = _isCalf ? 2 : 5;

    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openEditPage() async {
    if (widget.dbService == null) return;
    final result = await Navigator.of(context).push<Animal>(
      MaterialPageRoute(
        builder: (_) =>
            EditAnimalPage(animal: _animal, dbService: widget.dbService!),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _animal = result;
        _isCalf = result.isCalf;
      });
    }
  }

  String _calculateAgeText(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    if (now.day < birthDate.day) months--;
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years <= 0 && months <= 0) {
      final days = now.difference(birthDate).inDays;
      return '$days ${days == 1 ? 'Tag' : 'Tage'}';
    }
    if (years <= 0) return '$months ${months == 1 ? 'Monat' : 'Monate'}';
    if (months == 0) return '$years ${years == 1 ? 'Jahr' : 'Jahre'}';
    return '$years ${years == 1 ? 'Jahr' : 'Jahre'}, $months ${months == 1 ? 'Monat' : 'Monate'}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _animal.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: widget.dbService == null ? null : _openEditPage,
            icon: Icon(Icons.edit, size: 18, color: colorScheme.primary),
            label: const Text('Bearbeiten'),
          ),
        ],
      ),
      body: Column(
        children: [
          // TAB-BAR BEREICH (Gleichmäßig verteilt)
          Container(
            color: colorScheme.surface,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              isScrollable: false,
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              tabs: _isCalf
                  ? [
                      _buildResponsiveTab(loc.dashboard, Icons.info_outline),
                      _buildResponsiveTab(
                        loc.health,
                        Icons.medical_services_outlined,
                      ),
                    ]
                  : [
                      _buildResponsiveTab(loc.dashboard, Icons.info_outline),
                      _buildResponsiveTab(loc.milk, MdiIcons.bucketOutline),
                      _buildResponsiveTab('Reproduktion', Icons.auto_graph),
                      _buildResponsiveTab(
                        loc.health,
                        Icons.medical_services_outlined,
                      ),
                      _buildResponsiveTab(loc.calving, MdiIcons.cow),
                    ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _isCalf
                  ? [_buildInfoTab(colorScheme), _buildMedicalTab(colorScheme)]
                  : [
                      _buildInfoTab(colorScheme),
                      _buildMilkTab(colorScheme),
                      ReproductionTab(
                        animalId: _animal.id,
                        animalName: _animal.name,
                        currentStatus: _animal.reproStatus,
                      ),
                      _buildMedicalTab(colorScheme),
                      _buildCalvingTab(colorScheme),
                    ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(colorScheme),
    );
  }

  Tab _buildResponsiveTab(String text, IconData icon) {
    return Tab(
      height: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- INFO TAB (inkl. Dokumente) ---
  Widget _buildInfoTab(ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
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
                  color: _animal.isCalf
                      ? Colors.orange[100]
                      : colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _animal.isCalf ? MdiIcons.babyCarriage : MdiIcons.cow,
                  size: 48,
                  color: _animal.isCalf
                      ? Colors.deepOrange
                      : colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _animal.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              if (!_animal.isCalf)
                Chip(
                  label: Text(
                    ReproductionCalculator.mapStatusToGerman(
                      _animal.reproStatus,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getReproColor(_animal.reproStatus),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              Text(
                'Ohrmarke: ${_animal.earTagNumber}',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Allgemein', colorScheme),
        _buildInfoRow(
          'Geburtsdatum',
          _dateFormat.format(_animal.birthDate),
          colorScheme,
        ),
        _buildInfoRow(
          'Alter',
          _calculateAgeText(_animal.birthDate),
          colorScheme,
        ),
        if (_animal.breed.isNotEmpty)
          _buildInfoRow('Rasse', _animal.breed, colorScheme),
        _buildInfoRow('Geschlecht', _animal.gender, colorScheme),
        const SizedBox(height: 16),
        if (_animal.isCalf) ...[
          _buildSectionHeader('Kälber-Details', colorScheme),
          if (_animal.motherId != null && _animal.motherId!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mutter',
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (widget.dbService != null)
                    MotherNameDisplay(
                      motherId: _animal.motherId!,
                      dbService: widget.dbService!,
                    ),
                ],
              ),
            ),
          if (_animal.weaningDate != null)
            _buildInfoRow(
              'Absetzdatum',
              _dateFormat.format(_animal.weaningDate!),
              colorScheme,
            ),
          if (_animal.fatherId != null && _animal.fatherId!.isNotEmpty)
            _buildInfoRow('Vater', _animal.fatherId!, colorScheme),
        ] else ...[
          _buildSectionHeader('Produktion & Reproduktion', colorScheme),
          _buildInfoRow(
            'Laktationsnummer',
            '${_animal.lactationNumber}',
            colorScheme,
          ),
          if (_animal.expectedCalvingDate != null)
            _buildInfoRow(
              'Erw. Kalbetermin',
              _dateFormat.format(_animal.expectedCalvingDate!),
              colorScheme,
              isHighlight: true,
            ),
          if (_animal.dryOffDate != null)
            _buildInfoRow(
              'Trockenstellen am',
              _dateFormat.format(_animal.dryOffDate!),
              colorScheme,
            ),
        ],

        // --- NEU: ZUGEORDNETE DOKUMENTE ---
        const SizedBox(height: 24),
        _buildSectionHeader('Zugeordnete Dokumente', colorScheme),
        if (widget.dbService != null)
          StreamBuilder<List<FarmDocument>>(
            stream: widget.dbService!.getFarmDocumentsForAnimal(_animal.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Fehler: ${snapshot.error}'));
              }

              final docs = snapshot.data ?? [];

              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(left: 4.0, top: 4.0),
                  child: Text(
                    'Keine Dokumente für dieses Tier hinterlegt.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Wichtig in einem ListView
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  // Wir verwenden deine hübsche DetailCard für einheitliches Design
                  return _buildDetailCard(
                    title: doc.title,
                    subtitle: doc.category,
                    date: doc.createdAt,
                    icon: Icons.document_scanner_outlined,
                    iconColor: Colors.indigo,
                    colorScheme: colorScheme,
                    onTap: () {
                      // Beim Tippen öffnet sich der Dialog mit dem Bild
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppBar(
                                title: Text(doc.title),
                                leading: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                // NEU: Share / Download Button
                                actions: [
                                  IconButton(
                                    icon: const Icon(Icons.download),
                                    tooltip: 'Herunterladen / Teilen',
                                    onPressed: () async {
                                      try {
                                        await Share.shareXFiles(
                                          [XFile(doc.storageUrl)],
                                          text: doc.title,
                                        );
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Fehler beim Teilen: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Flexible(
                                child: InteractiveViewer(
                                  child: Image.file(
                                    File(doc.storageUrl),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Padding(
                                        padding: EdgeInsets.all(32.0),
                                        child: Text(
                                          'Bild konnte nicht geladen werden.',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    onDelete: () => _confirmDeletion(
                      context,
                      () => widget.dbService!.deleteFarmDocument(doc.id),
                    ),
                  );
                },
              );
            },
          ),
        const SizedBox(height: 32),
      ],
    );
  }

  Color _getReproColor(String status) {
    switch (status.toLowerCase()) {
      case 'offen':
        return Colors.redAccent;
      case 'belegt':
        return Colors.orange;
      case 'traechtig':
        return Colors.green;
      case 'trocken':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMilkTab(ColorScheme colorScheme) {
    return StreamBuilder<List<MilkYield>>(
      stream: widget.dbService?.getMilkYields(_animal.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        if (list.isEmpty)
          return _buildEmptyState(
            'Keine Milchdaten',
            MdiIcons.bucketOutline,
            colorScheme,
          );
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
              onTap: () => _showAddMilkDialog(record: item),
              onDelete: () => _confirmDeletion(
                context,
                () => widget.dbService?.deleteMilkYield(_animal.id, item.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMedicalTab(ColorScheme colorScheme) {
    return StreamBuilder<List<MedicalRecord>>(
      stream: widget.dbService?.getMedicalRecords(_animal.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        if (list.isEmpty)
          return _buildEmptyState(
            'Keine Behandlungen',
            Icons.medical_services_outlined,
            colorScheme,
          );
        return ListView.builder(
          itemCount: list.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final item = list[index];
            return _buildDetailCard(
              title: item.diagnosis,
              subtitle:
                  '${item.treatment}${item.cost > 0 ? ' (${item.cost.toStringAsFixed(2)} €)' : ''}',
              date: item.date,
              icon: Icons.healing,
              iconColor: Colors.red,
              colorScheme: colorScheme,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditMedicalPage(
                    animal: _animal,
                    dbService: widget.dbService!,
                    record: item,
                  ),
                ),
              ),
              onDelete: () => _confirmDeletion(
                context,
                () =>
                    widget.dbService?.deleteMedicalRecord(_animal.id, item.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalvingTab(ColorScheme colorScheme) {
    return StreamBuilder<List<CalvingHistory>>(
      stream: widget.dbService?.getCalvingHistory(_animal.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        if (list.isEmpty)
          return _buildEmptyState(
            'Keine Kalbungen',
            MdiIcons.babyCarriageOff,
            colorScheme,
          );
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditCalvingPage(
                    animal: _animal,
                    dbService: widget.dbService!,
                    record: item,
                  ),
                ),
              ),
              onDelete: () => _confirmDeletion(
                context,
                () =>
                    widget.dbService?.deleteCalvingHistory(_animal.id, item.id),
              ),
            );
          },
        );
      },
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

  Widget _buildInfoRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isHighlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isHighlight
            ? colorScheme.errorContainer.withOpacity(0.2)
            : colorScheme.surface,
        border: Border.all(
          color: isHighlight
              ? colorScheme.error.withOpacity(0.5)
              : colorScheme.outlineVariant.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
          ),
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

  Widget _buildDetailCard({
    required String title,
    required String subtitle,
    required DateTime date,
    required IconData icon,
    required Color iconColor,
    required ColorScheme colorScheme,
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _dateFormat.format(date),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: colorScheme.error,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    String message,
    IconData icon,
    ColorScheme colorScheme,
  ) {
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

  Widget? _buildFloatingActionButton(ColorScheme colorScheme) {
    if (_tabController.index == 0) return null;
    if (_isCalf) {
      if (_tabController.index == 1)
        return _styledFab(
          colorScheme,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditMedicalPage(
                animal: _animal,
                dbService: widget.dbService!,
              ),
            ),
          ),
        );
      return null;
    } else {
      switch (_tabController.index) {
        case 1:
          return _styledFab(colorScheme, () => _showAddMilkDialog());
        case 2:
          return _styledFab(
            colorScheme,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddReproEventPage(
                  animalId: _animal.id,
                  animalName: _animal.name,
                ),
              ),
            ),
          );
        case 3:
          return _styledFab(
            colorScheme,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditMedicalPage(
                  animal: _animal,
                  dbService: widget.dbService!,
                ),
              ),
            ),
          );
        case 4:
          return _styledFab(
            colorScheme,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditCalvingPage(
                  animal: _animal,
                  dbService: widget.dbService!,
                ),
              ),
            ),
          );
        default:
          return null;
      }
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

  void _showAddMilkDialog({MilkYield? record}) {
    final amountController = TextEditingController(
      text: record?.amountLiters.toString(),
    );
    String session = record?.session ?? 'Morgens';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          record == null ? 'Milchmenge erfassen' : 'Milchmenge bearbeiten',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Liter'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: session,
              decoration: InputDecoration(
                labelText: 'Session',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.schedule),
              ),
              items: [
                'Morgens',
                'Abends',
                'Mittags',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => session = val!,
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
              final newRecord = MilkYield(
                id: record?.id ?? '',
                date: record?.date ?? DateTime.now(),
                amountLiters: double.tryParse(amountController.text) ?? 0.0,
                session: session,
              );
              if (record == null)
                widget.dbService?.addMilkYield(_animal.id, newRecord);
              else
                widget.dbService?.updateMilkYield(_animal.id, newRecord);
              Navigator.pop(context);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletion(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Löschen bestätigen?'),
        content: const Text('Dieser Eintrag wird unwiderruflich entfernt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}

class MotherNameDisplay extends StatelessWidget {
  final String motherId;
  final DatabaseService dbService;
  const MotherNameDisplay({
    super.key,
    required this.motherId,
    required this.dbService,
  });
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Animal>(
      stream: dbService.getAnimal(motherId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Text("Lädt...");
        if (snapshot.hasError || !snapshot.hasData)
          return const Text("Unbekannt");
        return Text(
          snapshot.data!.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      },
    );
  }
}