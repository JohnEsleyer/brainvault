import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  String dbPath = 'brain.db';

  static final DatabaseService _instance = DatabaseService.internal();
  factory DatabaseService() => _instance;
  static Database? _db;
  Directory? directory;
  String fileName = 'brainFile.brain';

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
            table_name TEXT,
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
            table_name TEXT,
            FOREIGN KEY (document_id) REFERENCES documents (document_id) 
              ON DELETE CASCADE ON UPDATE NO ACTION
          );
          ''');
  }

  // Method to search documents and notes based on title and content.
  Future<List<Map<String, dynamic>>> searchDocumentsAndNotes(
      String query) async {
    final db = await database;

    // Regular expression pattern to remove HTML tags and extract plain text content.
    final RegExp htmlTagRegex =
        RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);

    // Helper function to extract plain text from content with HTML tags.
    String extractPlainText(String content) {
      return content.replaceAll(htmlTagRegex, '');
    }

    final List<Map<String, dynamic>> documents = await db.query(
      'documents',
      where: 'title LIKE ? OR table_name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    final List<Map<String, dynamic>> notes = await db.query(
      'notes',
      where: 'content LIKE ? OR table_name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    // Extract plain text from notes' content.
    List<Map<String, dynamic>> filteredNotes = [];
    for (var note in notes) {
      String content = note['content'];
      String plainText = extractPlainText(content);
      if (plainText.toLowerCase().contains(query.toLowerCase())) {
        // If the plain text contains the query, add it to the filtered notes list.
        filteredNotes.add(note);
      }
    }

    // Combine and return the results (documents and filtered notes).
    return [...documents, ...filteredNotes];
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

  void openDirectoryPicker() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        directory = Directory(result);
      }
    } catch (e) {
      print('Error picking directory: $e');
      return;
    }

    directory = directory;
    print('Selected directory path: ${directory?.path}');
  }

  Future<void> generateAndDownloadJsonFile() async {
    DatabaseService databaseService = DatabaseService();
    Uint8List jsonData = await databaseService.getDatabaseDataAsJson();

    // Get the directory based on the platform
    // Directory? directory;
    // if (Platform.isWindows || Platform.isLinux) {
    //   directory = await getDownloadsDirectory();
    // } else if (Platform.isAndroid) {
    //   directory = await getExternalStorageDirectory();
    // } else {
    //   // Unsupported platform, handle it accordingly
    //   return;
    // }

    if (directory == null) {
      // Directory is not available, handle it accordingly
      print("Directory not found");
      return;
    }

    // Create the file path with the desired file name
    String filePath = "${directory?.path}/$fileName";

    // Write the JSON data to a file
    File file = File(filePath);
    await file.writeAsBytes(jsonData);

    // Trigger the download
    MethodChannel platform = MethodChannel('flutter/platform');
    try {
      await platform.invokeMethod('sendIntent', {
        'action': 'android.intent.action.VIEW',
        'type': 'application/json',
        'data': Uri.file(filePath).toString(),
        'flag': 1,
      });
    } catch (e) {
      // If the intent invocation fails, prompt the user to open the file manually
      print('Failed to open the file: $e');
      // You can show a message or alert here for the user to manually open the file
    }
  }

// Method for importing and inserting JSON data into the database
  Future<void> uploadAndInsertJsonData() async {
    // Show a file picker dialog to let the user select a file
    FilePickerResult? result = await getFilePickerResult();

    if (result != null && result.files.isNotEmpty) {
      // Get the selected file
      PlatformFile file = result.files.first;

      // Obtain the file name
      fileName = file.name;

      // Get the directory path of the selected file
      directory = Directory(file.path ?? '').parent;

      // Read the selected JSON file as text
      String jsonDataString = await readJsonFileAsString(file);

      // Parse the JSON data
      Map<String, dynamic> jsonData = json.decode(jsonDataString);

      // Insert collections, documents, and notes
      await insertDataFromJson(jsonData);
    }
  }

// Function to get the file picker result
  Future<FilePickerResult?> getFilePickerResult() async {
    return FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'brain'
      ], // Set the accepted file type (JSON in this case)
    );
  }

// Function to read the selected JSON file as text
  Future<String> readJsonFileAsString(PlatformFile file) async {
    return await File(file.path!).readAsString();
  }

// Function to insert collections, documents, and notes from JSON data
  Future<void> insertDataFromJson(Map<String, dynamic> jsonData) async {
    if (jsonData.containsKey('collections') &&
        jsonData['collections'] is List) {
      List<dynamic> collectionsData = jsonData['collections'];
      for (var collectionData in collectionsData) {
        await insertCollection(collectionData as Map<String, dynamic>);
      }
    }

    if (jsonData.containsKey('documents') && jsonData['documents'] is List) {
      List<dynamic> documentsData = jsonData['documents'];
      for (var documentData in documentsData) {
        await insertDocument(documentData as Map<String, dynamic>);
      }
    }

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

  Future<int> updateCollectionDescription(int collectionId, String newDescription) async {
    final db = await database;
    final Map<String, dynamic> collection = {
      'description': newDescription,
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
        where: 'id = ?', whereArgs: [collectionId]);
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
        .delete('documents', where: 'id = ?', whereArgs: [documentId]);
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
    List<Map<String, dynamic>> notes =
        await db.query('notes', where: 'id = ?', whereArgs: [noteId]);
    if (notes.isNotEmpty) {
      return notes.first;
    } else {
      throw Exception('Note with ID $noteId not found');
    }
  }

  Future<List<Map<String, dynamic>>> getAllNotesByDocumentId(
      int documentId) async {
    final db = await database;
    return await db
        .query('notes', where: 'document_id = ?', whereArgs: [documentId]);
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
    return await db
        .update('notes', updatedNote, where: 'id = ?', whereArgs: [noteId]);
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
    return await db
        .update('notes', updatedNote, where: 'id = ?', whereArgs: [noteId]);
  }
}
