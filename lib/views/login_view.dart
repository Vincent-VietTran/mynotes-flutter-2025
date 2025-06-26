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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),

      body: FutureBuilder(
        // The FutureBuilder widget is used to handle asynchronous operations.
        // Define a future to be compared with the snapshot.
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),

        // The future builder will wait for the Firebase initialization to complete and render the UI accordingly.
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            // If the firebase connection is complete, render the registration form.
            case ConnectionState.done:
              return Column(
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
                        print(userCredential);
                      } on FirebaseAuthException catch (e) {
                        // Catch any errors that occur during the sign-in process.
                        if(e.code == 'invalid-credential') {
                          print("Invalid credential");
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
                          print("Error: ${e.code}");
                        }
                      }
                    },
                    child: const Text("Login"),
                  ),
                ],
              );

            // If the firebase connection is waiting, show a loading indicator.
            default:
              return const Text("Loading...");
          }
        },
      ),
    );
  }
}