import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_maturaprojekt_v01/content/appointments_page.dart';
import 'package:flutter_maturaprojekt_v01/content/dashboard_page.dart';
import 'package:flutter_maturaprojekt_v01/content/livestock_page.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';
import 'package:flutter_maturaprojekt_v01/utilities/bottom_nav_bar.dart';
import 'package:flutter_maturaprojekt_v01/theme/colors.dart';
import 'package:flutter_maturaprojekt_v01/utilities/open_menu.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // This file contains the web keys
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // FIX: This line MUST have 'options' to work on Web
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (e) {
    debugPrint("Persistence not supported on this platform: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ThemeData baseLight = AppTheme.lightTheme.copyWith(
          filledButtonTheme: AppTheme.filledButtonTheme(
            ColorsLight.primary,
            Colors.white,
          ), 
        );
        final ThemeData baseDark = AppTheme.darkTheme;

        return MaterialApp(
          title: "FarmManager",
          theme: baseLight,
          darkTheme: baseLight, // danach auf baseDark ändern
          themeMode: ThemeMode.system,

          // Andere Sprachen
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de')],

          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocales in supportedLocales) {
              if (supportedLocales.languageCode == locale?.languageCode) {
                return supportedLocales;
              }
            }
            return supportedLocales.first;
          },

          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // Waiting state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Logged in
              if (snapshot.hasData) {
                return const HomePage();
              } 
              // Not logged in
              else {
                return const LoginPage();
              }
            },
          ),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  void onTabChanged(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    // Check screen width to determine layout mode
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final isWide = screenWidth > 1200;

    final pages = [
      DashboardPage(changeTab: onTabChanged),
      const LivestockPage(),
      const AppointmentsPage(),
    ];

    return Scaffold(
      // On desktop, use a slightly distinct background color to create a "sheet" effect for the content
      backgroundColor: isDesktop ? colorScheme.surfaceContainerHigh : colorScheme.surface,
      endDrawer: OpenMenu(
        currentIndex: currentPageIndex,
        onIndexChanged: onTabChanged,
      ),
      body: isDesktop
          ? Row(
              children: [
                // Navigation Rail for Desktop/Tablet
                NavigationRail(
                  backgroundColor: colorScheme.surface,
                  selectedIndex: currentPageIndex,
                  onDestinationSelected: onTabChanged,
                  extended: isWide,
                  minExtendedWidth: 200,
                  labelType: isWide ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.dashboard_outlined),
                      selectedIcon: const Icon(Icons.dashboard),
                      label: Text(loc?.dashboard ?? 'Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.pets_outlined),
                      selectedIcon: const Icon(Icons.pets),
                      label: Text(loc?.livestock ?? 'Herde'),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.calendar_today_outlined),
                      selectedIcon: const Icon(Icons.calendar_today),
                      label: Text(loc?.appointments ?? 'Aufgaben'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                // Content Area
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias, // Clips the inner Scaffolds to the rounded corners
                        child: IndexedStack(index: currentPageIndex, children: pages),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : IndexedStack(index: currentPageIndex, children: pages), // Mobile Layout
      
      // Bottom Navigation Bar only for Mobile
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavBar(
              currentIndex: currentPageIndex,
              onIndexChanged: onTabChanged,
            ),
    );
  }
}