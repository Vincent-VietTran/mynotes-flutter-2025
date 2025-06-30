import 'dart:developer';

import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import  'package:delightful_toast/delight_toast.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  // The initState method is called when the widget is inserted into the widget tree.
  // It's a good place to initialize controllers or other resources.
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  // The dispose method is called when the widget is removed from the widget tree.
  // It's a good place to clean up resources like controllers.
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Previously return entire scaffold (entire new screen) with app bar and body.
    // Now we just return a column with text fields and a button (content) since home page already provide scaffold layout of common componets.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Login'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
            ),
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
          ),
      
          TextField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: "Password",
              hintText: "Enter your password",
            ),
            obscureText: true,
            enableSuggestions: false,
          ),
      
          TextButton(
            // Register is an asynchronous operation, so we use async
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              );
              // Sign in the user with the provided email and password.
              try{
                final userCredential = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                log('User credential: $userCredential.toString()');

                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  if (user.emailVerified) {
                    // If the user is successfully logged in, navigate to the notes view.
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/notes/', 
                      (route) => false
                    );
                  } else {
                    // If email not verified, navigate to the verify email view.
                    log("User email not verified.");
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/verify-email/', 
                      (route) => false
                    );
                  }
                } 
              } on FirebaseAuthException catch (e) {
                // Catch any errors that occur during the sign-in process.
                if(e.code == 'invalid-credential') {
                  log("Invalid credential");
                  DelightToastBar(
                    builder: (context) => const ToastCard(
                      leading: Icon(
                        Icons.flutter_dash,
                        size: 28,
                      ),
                      title: Text(
                        "Invalid email or password.",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ).show(context);
                } else {
                  log("Error: ${e.code}");
                }
              }
            },
            child: const Text("Login"),
          ),

          TextButton(
            onPressed: () {
              // Navigate to the registration view when the user clicks on the register button.
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/register/', 
                (route) => false
                );
            },
            child: const Text("Not registered yet? Register here!"),
          ),
        ],
      ),
    );
  }
}