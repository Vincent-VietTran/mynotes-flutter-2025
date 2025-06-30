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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  // Get the current user
                  final user = FirebaseAuth.instance.currentUser;
                    
                  // If the user is not null, send a verification email
                  await user?.sendEmailVerification();

                  // Show a snackbar to inform the user that the verification email has been sent
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification email sent!'))
                  );
                },
                child: const Text("Send Verification Email"),
              ),

              TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.currentUser?.reload();
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && user.emailVerified) {
                Navigator.of(context).pushNamedAndRemoveUntil('/notes/', (route)=> false);
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
        ],
      ),
    );
  }
}