import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Note {
  final int id;
  final String description;

  Note({required this.id, required this.description});

  Note.fromMap(Map<String, dynamic> item)
      : id = item["id"],
        description = item["description"];

  Map<String, Object> toMap() {
    return {'id': id, 'description': description};
  }
}

class SqliteService {
  Future<Database> initializeDB() async {
    // gets the default database location
    String path = await getDatabasesPath();

    // onCreate() callback: Will be called when the database is created for the first time, and it will execute the above SQL query to create the table notes.
    return openDatabase(
      join(path, 'database.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE Notes(id INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT NOT NULL)",
        );
      },
      version: 1,
    );
  }

  Future<int> createItem(Note note) async {
    int result;
    final Database db = await initializeDB();
    result = await db.insert('Notes', note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  Future<List<Note>> getItems() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('Notes');
    // await db.query('Notes', orderBy: NoteColumn.createdAt);
    return queryResult.map((e) => Note.fromMap(e)).toList();
  }

  // Delete an note by id
  Future<void> deleteItem(String id) async {
    final Database db = await initializeDB();
    try {
      await db.delete("Notes", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      // ignore: avoid_print
      print("Something went wrong when deleting an item: $err");
    }
  }
}
