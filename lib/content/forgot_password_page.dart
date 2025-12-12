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

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    final loc = AppLocalizations.of(context)!;

    final colorScheme = Theme.of(context).colorScheme;


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (context) => const LoginPage()), 
              (route) => false
            );
          }, 
          icon: const Icon(Icons.arrow_back_rounded)
        ),

      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        loc.forgot_password,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      loc.reset_passwd_text1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15
                      )
                    ),
                    const SizedBox(height: 60),
                    Text(loc.email, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              await authService.resetPassword(emailController.text.trim());
                          
                              if (emailController.text.trim().isNotEmpty && context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EmailSent(email: emailController.text.trim())
                                  )
                                );
                              }
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                            child: Text(
                              loc.send_email, 
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onPrimary
                              )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}