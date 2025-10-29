import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_maturaprojekt_v01/content/appointments_page.dart';
import 'package:flutter_maturaprojekt_v01/content/dashboard_page.dart';
import 'package:flutter_maturaprojekt_v01/content/livestock_page.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';
import 'package:flutter_maturaprojekt_v01/utilities/bottom_nav_bar.dart';
import 'package:flutter_maturaprojekt_v01/theme/colors.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );

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
            Colors.white
          ),       // NICHT VERGESSEN hier Farbe für Buttons auch ändern
        );
        final ThemeData baseDark = AppTheme.darkTheme;

        return MaterialApp(
          title: "FarmManager",
          theme: baseLight,
          darkTheme: baseLight,        // danach auf baseDark ändern
          themeMode: ThemeMode.system,

          // Andere Sprachen
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('de')
          ],

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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData) {
                return const HomePage();
              } else {
                return const LoginPage();
              }
            }
          ),
        );
      }
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

  final pages = [
    DashboardPage(),
    LivestockPage(),
    AppointmentsPage(),
  ];

  void onTabChanged(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentPageIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentPageIndex,
        onIndexChanged: onTabChanged,
      ),
    );
  }
}
