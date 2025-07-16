import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider{
  // AuthService is used to manage user authentication by delegating tasks to an AuthProvider implementations, such as FirebaseAuthProvider, maybe more in the future like googleAuth, facebookAuth.

  // Attributes
  final AuthProvider _authProvider;

  // Constructor that takes an AuthProvider instance
  AuthService(this._authProvider);

  // Firebase factory
  factory AuthService.firebase() {
    return AuthService(FirebaseAuthProvider());
  }

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
  
  @override
  Future<void> initialize() async {
    _authProvider.initialize();
  }
}