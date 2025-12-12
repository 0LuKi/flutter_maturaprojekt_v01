import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_maturaprojekt_v01/content/cow_list.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'package:flutter_maturaprojekt_v01/models/animal.dart';
import 'package:flutter_maturaprojekt_v01/models/calving_history.dart';
import 'package:flutter_maturaprojekt_v01/services/auth_service.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';

class LivestockPage extends StatefulWidget {
  const LivestockPage({super.key});

  @override
  State<LivestockPage> createState() => _LivestockPageState();
}

class _LivestockPageState extends State<LivestockPage> {
  DatabaseService? _dbService;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _dbService = DatabaseService(userId: user.uid);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // --- HEADER ---
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.livestock,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isDesktop
                      ? IconButton(
                          onPressed: _signOut,
                          tooltip: loc.sign_out ?? "Logout",
                          icon: const Icon(Icons.logout),
                          color: colorScheme.error,
                        )
                      : IconButton(
                          onPressed: () {
                            try {
                              Scaffold.of(context).openEndDrawer();
                            } catch (e) {
                              debugPrint("Kein Drawer gefunden");
                            }
                          },
                          tooltip: loc.menu ?? "Menu",
                          icon: const Icon(Icons.menu_rounded),
                          color: colorScheme.onSurfaceVariant,
                        ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // --- SEARCH BAR ---
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: loc.search ?? 'Suche...',
                    prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // --- CONTENT ---
              Expanded(
                child: _dbService == null
                    ? const Center(child: CircularProgressIndicator())
                    : CowList(dbService: _dbService!),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAnimalDialog(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- NEUER UMFASSENDER DIALOG ---
  void _showAddAnimalDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final earTagCtrl = TextEditingController();
    final breedCtrl = TextEditingController();
    final motherCtrl = TextEditingController();
    final fatherCtrl = TextEditingController(); 
    final lactationCtrl = TextEditingController(text: '0');

    DateTime birthDate = DateTime.now();
    String gender = 'Weiblich';
    bool isCalf = false;
    
    DateTime? weaningDate;
    DateTime? lastInseminationDate;
    DateTime? nextCheckDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final colorScheme = Theme.of(context).colorScheme;

            return AlertDialog(
              title: const Text('Neues Tier erfassen'),
              scrollable: true,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Allgemein', colorScheme),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameCtrl,
                    decoration: _inputDeco('Name / Rufname', Icons.edit),
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
                      final picked = await showDatePicker(
                        context: context, 
                        initialDate: birthDate, 
                        firstDate: DateTime(2000), 
                        lastDate: DateTime.now()
                      );
                      if (picked != null) setState(() => birthDate = picked);
                    }
                  ),

                  const SizedBox(height: 20),
                  
                  _buildSectionTitle('Eigenschaften & Abstammung', colorScheme),
                  const SizedBox(height: 8),
                  TextField(
                    controller: breedCtrl,
                    decoration: _inputDeco('Rasse', Icons.pets),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: motherCtrl,
                          decoration: _inputDeco('Mutter', Icons.female),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: fatherCtrl,
                          decoration: _inputDeco('Vater', Icons.male),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: _inputDeco('Geschlecht', Icons.wc),
                    items: ['Weiblich', 'Männlich'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => gender = val!),
                  ),

                  const SizedBox(height: 20),

                  SwitchListTile(
                    title: const Text('Ist es ein Kalb?'),
                    subtitle: const Text('Aktiviert Kälber-spezifische Felder'),
                    secondary: Icon(isCalf ? Icons.child_care : Icons.grass),
                    value: isCalf,
                    activeColor: colorScheme.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => isCalf = val),
                  ),

                  const SizedBox(height: 10),
                  
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: isCalf ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    
                    firstChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Aufzucht', colorScheme),
                        const SizedBox(height: 8),
                        _buildDatePickerField(
                          label: 'Geplantes Absetzdatum', 
                          value: weaningDate, 
                          onTap: () async {
                            final picked = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 90)), firstDate: DateTime.now(), lastDate: DateTime(2030));
                            if (picked != null) setState(() => weaningDate = picked);
                          }
                        ),
                      ],
                    ),

                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Produktion', colorScheme),
                        const SizedBox(height: 8),
                        TextField(
                          controller: lactationCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDeco('Laktationsnummer', Icons.numbers),
                        ),
                        const SizedBox(height: 12),
                        _buildDatePickerField(
                          label: 'Letzte Besamung', 
                          value: lastInseminationDate, 
                          onTap: () async {
                            final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                            if (picked != null) setState(() => lastInseminationDate = picked);
                          }
                        ),
                        const SizedBox(height: 12),
                        _buildDatePickerField(
                          label: 'Nächster Trächtigkeitscheck', 
                          value: nextCheckDate, 
                          isHighlight: true,
                          onTap: () async {
                            final picked = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime(2030));
                            if (picked != null) setState(() => nextCheckDate = picked);
                          }
                        ),
                      ],
                    ),
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

                    final newAnimal = Animal(
                      id: '', 
                      name: nameCtrl.text,
                      earTagNumber: earTagCtrl.text,
                      birthDate: birthDate,
                      breed: breedCtrl.text,
                      gender: gender,
                      isCalf: isCalf,
                      motherId: motherCtrl.text.isNotEmpty ? motherCtrl.text : null,
                      fatherId: fatherCtrl.text.isNotEmpty ? fatherCtrl.text : null,
                      weaningDate: isCalf ? weaningDate : null,
                      lactationNumber: isCalf ? 0 : (int.tryParse(lactationCtrl.text) ?? 0),
                      lastInseminationDate: !isCalf ? lastInseminationDate : null,
                      nextPregnancyCheckDate: !isCalf ? nextCheckDate : null,
                    );

                    if (isCalf && motherCtrl.text.isNotEmpty) {
                      _dbService!.addCalfWithMotherLink(
                        calf: newAnimal, 
                        motherIdentifier: motherCtrl.text, 
                        calvingDetails: CalvingHistory(
                          date: birthDate, 
                          calvingCourse: 'Normal', 
                          calfCount: '1',
                        )
                      );
                    } else {
                      _dbService!.addAnimal(newAnimal);
                    }
                    
                    Navigator.pop(context);
                  },
                  child: const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
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
          letterSpacing: 1.0
        ),
      ),
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
          prefixIcon: Icon(
            Icons.calendar_today, 
            size: 20, 
            color: isHighlight ? Colors.red : null
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          enabledBorder: isHighlight 
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), 
                  borderSide: const BorderSide(color: Colors.red)
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