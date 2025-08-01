import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

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

                  // If the user is not null, send a verification email
                  await AuthService.firebase().sendEmailVerification();

                  // Show a snackbar to inform the user that the verification email has been sent
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification email sent!')),
                  );
                },
                child: const Text("Resend Verification Email"),
              ),

              TextButton(
                onPressed: () async {
                  await AuthService.firebase().currentUser?.reload();
                  final user = AuthService.firebase().currentUser;
                  if (user != null && user.isEmailVerified) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email not verified yet!')),
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
