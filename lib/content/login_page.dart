import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

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
                        "Login to your account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                        )
                      ),
              
                      SizedBox(height: 8),
              
                      Text("Email"),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
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
              
                      Text("Password"),
                      TextField(
                        obscureText: obscurePassword,
                        controller: passwordController,
                        decoration: InputDecoration(
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

                      SizedBox(height: 20),
                        
                      Center(
                        child: Column(
                          children: [
                            FilledButton(
                            onPressed:() {
                              setState(() {
                                passwordError = passwordController.text != passwordRepeatController.text;
                              });
                            },

                          child: Text(
                            "Signup", 
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
                                  "Don't have an account? "
                                ),
                                TextButton(
                                  onPressed: () {
                                    
                                  },
                                  child: Text(
                                    "Signup",
                                    style: TextStyle(
                                      color: colorScheme.primary
                                    )
                                  )
                                )
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
}