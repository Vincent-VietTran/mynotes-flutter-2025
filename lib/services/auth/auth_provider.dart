import 'package:mynotes/services/auth/auth_user.dart';

// AuthProvider is an abstract class that defines the contract for authentication providers. such as Firebase or any other service (gooogle, facebook, etc).
abstract class AuthProvider {
  // Getters
  AuthUser? get currentUser;

  // Methods
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();
  Future<void> sendEmailVerification();
}