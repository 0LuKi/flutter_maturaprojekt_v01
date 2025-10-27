import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_maturaprojekt_v01/content/appointments_page.dart';
import 'package:flutter_maturaprojekt_v01/content/dashboard_page.dart';
import 'package:flutter_maturaprojekt_v01/content/livestock_page.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';
import 'package:flutter_maturaprojekt_v01/content/register_page.dart';
import 'package:flutter_maturaprojekt_v01/menus/bottom_nav_bar.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



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

        final ThemeData baseLight = AppTheme.lightTheme;
        final ThemeData baseDark = AppTheme.darkTheme;

        return MaterialApp(
          title: 'Flutter Demo',
          theme: baseLight,
          darkTheme: baseLight,        // danach auf baseDark ändern
          themeMode: ThemeMode.system,
          home: RegisterPage(),
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

  final List<Widget> pages = <Widget>[
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
