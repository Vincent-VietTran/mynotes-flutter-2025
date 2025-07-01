
// The RegisterView widget is a placeholder for the registration view.
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/utilities/display_system_message.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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

  // The build method is called to render the widget.
  @override
  Widget build(BuildContext context) {
    // Previously return entire scaffold (entire new screen) with app bar and body.
    // Now we just return a column with text fields and a button (content) since home page already provide scaffold layout of common componets.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Register'),
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
      
              try{
                final userCredential = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                log('User credential: $userCredential.toString()');

                // If the user is successfully registered, navigate to the verify email view.
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // If the user is not null, send a verification email
                  await user.sendEmailVerification();
                  showDeligtfulToast("Your account has been successfully registered. Email verification sent!", context);
                  
                  // Navigate to the verify view.
                  Navigator.of(context).pushReplacementNamed(
                    verifyEmailRoute, 
                    );
                } else {
                  log("User is not registered.");
                }
              } on FirebaseAuthException catch (e) {
                String errorMessage = 'An error occurred during registration. Please try again later.';
                // Handle specific FirebaseAuthException errors
                if (e.code == 'weak-password' || e.code == 'missing-password') {
                  errorMessage = 'Password should be at least 6 characters long.';
                  showDeligtfulToast(errorMessage, context);
      
                } else if (e.code == 'email-already-in-use') {
                  errorMessage = 'The account already exists.';
                  showDeligtfulToast(errorMessage, context);
                } 
                else if (e.code == 'invalid-email') {
                  errorMessage = 'The email address entered is not valid.';
                  showDeligtfulToast(errorMessage, context);
                } 
                else {
                  log('Error: ${e.code}');
                }
              } catch (e) {
                // Handle any other exceptions that may occur
                String errorMessage = 'An unexpected error occurred. Please try again later.';
                log('$errorMessage: $e');
                showDeligtfulToast(errorMessage, context);
              }
            },
            child: const Text("Register"),
          ),

          TextButton(
            onPressed: () {
              // Navigate to the registration view when the user clicks on the register button.
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute, 
                (route) => false
                );
            },
            child: const Text("Already registered? Login here!"),
          ),
        ],
      ),
    );
  }
}