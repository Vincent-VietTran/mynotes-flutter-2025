import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

/// Represents an authenticated user in the application.
/// This class encapsulates the properties and behaviors of a user as we dont want to expose Firebase User directly to UI components.
// Immutable notation used to ensure that the properties of AuthUser and its subclasses cannot be changed after initialization.
@immutable
class AuthUser {
  final User user;
  final bool isEmailVerified;

  // Constructor
  const AuthUser({required this.isEmailVerified, required this.user});

  // Factory constructor to create an AuthUser from a Firebase User.
  factory AuthUser.fromFirebase(User user) {
    return AuthUser(isEmailVerified: user.emailVerified, user: user);
  }

  Future<void> reload() async {
    // Reload the user data from Firebase.
    await user.reload();
  }
}