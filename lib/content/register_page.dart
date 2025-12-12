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
  bool isLoading = false;

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
                          loc.signup_create,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        ),
                
                        const SizedBox(height: 20),
                
                        Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
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
                        
                        const SizedBox(height: 15),
                
                        Text(loc.email, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
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
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "${loc.email_in_use}.",
                              style: TextStyle(
                                color: colorScheme.error
                              )
                            ),
                          ),
                
                        const SizedBox(height: 15),
                
                        Text(loc.password, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
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
                
                        const SizedBox(height: 15),
                
                        Text(loc.retype_password, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
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
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(MdiIcons.alertCircleOutline, color: colorScheme.error, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  loc.diff_passwords,
                                  style: TextStyle(color: colorScheme.error)
                                ),
                              ],
                            ),
                          ),
                          
                        const SizedBox(height: 40),
                          
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: isLoading ? null : () async {
                                  if (passwordController.text != passwordRepeatController.text) {
                                    setState(() {
                                      passwordError = true;
                                    });
                                    return;
                                  }

                                  await signup();
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
                                      loc.signup, 
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
                                  "${loc.have_account}? "
                                ),
                                if (!isLoading)
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

  signup() async {
    setState(() => isLoading = true);

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

      if (e.code == 'email-already-in-use') {
        setState(() => userExists = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Something went wrong"))
        );
      }
    } catch (e) {
      log("Unexpected signup error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}