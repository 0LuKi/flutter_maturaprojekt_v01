import 'package:flutter/material.dart';
import 'package:flutter_maturaprojekt_v01/content/forgot_password_page.dart';
import 'package:flutter_maturaprojekt_v01/content/login_page.dart';
import 'package:flutter_maturaprojekt_v01/l10n/app_localizations.dart';
import 'package:flutter_maturaprojekt_v01/utilities/pressable_text.dart';

class EmailSent extends StatefulWidget {
  final String email;

  const EmailSent({super.key, required this.email});

  @override
  State<EmailSent> createState() => _EmailSentState();
}

class _EmailSentState extends State<EmailSent> {
  @override
  Widget build(BuildContext context) {

    final loc = AppLocalizations.of(context)!;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (context) => const ForgotPassword()), 
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
                        loc.email_sent,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text.rich(
                      TextSpan(
                        text: loc.email_sent_text1,
                        style : const TextStyle(fontSize: 15),
                        children: [
                          TextSpan(
                            text: " ${widget.email} ",
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          TextSpan(
                            text: loc.email_sent_text2
                          )
                        ]
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage()
                                ),
                                (route) => false
                              );
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                            child: Text(
                              loc.back_to_login, 
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onPrimary
                              )
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${loc.email_not_correct}? "
                        ),
                        PressableText(
                          text: loc.click_to_edit, 
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
                            fontWeight: FontWeight.bold
                          )
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