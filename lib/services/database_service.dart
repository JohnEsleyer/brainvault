
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


class DatabaseService{
  String dbPath = 'brain.db';

  static final DatabaseService _instance = DatabaseService.internal();
  factory DatabaseService() => _instance;
  static Database? _db;

  DatabaseService.internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    return await openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    // Create your database table(s) here
    await db.execute(
        '''
          CREATE TABLE collections (
            id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT,
            created_at INTEGER
          );
          '''
        );

        await db.execute(
          '''
          CREATE TABLE chunks (
            id INTEGER PRIMARY KEY,
            collection_id INTEGER,
            title TEXT,
            position INTEGER,
            created_at INTEGER,
            last_reviewed INTEGER,
            next_review INTEGER,
            spaced_repetition_level INTEGER,
            FOREIGN KEY (collection_id) REFERENCES collections (collection_id) 
              ON DELETE CASCADE ON UPDATE NO ACTION
          );
          '''
        );

        await db.execute(
          '''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY,
            chunk_id INTEGER,
            content TEXT,
            position INTEGER,
            created_at INTEGER,
            last_reviewed INTEGER,
            next_review INTEGER,
            spaced_repetition_level INTEGER,
            FOREIGN KEY (chunk_id) REFERENCES chunks (chunk_id) 
              ON DELETE CASCADE ON UPDATE NO ACTION
          );
          '''
    );
  }

  // CRUD Operations for 'collections' table
  Future<int> insertCollection(Map<String, dynamic> collection) async {
    final db = await database;
    return await db.insert('collections', collection);
  }

  Future<List<Map<String, dynamic>>> getAllCollections() async {
    final db = await database;
    return await db.query('collections');
  }

  Future<Map<String, dynamic>> getCollectionById(int id) async {
  final db = await database;
  final List<Map<String, dynamic>> collections = await db.query(
    'collections',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (collections.isNotEmpty) {
    return collections.first;
  } else {
  
    throw Exception('Collection with ID $id not found.');
  }
}


  Future<int> updateCollection(Map<String, dynamic> collection) async {
    final db = await database;
    return await db.update('collections', collection,
        where: 'collection_id = ?', whereArgs: [collection['collection_id']]);
  }

  Future<int> deleteCollection(int collectionId) async {
    final db = await database;
    return await db.delete('collections',
        where: 'collection_id = ?', whereArgs: [collectionId]);
  }

  // Future<String> getCollectionTitleById(int id) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> collections = await db.query(
  //     'collections',
  //     columns: ['title'],
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );

  //   if (collections.isNotEmpty) {
  //     // Extract the title from the first record and return it.
  //     return collections.first['title'] as String;
  //   } else {
  //     throw Exception('Collection with ID $id not found.');
  //   }
  // }


  // CRUD Operations for 'chunks' table
  Future<int> insertChunk(Map<String, dynamic> chunk) async {
    final db = await database;
    return await db.insert('chunks', chunk);
  }

  Future<List<Map<String, dynamic>>> getAllChunks() async {
    final db = await database;
    return await db.query('chunks');
  }

  Future<List<Map<String, dynamic>>> getChunksByCollectionId(int collectionId) async {
    final db = await database;
    final List<Map<String, dynamic>> chunks = await db.query(
      'chunks',
      where: 'collection_id = ?',
      whereArgs: [collectionId],
    );
    return chunks;
  }

  Future<Map<String, dynamic>> getChunkById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> chunks = await db.query(
      'chunks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (chunks.isNotEmpty) {
      return chunks.first;
    } else {
      throw Exception('Chunk with ID $id not found.');
    }
  }



  Future<int> updateChunk(Map<String, dynamic> chunk) async {
    final db = await database;
    return await db.update('chunks', chunk,
        where: 'chunk_id = ?', whereArgs: [chunk['chunk_id']]);
  }

  Future<int> deleteChunk(int chunkId) async {
    final db = await database;
    return await db.delete('chunks', where: 'chunk_id = ?', whereArgs: [chunkId]);
  }

  // CRUD Operations for 'notes' table
  Future<int> insertNote(Map<String, dynamic> note) async {
    final db = await database;
    return await db.insert('notes', note);
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await database;
    return await db.query('notes');
  }

  Future<int> updateNote(Map<String, dynamic> note) async {
    final db = await database;
    return await db.update('notes', note,
        where: 'note_id = ?', whereArgs: [note['note_id']]);
  }

  Future<int> deleteNote(int noteId) async {
    final db = await database;
    return await db.delete('notes', where: 'note_id = ?', whereArgs: [noteId]);
  }
}
