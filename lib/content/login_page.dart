import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/register_page.dart';
import 'package:flutter_maturaprojekt_v01/main.dart';
import 'package:flutter_maturaprojekt_v01/services/auth_service.dart';
import 'package:flutter_maturaprojekt_v01/utilities/pressable_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();

  bool obscurePassword = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordRepeatController = TextEditingController();

  bool passwordError = false;

  void checkPasswordsMatch() {
    setState(() {
      passwordError = passwordController.text.isNotEmpty &&
                      passwordRepeatController.text.isNotEmpty && 
                      passwordController.text != passwordRepeatController.text;
    });
  }

  @override
  void initState() {
    super.initState();

    passwordController.addListener(checkPasswordsMatch);
    passwordRepeatController.addListener(checkPasswordsMatch);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordRepeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,

                spacing: 30,

                children: [
                        
                  Image(
                    image: AssetImage('assets/images/FarmManager_LOGO3.png'),
                        
                  ),
              
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 5,
              
                    children: [
              
                      Text(
                        "Please log in to your account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                        )
                      ),
              
                      SizedBox(height: 8),
              
                      Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Enter your email",
                          hintStyle: TextStyle(
                            color: colorScheme.outline
                          ),
                          filled: false,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: colorScheme.outline
                            )
                          ),
                        ),
                      ),
              
                      SizedBox(height: 15),
              
                      Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        obscureText: obscurePassword,
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          hintStyle: TextStyle(
                            color: colorScheme.outline
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword ? MdiIcons.eyeOff : MdiIcons.eye
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          filled: false,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: colorScheme.outline
                            )
                          ),
                        ),
                      ),

                      SizedBox(height: 40),
                        
                      Center(
                        child: Column(
                          children: [
                            FilledButton(
                              onPressed: () async {
                                await login();
                              },
                            
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30),
                                child: Text(
                                  "Log in", 
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: colorScheme.onPrimary
                                  )
                                ),
                              )
                            ),

                            SizedBox(height: 30),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? "
                                ),
                                PressableText(
                                  text: "Sign up", 
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RegisterPage()
                                      )
                                    );
                                  }, 
                                  style: TextStyle(
                                    color: colorScheme.primary
                                  ) 
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  goToHome(BuildContext context) => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const HomePage())
  );

  login() async {
    final user = await _auth.signInWithEmailAndPassword(emailController.text, passwordController.text);
    if (user != null) {
      log("User logged in successfully");
      if (!mounted) return;
      goToHome(context);
    }
  }
}