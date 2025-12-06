import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/services/auth_service.dart';
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

    // color for selected tile (adjust as you like)
    final selectedTileColor = colorScheme.primary.withOpacity(0.12);

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // top group: header + first 3 tiles
              Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(color: Colors.transparent, width: 0),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(MdiIcons.accountCircle, size: 60),
                          SizedBox(height: 10),
                          Text(
                            "${loc.welcome}, ${user?.displayName}",
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(MdiIcons.homeAnalytics),
                    title: Text(loc.dashboard),
                    selected: widget.currentIndex == 0,
                    selectedTileColor: selectedTileColor,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onIndexChanged(0);
                    },
                  ),
                  ListTile(
                    leading: Icon(MdiIcons.cow),
                    title: Text(loc.livestock),
                    selected: widget.currentIndex == 1,
                    selectedTileColor: selectedTileColor,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onIndexChanged(1);
                    },
                  ),
                  ListTile(
                    leading: Icon(MdiIcons.calendar),
                    title: Text(loc.appointments),
                    selected: widget.currentIndex == 2,
                    selectedTileColor: selectedTileColor,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onIndexChanged(2);
                    },
                  ),
                ],
              ),

              // bottom group: logout
              Column(
                children: [
                  ListTile(
                    leading: Icon(MdiIcons.logout),
                    title: Text(loc.sign_out),
                    onTap: () async {
                      await signout();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
     );
   }

  signout() async {
    await _auth.signOut();
    log("User signed out successfully");

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false, // remove all previous routes
    );
  }
}

