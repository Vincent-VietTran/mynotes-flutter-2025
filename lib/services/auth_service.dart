import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';

class AuthService implements AuthProvider{
  // AuthService is used to manage user authentication by delegating tasks to an AuthProvider implementations, such as FirebaseAuthProvider.

  // Attributes
  final AuthProvider _authProvider;

  // Constructor that takes an AuthProvider instance
  AuthService(this._authProvider);

  @override
  Future<AuthUser> createUser({required String email, required String password}) {
    return _authProvider.createUser(email: email, password: password);
  }

  @override
  AuthUser? get currentUser {
    return _authProvider.currentUser;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    return _authProvider.logIn(email: email, password: password);
  }

  @override
  Future<void> logOut() {
    return _authProvider.logOut();
  }
  
  @override
  Future<void> sendEmailVerification() {
    return _authProvider.sendEmailVerification();
  }
}