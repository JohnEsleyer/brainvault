import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
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
    await db.execute('''
          CREATE TABLE collections (
            id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT,
            created_at INTEGER
          );
          ''');

    await db.execute('''
          CREATE TABLE documents (
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
          ''');

    await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY,
            document_id INTEGER,
            content TEXT,
            position INTEGER,
            created_at INTEGER,
            last_reviewed INTEGER,
            next_review INTEGER,
            spaced_repetition_level INTEGER,
            FOREIGN KEY (document_id) REFERENCES documents (document_id) 
              ON DELETE CASCADE ON UPDATE NO ACTION
          );
          ''');
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

  // CRUD Operations for 'documents' table
  Future<int> insertDocument(Map<String, dynamic> document) async {
    final db = await database;
    return await db.insert('documents', document);
  }

  Future<List<Map<String, dynamic>>> getAllDocuments() async {
    final db = await database;
    return await db.query('documents');
  }

  Future<List<Map<String, dynamic>>> getDocumentsByCollectionId(
      int collectionId) async {
    final db = await database;
    final List<Map<String, dynamic>> documents = await db.query(
      'documents',
      where: 'collection_id = ?',
      whereArgs: [collectionId],
    );
    return documents;
  }

  Future<Map<String, dynamic>> getDocumentById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> documents = await db.query(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (documents.isNotEmpty) {
      return documents.first;
    } else {
      throw Exception('Document with ID $id not found.');
    }
  }

  Future<int> updateDocument(Map<String, dynamic> document) async {
    final db = await database;
    return await db.update('documents', document,
        where: 'document_id = ?', whereArgs: [document['document_id']]);
  }

  Future<int> updateDocumentTitle(int documentId, String newTitle) async {
    final db = await database;
    final Map<String, dynamic> document = {
      'title': newTitle,
    };
    return await db.update('documents', document,
        where: 'id = ?', whereArgs: [documentId]);
  }


  Future<int> deleteDocument(int documentId) async {
    final db = await database;
    return await db
        .delete('documents', where: 'document_id = ?', whereArgs: [documentId]);
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

  Future<Map<String, dynamic>> getNoteById(int noteId) async {
    final db = await database;
    List<Map<String, dynamic>> notes = await db.query('notes', where: 'id = ?', whereArgs: [noteId]);
    if (notes.isNotEmpty) {
      return notes.first;
    } else {
      throw Exception('Note with ID $noteId not found');
    }
  }

  Future<List<Map<String, dynamic>>> getAllNotesByDocumentId(int documentId) async {
    final db = await database;
    return await db.query('notes', where: 'document_id = ?', whereArgs: [documentId]);
  }



  Future<int> updateNote(Map<String, dynamic> note) async {
    final db = await database;
    return await db.update('notes', note,
        where: 'note_id = ?', whereArgs: [note['note_id']]);
  }

  Future<int> updateNoteContent(int noteId, String newContent) async {
    final db = await database;
    final Map<String, dynamic> updatedNote = {
      'content': newContent,
    };
    return await db.update('notes', updatedNote, where: 'id = ?', whereArgs: [noteId]);
  }


  Future<int> deleteNote(int noteId) async {
    final db = await database;
    return await db.delete('notes', where: 'note_id = ?', whereArgs: [noteId]);
  }
}
