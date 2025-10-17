import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_maturaprojekt_v01/theme/colors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {

        final ThemeData lightTheme = lightDynamic != null
            ? ThemeData(
                colorScheme: lightDynamic.harmonized(), // harmonisiert Farben
                useMaterial3: true,
              )
            : AppTheme.lightTheme;

        final ThemeData darkTheme = darkDynamic != null
            ? ThemeData(
                colorScheme: darkDynamic.harmonized(),
                useMaterial3: true,
              )
            : AppTheme.darkTheme;

        return MaterialApp(
          title: 'Flutter Demo',

          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,

          home: const HomePage(),
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

int selectedIndex = 0;

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {

    final double topSafeArea = MediaQuery.of(context).padding.top;

    // 
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.primary,

      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: topSafeArea + 100,
                color: Theme.of(context).colorScheme.primary
                //color: ColorsLight.primary,
              ),
              Expanded(
                child: Container(
                  //color: ColorsLight.onPrimary
                )
              )
            ]
          ),

          SafeArea(
            // AppBar
            child: Column(
              children: [
                AppBar(
                  title: const Text(
                    'Livestock',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    )
                  ),
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  //foregroundColor: ColorsLight.onPrimary,
                  backgroundColor: Colors.transparent,
                ),
            
                // Liste container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)
                      )
                    ),
                              
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: "Search",
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.outlineVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                              
                          const SizedBox(height: 15),
                  
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  CowCard(id: "IT412345", name: "Lunte"),
                                  CowCard(id: "IT412345", name: "Lunte"),
                                  CowCard(id: "IT412345", name: "Lunte"),
                                  CowCard(id: "IT412345", name: "Lunte"),
                                  CowCard(id: "IT412345", name: "Lunte"),
                                ]
                              ),
                            ),
                          )
                        ]
                      )
                    )
                  )
                ),
              ],
            ),
          ),
        ],
      ),

      // Floating Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: 0.05
          ))
        ),
        child: NavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          height: 80,
          elevation: 0,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        
          destinations: [
            NavigationDestination(
              icon: Icon(MdiIcons.cow),
              selectedIcon: Icon(MdiIcons.cow), 
              label: "Livestock"
            ),
            NavigationDestination(
              icon: Icon(MdiIcons.calendarOutline), 
              selectedIcon: Icon(MdiIcons.calendar),
              label: "Appointments"
            ),
          ],
        ),
      ),
    );
  }
}


class CowCard extends StatelessWidget {

  final String id;
  final String name;

  const CowCard({super.key, required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 5),
        color: Theme.of(context).colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.transparent,
            width: 0
          ),
        ),
        child: ListTile(
          title: Text(id, style: TextStyle(
            fontWeight: FontWeight.bold,
            //color: ColorsLight.onPrimaryAccent2
          )),
          subtitle: Text(name, style: TextStyle(
            //color: ColorsLight.onPrimaryAccent2
          )),
        )
      ),
    );
  }
}