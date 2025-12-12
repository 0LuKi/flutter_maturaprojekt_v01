import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/services/auth_service.dart';
import 'package:flutter_maturaprojekt_v01/utilities/globals.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class OpenMenu extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const OpenMenu({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged
  });

  @override
  State<OpenMenu> createState() => OpenMenuState();
}

class OpenMenuState extends State<OpenMenu> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    // Helper for initials if no photo is available
    String initials() {
      final name = user?.displayName;
      if (name != null && name.trim().isNotEmpty) {
        final parts = name.trim().split(RegExp(r'\s+'));
        return parts.take(2).map((p) => p[0]).join().toUpperCase();
      }
      final email = user?.email;
      return (email != null && email.isNotEmpty) ? email[0].toUpperCase() : '?';
    }

    return Drawer(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      width: 300, // Slightly wider for a premium feel
      child: SafeArea(
        child: Column(
          children: [
            // --- MODERN HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.outlineVariant, width: 1),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
                      child: (user?.photoURL == null) 
                          ? Text(initials(), style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 18)) 
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user?.displayName ?? loc.welcome,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),

            // --- NAVIGATION ITEMS ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildModernNavItem(
                    context, 
                    icon: MdiIcons.homeAnalytics, 
                    label: loc.dashboard, 
                    index: 0,
                    colorScheme: colorScheme,
                  ),
                  _buildModernNavItem(
                    context, 
                    icon: MdiIcons.cow, 
                    label: loc.livestock, 
                    index: 1,
                    colorScheme: colorScheme,
                  ),
                  _buildModernNavItem(
                    context, 
                    icon: MdiIcons.calendar, 
                    label: loc.appointments, 
                    index: 2,
                    colorScheme: colorScheme,
                  ),
                  // Space for more items
                ],
              ),
            ),

            // --- FOOTER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: [
                   ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: Icon(MdiIcons.logout, color: colorScheme.error),
                    title: Text(loc.sign_out, style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      await signout();
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(MdiIcons.copyright, size: 12, color: colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        'FarmManager ${Globals.version}', 
                        style: TextStyle(color: colorScheme.outline, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModernNavItem(BuildContext context, {required IconData icon, required String label, required int index, required ColorScheme colorScheme}) {
    final isSelected = widget.currentIndex == index;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: isSelected ? colorScheme.secondaryContainer : Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(
          icon, 
          color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
          size: 24,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        onTap: () {
          // Close drawer first, then change index
          Navigator.pop(context);
          // Small delay for visual consistency if needed, but direct call is snappier
          widget.onIndexChanged(index);
        },
      ),
    );
  }

  signout() async {
    await _auth.signOut();
    log("User signed out successfully");

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}