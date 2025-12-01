import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/services/auth_service.dart';

import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    final user = FirebaseAuth.instance.currentUser;
    
    final colorScheme = Theme.of(context).colorScheme;
    final double topSafeArea = MediaQuery.of(context).padding.top;
    
    // Dashboard page (opening page)
    return Stack(
        children: [
          Column(
            children: [
              Container(
                height: topSafeArea + 100,
                color: colorScheme.primary
              ),
              Expanded(
                child: Container(
                  color: colorScheme.onPrimary
                )
              )
            ]
          ),

          SafeArea(
            // AppBar
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppBar(
                    title: Text(
                      loc.dashboard,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      )
                    ),
                    actions: [
                      IconButton(
                        onPressed: () => {
                          Scaffold.of(context).openEndDrawer()
                        },
                        tooltip: "Menu",
                        icon: Icon(Icons.menu_rounded, size: 40),
                        
                      )
                    ],
                    foregroundColor: colorScheme.onPrimary,
                    backgroundColor: Colors.transparent,
                  ),
                ),
            
                // Liste container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)
                      )
                    ),
                              
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          
                          Text("Welcome, ${user?.displayName ?? 'User'}"),



                          // Bar Chart WIP add it here
                          
                          const SizedBox(height: 40),
                          
                          AspectRatio(
                            aspectRatio: 1.5,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 20,
                                // Hide Grid lines for cleaner look
                                gridData: const FlGridData(show: false),
                                // Hide the border around the chart
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  // Hide Top and Right labels
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  // Customize Left Y-Axis labels
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      interval: 5, // Interval of numbers
                                    ),
                                  ),
                                  // Customize Bottom X-Axis labels
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        const style = TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        );
                                        Widget text;
                                        switch (value.toInt()) {
                                          case 0:
                                            text = const Text('Mon', style: style);
                                            break;
                                          case 1:
                                            text = const Text('Tue', style: style);
                                            break;
                                          case 2:
                                            text = const Text('Wed', style: style);
                                            break;
                                          case 3:
                                            text = const Text('Thu', style: style);
                                            break;
                                          case 4:
                                            text = const Text('Fri', style: style);
                                            break;
                                          case 5:
                                            text = const Text('Sat', style: style);
                                            break;
                                          case 6:
                                            text = const Text("Sun", style: style);
                                            break;
                                          default:
                                            text = const Text('', style: style);
                                            break;
                                        }
                                        return SideTitleWidget(
                                          meta: meta,
                                          space: 4,
                                          child: text,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // THE DATA POINTS
                                barGroups: [
                                  BarChartGroupData(
                                    x: 0,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 8,
                                        color: colorScheme.primary,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 1,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 12,
                                        color: colorScheme.primary,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 2,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 16,
                                        color: colorScheme.primary,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 3,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 6,
                                        color: colorScheme.primary,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 4,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 19,
                                        color: colorScheme.primary,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 5,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 8,
                                        color: colorScheme.primary,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 6,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 16,
                                        color: colorScheme.primary,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),



                          // LOGOUT button
                          SizedBox(height: 40),

                          FilledButton(
                            onPressed: () async {
                              await signout();
                            }, 
                            child: Text(loc.sign_out)
                          ),





                        ],
                      )
                    )
                  )
                ),
              ],
            ),
          ),
        ],  
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