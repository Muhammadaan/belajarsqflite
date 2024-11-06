import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'todo.dart';

class DatabaseHelper {
  static const _databaseName = "todo.db";
  static const _databaseVersion = 1;
  static const table = 'todo_table';

  static const columnId = 'id';
  static const columnTask = 'task';
  static const columnIsDone = 'isDone';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // Create the database schema
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnTask TEXT NOT NULL,
            $columnIsDone INTEGER NOT NULL
          )
    ''');
  }

  // Insert a new todo
  Future<int> insert(Todo todo) async {
    Database db = await instance.database;
    return await db.insert(table, todo.toMap());
  }

  // Get all todos
  Future<List<Todo>> getTodos() async {
    Database db = await instance.database;
    var result = await db.query(table);
    List<Todo> todos =
        result.isNotEmpty ? result.map((c) => Todo.fromMap(c)).toList() : [];
    return todos;
  }

  // Update a todo
  Future<int> update(Todo todo) async {
    Database db = await instance.database;
    return await db.update(
      table,
      todo.toMap(),
      where: '$columnId = ?',
      whereArgs: [todo.id],
    );
  }

  // Delete a todo
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}
