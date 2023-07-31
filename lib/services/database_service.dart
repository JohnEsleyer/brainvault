import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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
            description TEXT
          );
          ''');

    await db.execute('''
          CREATE TABLE documents (
            id INTEGER PRIMARY KEY,
            collection_id INTEGER,
            title TEXT,
            position INTEGER,
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
            type TEXT,
            FOREIGN KEY (document_id) REFERENCES documents (document_id) 
              ON DELETE CASCADE ON UPDATE NO ACTION
          );
          ''');
  }

   Future<Uint8List> getDatabaseDataAsJson() async {
    final db = await database;

    // Query the necessary tables and retrieve the data
    List<Map<String, dynamic>> collectionsData = await db.query('collections');
    List<Map<String, dynamic>> documentsData = await db.query('documents');
    List<Map<String, dynamic>> notesData = await db.query('notes');

    // Organize the data as needed in a Map
    Map<String, dynamic> jsonData = {
      'collections': collectionsData,
      'documents': documentsData,
      'notes': notesData,
    };

    // Convert the data to JSON-formatted string
    String jsonString = jsonEncode(jsonData);

    // Convert the JSON string to Uint8List to use in Blob
    Uint8List jsonUint8List = Uint8List.fromList(utf8.encode(jsonString));
    return jsonUint8List;
  }

  void generateAndDownloadJsonFile() async {
    DatabaseService databaseService = DatabaseService();
    Uint8List jsonData = await databaseService.getDatabaseDataAsJson();

    // Create a Blob with the JSON data
    final blob = html.Blob([jsonData], 'application/json');

    // Create a URL for the Blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create an anchor element (a) to initiate the download
    html.AnchorElement(href: url)
      ..setAttribute("download", "database_data.brain") // Set the file name
      ..click(); // Simulate a click event to trigger the download

    // Release the URL resource
    html.Url.revokeObjectUrl(url);
  }

   // Method for uploading and inserting JSON data into the database
  Future<void> uploadAndInsertJsonData() async {
    // Create an input element of type "file" to handle file upload
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.brain'; // Set the accepted file type (JSON in this case)
    uploadInput.click(); // Simulate a click on the input element

    // Wait for the user to select a file and read it
    await uploadInput.onChange.first;

    // Get the selected file from the input element
    final html.File uploadedFile = uploadInput.files!.first;

    // Read the selected JSON file as text
    final reader = html.FileReader();
    reader.readAsText(uploadedFile);

    // Wait for the reader to finish loading the file
    await reader.onLoad.first;

    // Get the JSON data as a String
    String jsonDataString = reader.result as String;

    // Parse the JSON data
    Map<String, dynamic> jsonData = json.decode(jsonDataString);

    // Insert collections
    if (jsonData.containsKey('collections') && jsonData['collections'] is List) {
      List<dynamic> collectionsData = jsonData['collections'];
      for (var collectionData in collectionsData) {
        await insertCollection(collectionData as Map<String, dynamic>);
      }
    }

    // Insert documents
    if (jsonData.containsKey('documents') && jsonData['documents'] is List) {
      List<dynamic> documentsData = jsonData['documents'];
      for (var documentData in documentsData) {
        await insertDocument(documentData as Map<String, dynamic>);
      }
    }

    // Insert notes
    if (jsonData.containsKey('notes') && jsonData['notes'] is List) {
      List<dynamic> notesData = jsonData['notes'];
      for (var noteData in notesData) {
        await insertNote(noteData as Map<String, dynamic>);
      }
    }
  }


  Future<void> clearDatabase() async {
    final db = await database;

    // Delete all rows from each table
    await db.delete('collections');
    await db.delete('documents');
    await db.delete('notes');
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

  Future<int> updateCollectionTitle(int collectionId, String newTitle) async {
    final db = await database;
    final Map<String, dynamic> collection = {
      'title': newTitle,
    };
    return await db.update('collections', collection,
        where: 'id = ?', whereArgs: [collectionId]);
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
    return await db.delete('notes', where: 'id = ?', whereArgs: [noteId]);
  }

  Future<int> updateNoteType(int noteId, String newType) async {
    final db = await database;
    final Map<String, dynamic> updatedNote = {
      'type': newType,
    };
    return await db.update('notes', updatedNote, where: 'id = ?', whereArgs: [noteId]);
  }




}
