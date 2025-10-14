import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/theme/colors.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary)
      ),     // TODO Dark Theme
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(

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
              foregroundColor: AppColors.onPrimary,
              backgroundColor: AppColors.primary,
            ),

            // Liste container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.onPrimary,
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
                          fillColor: AppColors.onPrimaryAccent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

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
            )
          ],
        ),
      ),

      // Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: "Livestock",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Appointments"  
          )
        ]
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
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 5),
      color: AppColors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.onPrimaryAccent,
          width: 2
        )
      ),
      child: ListTile(
        title: Text(id, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(name),
      )
    );
  }
}