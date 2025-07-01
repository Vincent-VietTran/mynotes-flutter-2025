import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/utilities/display_system_message.dart';

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
                String message;

                if (user != null) {
                  if (user.emailVerified) {
                    message = 'Sucessfully logged in.';
                    showDeligtfulToast(message, context);
                    // If the user is successfully logged in, navigate to the notes view.
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute, 
                      (route) => false
                    );
                  } else {
                    // If email not verified, navigate to the verify email view.
                    message = 'Logged in failed. Please verify your email.';
                    showDeligtfulToast(message, context);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyEmailRoute, 
                      (route) => false
                    );
                  }
                } 
              } on FirebaseAuthException catch (e) {
                String errorMessage;
                // Catch any errors that occur during the sign-in process.
                if(e.code == 'invalid-credential' || e.code == 'invalid-email' 
                    || e.code == 'user-not-found' || e.code == 'wrong-password') {
                  errorMessage = 'Invalid email or password.';
                  showDeligtfulToast(errorMessage, context);
                } 
                else if (e.code == 'missing-password') {
                  errorMessage = 'Password should be at least 6 characters long.';
                  showDeligtfulToast(errorMessage, context);
                } 
                else {
                  log("Error: ${e.code}");
                }
              } catch (e) {
                // Handle any other exceptions that may occur
                String errorMessage = 'An unexpected error occurred. Please try again later.';
                log('$errorMessage: $e');
                showDeligtfulToast(errorMessage, context);
              }
            },
            child: const Text("Login"),
          ),

          TextButton(
            onPressed: () {
              // Navigate to the registration view when the user clicks on the register button.
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute, 
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