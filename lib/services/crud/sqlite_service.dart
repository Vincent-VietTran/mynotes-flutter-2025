import 'package:flutter/widgets.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;

// Sqlite is the local database storage, used for local dev environment only
// see https://docs.flutter.dev/cookbook/persistence/sqlite for more details how to integrate Sqlite with Flutter app

class SqliteService {
  // private attributes
  Database? _db;

  // CRUD for note
  Future<Note> createNote({required User owner}) async {
    final db = _getDatabaseOrThrow();
    // Make sure owner exists in the database with correct id
    final user = await getUser(id: owner.id);

    if (user != owner) {
      throw UserNotExist();
    }

    const text = "";
    // create note
    final noteId = await db.insert(noteTable, {
      "user_id": owner.id,
      "text": text,
      "is_synced_with_cloud": 1,
    });

    final note = Note(id: noteId, userId: owner.id, text: text);
    return note;
  }

  Future<List<Note>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    // Query to get all notes
    final List<Map<String, Object?>> noteMaps = await db.query(noteTable);

    // Convert the list notes properties into a list of Note object
    return [for (var map in noteMaps) Note.fromMap(map)];
  }

  Future<Note> getNote({required id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id=?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw NoteNotExist();
    }
    return Note.fromMap(notes.first);
  }

  Future<Note> updateNote({required Note note, required String text}) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    final updateCount = await db.update(
      noteTable,
      {textColumn: text, isSyncedWithCloudColumn: 0},
      where: 'id=?',
      whereArgs: [note.id],
    );

    if (updateCount == 0) {
      throw FailToUpdateNote();
    } else {
      return getNote(id: note.id);
    }
  }

  Future<void> deleteNote({required id}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      noteTable,
      where: 'id=?',
      whereArgs: [id],
    );
    if (deleteCount != 1) {
      throw FailToDeleteNote();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  // CRUD for User
  Future<User> createUser({required User user}) async {
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

    final userId = await db.insert(
      userTable,
      user.toMap(),
      // Replace if duplicate user record created
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return User(id: userId, email: user.email);
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
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
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
