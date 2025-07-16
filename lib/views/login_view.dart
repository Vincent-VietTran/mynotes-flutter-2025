import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth_service.dart';
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
              await AuthService.firebase().initialize();
              // Sign in the user with the provided email and password.
              try{
                await AuthService.firebase().logIn(
                  email: email, 
                  password: password
                );

                final user = AuthService.firebase().currentUser;
                String message;
                if (user?.isEmailVerified ?? false) {
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
              } on UserNotFoundAuthException catch (_) {
                showDeligtfulToast("Invalid user name or password.", context);
              } on InvalidCredentialAuthException catch (_) {
                showDeligtfulToast("Invalid user name or password.", context);
              } on WeakPasswordAuthException catch (_) {
                showDeligtfulToast("Invalid user name or password.", context);
              } on WrongPasswordAuthException catch (_) {
                showDeligtfulToast("Invalid user name or password.", context);
              } on GenericAuthException {
                showDeligtfulToast("An unexpected error occurred during authentication. Please try again later.", context);
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