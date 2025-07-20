import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

void main() async {
  // Enabling widgets binding before Firebase initializeApp
  // so that dont need to initialize firebase on every button/widget that uses firebase functionality (register, login)
  // Only one central firebase initialization is needed for all buttons
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),

      // Specify routes
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        notesRoute: (context) => const NotesView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // The FutureBuilder widget is used to handle asynchronous operations.
      // Define a future to be compared with the snapshot.
      future: AuthService.firebase().initialize(),
      // The future builder will wait for the Firebase initialization to complete and render the UI accordingly.
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          // If the firebase connection is complete, render the registration form.
          case ConnectionState.done:
            final currentUser = AuthService.firebase().currentUser;
            log('Current user: $currentUser.toString()');
            final emailVerified = currentUser?.isEmailVerified ?? false;
            // If able to review the current user, check if the email is verified.
            if (currentUser != null) {
              if (emailVerified) {
                // If the user is already logged in, navigate to the register view.
                log("You're account have been verified successfully!");
                return NotesView();
              } else {
                // If user already registered, but email is not verified yet, navigate them to email verification page.
                log("Please verify your email first.");
                return const VerifyEmailView();
              }
            } else {
              // If the user not registered yet, navigate them to the login view.
              log("User is not logged in.");
              return const LoginView();
            }

          // If the firebase connection is waiting, show a loading indicator.
          default:
            log("Loading...");
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
