import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart' 
show FirebaseAuth, FirebaseAuthException;



class FirebaseAuthProvider implements AuthProvider{
  // FirebaseAuthProvider implements the AuthProvider interface, providing methods for user authentication using Firebase.
  @override
  Future<AuthUser> createUser({required String email, required String password}) async{
    try{
      // Attempt to create a new user with the provided email and password
      await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

      final user = currentUser;
      // Done registeration, check if user logged in or not
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }

    } on FirebaseAuthException catch (e) {
        // Handle specific FirebaseAuthException errors
        if (e.code == 'weak-password' || e.code == 'missing-password') {
          throw WeakPasswordAuthException();

        } else if (e.code == 'email-already-in-use') {
          throw EmailAlreadyInUseAuthException();

        } else if (e.code == 'invalid-email') {
          throw InvalidEmailAuthException();

        } else {
          // Handle any other FirebaseAuthException errors
          throw GenericAuthException();
        }
    } catch (e) {
      // Handle any other exceptions that might occur
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    // Get the current user from FirebaseAuth if there is one, return null otherwise
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) async{
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          );
      
      // If the user is successfully logged in, return the current user
      final user = currentUser;
      if (user != null) {
        // If the user is not null, return the user
        return user;
      } else {
        // If the user is null, throw an exception
        throw UserNotLoggedInAuthException();
      }

    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthException errors
      if (e.code == 'invalid-credential' || e.code == 'invalid-email' 
        || e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw InvalidCredentialAuthException();

      } else if (e.code == 'missing-password') {
        throw WeakPasswordAuthException();

      } else {
        // Handle any other FirebaseAuthException errors
        throw GenericAuthException();
      }
    } catch (e) {
      // Handle any other exceptions that might occur
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If the user is not null, sign out
      await FirebaseAuth.instance.signOut();
    } else {
      // If the user is null, throw an exception
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    // If the user is successfully registered, and first time logged in, send a verification email.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If the user is not null, send a verification email
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
  
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              );
  }

}

