import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/add_animal_page.dart';
import 'package:flutter_maturaprojekt_v01/content/cow_list.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
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
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.5,
                      ),
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
                  ),
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
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
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
        onPressed: _dbService == null
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddAnimalPage(dbService: _dbService!),
                  ),
                );
              },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
