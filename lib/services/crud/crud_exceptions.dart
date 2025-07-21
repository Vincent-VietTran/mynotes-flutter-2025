// Database related Exeptions
class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

class DatabaseIsNotOpenExeption implements Exception {}

// User table specific exceptions
class UserAlreadyExist implements Exception {}

class UserNotExist implements Exception {}

class FailToDeleteUser implements Exception {}

// Note table specific exceptions
class NoteAlreadyExist implements Exception {}

class NoteNotExist implements Exception {}

class FailToUpdateNote implements Exception {}

class FailToDeleteNote implements Exception {}
