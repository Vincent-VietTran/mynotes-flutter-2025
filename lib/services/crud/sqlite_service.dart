import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;

// Sqlite is the local database storage, used for local dev environment only
// see https://docs.flutter.dev/cookbook/persistence/sqlite for more details how to integrate Sqlite with Flutter app

// Database related Exeptions
class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

class DatabaseIsNotOpenExeption implements Exception {}

class FailToDeleteUser implements Exception {}

class UserAlreadyExist implements Exception {}

class UserNotExist implements Exception {}

class SqliteService {
  // private attributes
  Database? _db;

  // TODO: write CRUD for Note

  Future<void> createUser({required User user}) async {
    final db = _getDatabaseOrThrow();

    // Check if user already exist
    final duplicateUsers = await db.query(
      userTable,
      limit: 1,
      where: 'id=?',
      whereArgs: [user.id],
    );
    if (duplicateUsers.isNotEmpty) {
      throw UserAlreadyExist();
    }

    await db.insert(
      userTable,
      user.toMap(),
      // Replace if duplicate user record created
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<User>> getUsers() async {
    final db = _getDatabaseOrThrow();
    // Query to get all users
    final List<Map<String, Object?>> userMaps = await db.query(userTable);
    // Convert the list users properties into a list of User object
    return [
      for (final {'id': id as int, 'email': email as String} in userMaps)
        User(id: id, email: email),
    ];
  }

  Future<User> getUser({required id}) async {
    final db = _getDatabaseOrThrow();
    final query = await db.query(
      userTable,
      limit: 1,
      where: 'id=?',
      whereArgs: [id],
    );
    if (query.isEmpty) {
      throw UserNotExist();
    }
    return User.fromMap(query.first);
  }

  Future<void> updateUser({required User user}) async {
    final db = _getDatabaseOrThrow();
    final getUserQuery = await db.query(
      userTable,
      limit: 1,
      where: 'id=?',
      whereArgs: [user.id],
    );
    if (getUserQuery.isEmpty) {
      throw UserNotExist();
    }
    await db.update(
      userTable,
      user.toMap(),
      where: 'id=?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser({required id}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(dbName, where: 'id=?', whereArgs: [id]);
    if (deleteCount != 1) {
      throw FailToDeleteUser();
    }
  }

  // Retrieve database
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenExeption();
    }
    return db;
  }

  // Close database function
  Future<void> close() async {
    final db = _db;
    // It is expected that database is already opended here, if it is not, throw exception
    if (db == null) {
      throw DatabaseIsNotOpenExeption();
    }
    db.close();
  }

  // Open database function
  Future<void> open() async {
    // It is expected that database is not retrieved yet here, if it is throw exeption
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      // Database will be generated on device (of any platform, e.g. IOS, Android, etc.),
      // - docs path, path to the folder where the database is stored in device
      // - dbPath, path to the database
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);

      // assign private attribute _db to the retrieved db
      _db = db;

      // Execute Sqlite query
      // Create user table
      await db.execute(createUserTableQuery);

      // Create note table
      await db.execute(createNoteTableQuery);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

// Define User data model
// marked as immutable class: its states/properties cannot be changed/modified after creation
@immutable
class User {
  final int id;
  final String email;

  // Constructor
  const User({required this.id, required this.email});

  // Need to convert data model into a Map to perform insert operation
  Map<String, Object?> toMap() {
    return {'id': id, 'email': email};
  }

  // Map conversion to user object
  User.fromMap(Map<String, Object?> map)
    : id = map['id'] as int,
      email = map['email'] as String;

  // Implement toString to make it easier to see information about
  // each user when using the print statement.
  @override
  String toString() {
    return "User (id: $id, email: $email)";
  }

  @override
  // User object comparison (used covariant to specify type of param used for a method/function)
  // used to override object comparsion with User comparison rules)
  bool operator ==(covariant User other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

@immutable
// Define Note data model
class Note {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  // Constructor
  const Note({
    required this.id,
    required this.userId,
    required this.text,
    this.isSyncedWithCloud = false,
  });

  // Note to Map conversion, used to insert each note to database
  Map<String, Object?> toMap() {
    // Note that is_synced_with_cloud is defined as bool in flutter but as interger (with value 0 or 1) in database
    return {
      'id': id,
      'user_id': userId,
      'text': text,
      'is_synced_with_cloud': isSyncedWithCloud == false ? 0 : 1,
    };
  }

  // Map conversion to Note object
  Note.fromMap(Map<String, Object?> map)
    : id = map['id'] as int,
      userId = map['user_id'] as int,
      text = map['text'] as String,
      isSyncedWithCloud = map['is_synced_with_cloud'] == 1 ? true : false;

  // Implement toString to make it easier to see information about
  // each user when using the print statement.
  @override
  String toString() {
    return "Note (id: $id, user_id: $userId, text: $text, is_synced_with_cloud: $isSyncedWithCloud)";
  }

  @override
  // Note object comparison
  bool operator ==(covariant Note other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

// constants
const dbName = "notes_flutter_app.db";
const noteTable = "notes";
const userTable = "users";
const createUserTableQuery = ''' CREATE TABLE IF NOT EXISTS "users" (
          "id"	INTEGER NOT NULL,
          "email"	TEXT NOT NULL UNIQUE,
          PRIMARY KEY("id","email")
        );
        ''';
const createNoteTableQuery = ''' CREATE TABLE "notes" (
"id"	INTEGER NOT NULL,
"user_id"	INTEGER NOT NULL,
"text"	TEXT NOT NULL,
"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
PRIMARY KEY("id" AUTOINCREMENT),
CONSTRAINT "notes_users_fk" FOREIGN KEY("user_id") REFERENCES "users"("id")
);''';
