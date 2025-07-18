import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

/*
  This test file used to test functionality of any AuthProvider implementation
  Simulating success API calls and responses
*/

void main() {
  group('Mock Authentication Tests', () {
    final provider = AuthMockProvider();

    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', () {
      // Perform log out and expect it to throw NotInitializedException
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be able to intialize', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () async {
      await provider.initialize();
      expect(provider.currentUser, null);
    });

    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Create user should delegate to log in function', () async {
      // Test bad email
      final badEmailUser = provider.createUser(
        email: "foo@bar.com",
        password: "foobar",
      );
      expect(badEmailUser, throwsA(TypeMatcher<UserNotFoundAuthException>()));

      // Test bad password
      final badPasswordUser = provider.createUser(
        email: "a@b.com",
        password: "wrongpassword",
      );
      expect(
        badPasswordUser,
        throwsA(TypeMatcher<WrongPasswordAuthException>()),
      );

      // Test register delegating task to log in, ensuring newly logged in user is new registered user
      final user = await provider.createUser(
        email: 'email',
        password: 'password',
      );
      expect(provider.currentUser, user);

      // Test to make sure email is not verified when first log in after registration
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      // Make sure after getting verified, logged in user is not null
      expect(user, isNotNull);
      // "!": null assertion operator, certain that the variable is not null
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and log in again', () async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');
      // Check successful log in, e.g. current user not null
      expect(provider.currentUser, isNotNull);
    });
  });
}

// Exceptions
class NotInitializedException implements Exception {}

// Mock AuthProvider, used to test functionality of any AuthProvider implementation
class AuthMockProvider implements AuthProvider {
  // private attributes
  AuthUser? _user;
  bool _isInitialized = false;

  // Getters
  bool get isInitialized {
    return _isInitialized;
  }

  // Methods
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    // Check if the provider is initialized
    if (!isInitialized) {
      throw NotInitializedException();
    }
    // Simulate a delay to mimic network API call
    await Future.delayed(const Duration(seconds: 1));
    // If log in is successful, that means user is created correctly
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    // Simulate auth provider initialization
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    // Check if the provider is initialized
    if (!isInitialized) {
      throw NotInitializedException();
    }
    // Check for user not found exception
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    // Check for wrong password exception
    if (password == 'wrongpassword') throw WrongPasswordAuthException();

    // create mock user
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    // Check if the provider is initialized
    if (!isInitialized) {
      throw NotInitializedException();
    }

    // If current user is null, throw exeption
    if (_user == null) {
      throw UserNotFoundAuthException();
    }
    // Simulating logout API calls
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    // Check if the provider is initialized
    if (!isInitialized) {
      throw NotInitializedException();
    }
    // If current user is null, throw exeption
    final user = _user;
    if (user == null) {
      throw UserNotFoundAuthException();
    }
    // Simulating email verification API calls
    await Future.delayed(const Duration(seconds: 1));
    _user = AuthUser(isEmailVerified: true);
  }
}
