import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';
import 'package:flutter_maturaprojekt_v01/main.dart';
import 'package:flutter_maturaprojekt_v01/services/auth_service.dart';
import 'package:flutter_maturaprojekt_v01/utilities/pressable_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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

    OutlineInputBorder normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: colorScheme.outline)
    );

    OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.red)
    );

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
                        "Sign up to create an account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                        )
                      ),
              
                      SizedBox(height: 8),
              
                      Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Enter your Name",
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
                          enabledBorder: passwordError ? errorBorder : normalBorder,
                          focusedBorder: passwordError ? errorBorder : normalBorder
                        ),
                      ),
              
                      SizedBox(height: 15),
              
                      Text("Retype password", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        obscureText: obscurePassword,
                        controller: passwordRepeatController,
                        decoration: InputDecoration(
                          hintText: "Retype your password",
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
                          enabledBorder: passwordError ? errorBorder : normalBorder,
                          focusedBorder: passwordError ? errorBorder : normalBorder
                        ),
                      ),
              
                      if (passwordError) 
              
                        Row(
                          spacing: 3,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(MdiIcons.alertCircleOutline, color: Colors.red,),
                            Text(
                              "Passwords do not match",
                              style: TextStyle(color: Colors.red)
                            ),
                          ],
                        ),
                        
                      SizedBox(height: 20),
                        
                      Center(
                        child: Column(
                          children: [
                            FilledButton(
                            onPressed: () async {
                              if (passwordController.text != passwordRepeatController.text) {
                                setState(() {
                                  passwordError = true;
                                });
                                return;
                              }

                              await signup();
                            },

                          child: Text(
                            "Sign up", 
                            style: TextStyle(
                              fontSize: 20,
                              color: colorScheme.onPrimary
                            )
                          )
                        ),

                            SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? "
                                ),
                                PressableText(
                                  text: "Log in", 
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage()
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

  signup() async {
    final user = await _auth.createUserWithEmailAndPassword(emailController.text, passwordController.text);
    if (user != null) {
      log("User created successfully");
      if (!mounted) return;
      goToHome(context);
    }
  }
}