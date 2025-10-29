import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/services/auth_service.dart';

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
    return Scaffold(
      backgroundColor: colorScheme.primary,

      body: Stack(
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
                        onPressed: () {  },
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
                          FilledButton(
                            onPressed: () async {
                              await signout();
                            }, 
                            child: Text(loc.sign_out)
                          ),
                          Text("Welcome, ${user?.displayName ?? 'User'}")
                        ],
                      )
                    )
                  )
                ),
              ],
            ),
          ),
        ],
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