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
  InvalidEmailAuthException([this.message = 'The email address entered is not valid.']);

  @override
  String toString() => 'InvalidEmailException: $message';
}

class InvalidCredentialAuthException implements Exception {
  final String message;

  // Constructor with an optional message parameter
  InvalidCredentialAuthException([this.message = 'Invalid email or password.']);

  @override
  String toString() => 'InvalidCredentialException: $message';
}

// Registration exception
class EmailAlreadyInUseAuthException implements Exception {
  final String message;

  // Constructor with an optional message parameter
  EmailAlreadyInUseAuthException([this.message = 'The account already exists.']);

  @override
  String toString() => 'EmailAlreadyInUseException: $message';
}

class WeakPasswordAuthException implements Exception {
  final String message;

  // Constructor with an optional message parameter
  WeakPasswordAuthException([this.message = 'Password should be at least 6 characters long.']);

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