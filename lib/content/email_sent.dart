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
              MaterialPageRoute(builder: (context) => ForgotPassword()), 
              (route) => false
            );
          }, 
          icon: Icon(Icons.arrow_back_rounded)
        ),

      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              spacing: 5,
              children: [
                SizedBox(height: 80),
                Text(
                  loc.email_sent,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30
                  ),
                ),
                SizedBox(height: 30),
                Text.rich(
                  TextSpan(
                    text: loc.email_sent_text1,
                    style : TextStyle(fontSize: 15),
                    children: [
                      TextSpan(
                        text: widget.email,
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

                SizedBox(height: 30),

                Column(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage()
                          ),
                          (route) => false
                        );
                      },
                    
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
                        child: Text(
                          loc.back_to_login, 
                          style: TextStyle(
                            fontSize: 15,
                            color: colorScheme.onPrimary
                          )
                        ),
                      )
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loc.email_not_correct + "? "
                    ),
                    PressableText(
                      text: loc.click_to_edit, 
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => ForgotPassword()
                          )
                        );
                      }, 
                      style: TextStyle(
                        color: colorScheme.primary
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}