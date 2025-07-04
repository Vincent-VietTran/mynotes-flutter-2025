// Login exeption
class UserNotFoundAuthException implements Exception {
  final String message;

  // Constructor with an optional message parameter
  UserNotFoundAuthException([this.message = 'User not found']);

  @override
  String toString() => 'UserNotFoundException: $message';
}

class WrongPasswordAuthException implements Exception {
  final String message;

  // Constructor with an optional message parameter
  WrongPasswordAuthException([this.message = 'Wrong password']);

  @override
  String toString() => 'WrongPasswordException: $message';
}

class InvalidEmailAuthException implements Exception {
  final String message;

  // Constructor with an optional message parameter
  InvalidEmailAuthException([this.message = 'Invalid email']);

  @override
  String toString() => 'InvalidEmailException: $message';
}

class InvalidCredentialAuthException implements Exception {
  final String message;

  // Constructor with an optional message parameter
  InvalidCredentialAuthException([this.message = 'Invalid credential']);

  @override
  String toString() => 'InvalidCredentialException: $message';
}

class MissingPasswordAuthException implements Exception {
  final String message;

  // Constructor with an optional message parameter
  MissingPasswordAuthException([this.message = 'Missing password']);

  @override
  String toString() => 'MissingPasswordException: $message';
}

// Registration exception
class EmailAlreadyInUseAuthException implements Exception {
  final String message;

  // Constructor with an optional message parameter
  EmailAlreadyInUseAuthException([this.message = 'Email already in use']);

  @override
  String toString() => 'EmailAlreadyInUseException: $message';
}

class WeakPasswordAuthException implements Exception {
  final String message;

  // Constructor with an optional message parameter
  WeakPasswordAuthException([this.message = 'Weak password']);

  @override
  String toString() => 'WeakPasswordException: $message';
}

// Generic exeption
class GenericAuthException implements Exception {
  final String message;

  // Constructor with an optional message parameter
  GenericAuthException([this.message = 'An unexpected error occurred during authentication']);

  @override
  String toString() => 'GenericAuthException: $message';
}

class UserNotLoggedInAuthException implements Exception {
  final String message;

  // Constructor with an optional message parameter
  UserNotLoggedInAuthException([this.message = 'User not logged in']);

  @override
  String toString() => 'UserNotLoggedInException: $message';
}