import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const Text("Please verify your email address before proceeding."),
          TextButton(
            onPressed: () async {
              // Get the current user
              final user = FirebaseAuth.instance.currentUser;
      
              // If the user is not null, send a verification email
              await user?.sendEmailVerification();
            },
            child: const Text("Send Verification Email"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.currentUser?.reload();
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && user.emailVerified) {
                Navigator.of(context).pushReplacementNamed('/notes/');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email not verified yet!'))
                );
              }
            },
            child: const Text("I have verified my email"),
          ),
        ],
      ),
    );
  }
}