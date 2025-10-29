import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/email_sent.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/services/auth_service.dart';

class ForgotPassword extends StatefulWidget {

  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    final loc = AppLocalizations.of(context)!;

    final colorScheme = Theme.of(context).colorScheme;

    bool wrongEmail = false;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (context) => LoginPage()), 
              (route) => false
            );
          }, 
          icon: Icon(Icons.arrow_back_rounded)
        ),

      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 5,
                children: [
                  SizedBox(height: 80),
                  Center(
                    child: Text(
                      loc.forgot_password,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    loc.reset_passwd_text1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15
                    )
                  ),
                  SizedBox(height: 60),
                  Text(loc.email, style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: loc.enter_email,
                      hintStyle: TextStyle(
                        color: colorScheme.outline
                      ),
                      filled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colorScheme.outline)
                      )
                    ),
                  ),
                  SizedBox(height: 30),
                  Column(
                    children: [
                      FilledButton(
                        onPressed: () async {
                          await authService.resetPassword(emailController.text.trim());

                          if (emailController.text.trim().isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmailSent(email: emailController.text.trim())
                              )
                            );
                          }
                        },
                      
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
                          child: Text(
                            loc.send_email, 
                            style: TextStyle(
                              fontSize: 15,
                              color: colorScheme.onPrimary
                            )
                          ),
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}