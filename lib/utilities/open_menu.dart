import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class OpenMenu extends StatefulWidget {
  const OpenMenu({super.key});

  @override
  State<OpenMenu> createState() => OpenMenuState();
}

class OpenMenuState extends State<OpenMenu> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final user = FirebaseAuth.instance.currentUser;

    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: Colors.transparent, width: 0)
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(MdiIcons.accountCircle, size: 60),
                    SizedBox(height: 10),
                    Text(
                      "Welcome, ${user?.displayName}",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 24
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                ListTile(
                  leading: Icon(MdiIcons.homeAnalytics),
                  title: Text(loc.dashboard),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(MdiIcons.cow),
                title: Text(loc.livestock),
                onTap: () {},
                ),
                ListTile(
                  leading: Icon(MdiIcons.calendar),
                  title: Text(loc.appointments),
                  onTap: () {},
                ),
              ],
            ),
          ]
        )
      );
  }
}