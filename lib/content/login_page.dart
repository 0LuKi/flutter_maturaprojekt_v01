import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/forgot_password_page.dart';
import 'package:flutter_maturaprojekt_v01/content/register_page.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
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
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool wrongCred = false;

  void checkPassword() {

  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
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
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: const Image(
                        image: AssetImage('assets/images/FarmManager_LOGO3.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          loc.please_login,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        ),
                
                        const SizedBox(height: 20),
                
                        Text(loc.email, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          onChanged: (_) {
                            if (wrongCred) setState(() => wrongCred = false);
                          },
                          decoration: InputDecoration(
                            hintText: loc.enter_email,
                            hintStyle: TextStyle(
                              color: colorScheme.outline
                            ),
                            filled: false,
                            enabledBorder: wrongCred ? errorBorder : normalBorder,
                            focusedBorder: wrongCred ? errorBorder : normalBorder
                          ),
                        ),
                        
                        const SizedBox(height: 15),
                
                        Text(loc.password, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          obscureText: obscurePassword,
                          controller: passwordController,
                          onChanged: (_) {
                            if (wrongCred) setState(() => wrongCred = false);
                          },
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
                            enabledBorder: wrongCred ? errorBorder : normalBorder,
                            focusedBorder: wrongCred ? errorBorder : normalBorder
                          ),
                        ),
                        
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              wrongCred ? loc.incorrect_cred : "",
                              style: TextStyle(
                                color: colorScheme.error
                              )
                            ),
                            PressableText(
                              text: "${loc.forgot_password_question}?", 
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ForgotPassword()
                                  )
                                );
                              }, 
                              style: TextStyle(
                                color: colorScheme.primary,
                              )
                            ),
                          ],
                        ),
            
                        const SizedBox(height: 30),
                          
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: isLoading ? null : () async {
                                  await login();
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                ),
                                child: isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          colorScheme.onPrimary
                                        ),
                                      ),
                                    ) 
                                  : Text(
                                      loc.login, 
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: colorScheme.onPrimary
                                      )
                                    ),
                              ),
                            ),
            
                            const SizedBox(height: 30),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${loc.dont_have_account}? "
                                ),
                                if (!isLoading)
                                  PressableText(
                                    text: loc.signup, 
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const RegisterPage()
                                        )
                                      );
                                    }, 
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold
                                    ) 
                                  ),
                              ],
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

  goToHome(BuildContext context) => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
  );

  login() async {
    setState(() => isLoading = true);

    try{

      final user = await _auth.signInWithEmailAndPassword(emailController.text.trim(), passwordController.text.trim());
      
      if (user != null) {
        log("User logged in successfully");
        if (!mounted) return;
        setState(() => wrongCred = false);
        goToHome(context);
      }
    } on FirebaseAuthException catch (e) {
      log("login error: ${e.code}");

      // Detect wrong password error
      if (e.code == 'wrong-password' ||
          e.code == 'user-not-found' ||
          e.code == 'invalid-credential') {
        setState(() => wrongCred = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Something went wrong.")),
        );
      }

    } catch (e) {
      log("Unexpected login error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}