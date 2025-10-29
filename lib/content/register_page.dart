import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
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
  bool userExists = false;

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
    final loc = AppLocalizations.of(context)!;

    final colorScheme = Theme.of(context).colorScheme;

    OutlineInputBorder normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: colorScheme.outline)
    );

    OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: colorScheme.error)
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
                        loc.signup_create,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                        )
                      ),
              
                      SizedBox(height: 8),
              
                      Text(loc.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: loc.enter_name,
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
              
                      Text(loc.email, style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: emailController,
                        onChanged: (_) {
                          if (userExists) setState(() => userExists = false);
                        },
                        decoration: InputDecoration(
                          hintText: loc.enter_email,
                          hintStyle: TextStyle(
                            color: colorScheme.outline
                          ),
                          filled: false,
                          enabledBorder: userExists ? errorBorder : normalBorder,
                          focusedBorder: userExists ? errorBorder : normalBorder
                        ),
                      ),
                      if (userExists)
                        Text(
                          loc.email_in_use + ".",
                          style: TextStyle(
                            color: colorScheme.error
                          )
                        ),
              
                      SizedBox(height: 15),
              
                      Text(loc.password, style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        obscureText: obscurePassword,
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: loc.enter_password,
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
              
                      Text(loc.retype_password, style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        obscureText: obscurePassword,
                        controller: passwordRepeatController,
                        decoration: InputDecoration(
                          hintText: loc.retype_password2,
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
                            Icon(MdiIcons.alertCircleOutline, color: colorScheme.error,),
                            Text(
                              loc.diff_passwords,
                              style: TextStyle(color: colorScheme.error)
                            ),
                          ],
                        ),
                        
                      SizedBox(height: 40),
                        
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

                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30),
                                child: Text(
                                  loc.signup, 
                                  style: TextStyle(
                                    fontSize: 15,
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
                                  loc.have_account + "? "
                                ),
                                PressableText(
                                  text: loc.login, 
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

  goToHome(BuildContext context) => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
  );

  signup() async {

    try {
      final user = await _auth.createUserWithEmailAndPassword(emailController.text, passwordController.text);
      if (user != null) {
        log("User created successfully");

        await user.updateDisplayName(nameController.text);
        await user.reload();

        if (!mounted) return;
        setState(() => userExists = false);
        goToHome(context);
      }
    } on FirebaseAuthException catch(e) {
      log("singup error: ${e.code}");

      // Detect if user already exists
      if (e.code == 'email-already-in-use') {
        setState(() => userExists = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Something went wrong"))
        );
      }
    } catch (e) {
      log("Unexpected signup error: $e");
    }
    
  }
}