import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.onSurface, width: 0.05),
        ),
      ),
      child: NavigationBar(
        backgroundColor: colorScheme.surfaceContainer,
        height: 80,
        elevation: 0,
        indicatorColor: colorScheme.primary,
        selectedIndex: currentIndex,
        onDestinationSelected: onIndexChanged,
        destinations: [
          NavigationDestination(
            icon: Icon(MdiIcons.homeAnalytics),
            selectedIcon: Icon(MdiIcons.homeAnalytics),
            label: loc.dashboard,
          ),
          NavigationDestination(
            icon: Icon(MdiIcons.cow),
            selectedIcon: Icon(MdiIcons.cow),
            label: loc.livestock,
          ),
          NavigationDestination(
            icon: Icon(MdiIcons.calendar),
            selectedIcon: Icon(MdiIcons.calendar),
            label: loc.appointments,
          ),
        ],
      ),
    );
  }
}
