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
    return await openDatabase(inMemoryDatabasePath, onCreate: _onCreate, version: 1);
  }

  void _onCreate(Database db, int version) async {
    // Create your database table(s) here
    await db.execute('''
          CREATE TABLE subjects (
            id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT
          );
          ''');

    await db.execute('''
          CREATE TABLE topics (
            id INTEGER PRIMARY KEY,
            subject_id INTEGER,
            title TEXT,
            FOREIGN KEY (subject_id) REFERENCES subjects (subject_id) 
              ON DELETE CASCADE ON UPDATE NO ACTION
          );
          ''');

    await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY,
            topic_id INTEGER,
            content TEXT,
            FOREIGN KEY (topic_id) REFERENCES topics (topic_id) 
              ON DELETE CASCADE ON UPDATE NO ACTION
          );
          ''');
    
  }

  void closeDatabase() async {
    await _db!.close();
  }

  // Method to search topics and notes based on title and content.
  Future<List<Map<String, dynamic>>> searchTopicsAndNotes(
      String query) async {
    final db = await database;

    // Regular expression pattern to remove HTML tags and extract plain text content.
    final RegExp htmlTagRegex =
        RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);

    // Helper function to extract plain text from content with HTML tags.
    String extractPlainText(String content) {
      return content.replaceAll(htmlTagRegex, '');
    }

    final List<Map<String, dynamic>> topics = await db.query(
      'topics',
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

    // Combine and return the results (topics and filtered notes).
    return [...topics, ...filteredNotes];
  }

  Future<Uint8List> getDatabaseDataAsJson() async {
    final db = await database;

    // Query the necessary tables and retrieve the data
    List<Map<String, dynamic>> subjectsData = await db.query('subjects');
    List<Map<String, dynamic>> topicsData = await db.query('topics');
    List<Map<String, dynamic>> notesData = await db.query('notes');

    // Organize the data as needed in a Map
    Map<String, dynamic> jsonData = {
      'subjects': subjectsData,
      'topics': topicsData,
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

      // Insert subjects, topics, and notes
      await insertDataFromJson(jsonData);
    }
  }

// Function to get the file picker result
  Future<FilePickerResult?> getFilePickerResult() async {
    return FilePicker.platform.pickFiles(
      type: FileType.any,
      // allowedExtensions: [
      //   'brain'
      // ], // Set the accepted file type (JSON in this case)
    );
  }

// Function to read the selected JSON file as text
  Future<String> readJsonFileAsString(PlatformFile file) async {
    return await File(file.path!).readAsString();
  }

// Function to insert subjects, topics, and notes from JSON data
  Future<void> insertDataFromJson(Map<String, dynamic> jsonData) async {
    if (jsonData.containsKey('subjects') &&
        jsonData['subjects'] is List) {
      List<dynamic> subjectsData = jsonData['subjects'];
      for (var subjectData in subjectsData) {
        await insertSubject(subjectData as Map<String, dynamic>);
      }
    }

    if (jsonData.containsKey('topics') && jsonData['topics'] is List) {
      List<dynamic> topicsData = jsonData['topics'];
      for (var topicData in topicsData) {
        await insertTopic(topicData as Map<String, dynamic>);
      }
    }

    if (jsonData.containsKey('notes') && jsonData['notes'] is List) {
      List<dynamic> notesData = jsonData['notes'];
      for (var noteData in notesData) {
        await insertNote(noteData as Map<String, dynamic>);
      }
    }
  }



  // CRUD Operations for 'subjects' table
  Future<int> insertSubject(Map<String, dynamic> subject) async {
    final db = await database;
    return await db.insert('subjects', subject);
  }

  Future<List<Map<String, dynamic>>> getAllSubjects() async {
    final db = await database;
    return await db.query('subjects');
  }

  Future<Map<String, dynamic>> getSubjectById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> subjects = await db.query(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (subjects.isNotEmpty) {
      return subjects.first;
    } else {
      throw Exception('subject with ID $id not found.');
    }
  }

  Future<int> updateSubjectTitle(int subjectId, String newTitle) async {
    final db = await database;
    final Map<String, dynamic> subject = {
      'title': newTitle,
    };
    return await db.update('subjects', subject,
        where: 'id = ?', whereArgs: [subjectId]);
  }

  Future<int> updateSubjectDescription(int subjectId, String newDescription) async {
    final db = await database;
    final Map<String, dynamic> subject = {
      'description': newDescription,
    };
    return await db.update('subjects', subject,
        where: 'id = ?', whereArgs: [subjectId]);
  }

  Future<int> updateSubject(Map<String, dynamic> subject) async {
    final db = await database;
    return await db.update('subjects', subject,
        where: 'subject_id = ?', whereArgs: [subject['subject_id']]);
  }

  Future<int> deleteSubject(int subjectId) async {
    final db = await database;
    return await db.delete('subjects',
        where: 'id = ?', whereArgs: [subjectId]);
  }

  // CRUD Operations for 'topics' table
  Future<int> insertTopic(Map<String, dynamic> topic) async {
    final db = await database;
    return await db.insert('topics', topic);
  }

  Future<List<Map<String, dynamic>>> getAllTopics() async {
    final db = await database;
    return await db.query('topics');
  }

  Future<List<Map<String, dynamic>>> getTopicsBySubjectId(
      int subjectId) async {
    final db = await database;
    final List<Map<String, dynamic>> topics = await db.query(
      'topics',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );
    return topics;
  }

  Future<Map<String, dynamic>> getTopicById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> topics = await db.query(
      'topics',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (topics.isNotEmpty) {
      return topics.first;
    } else {
      throw Exception('topic with ID $id not found.');
    }
  }

  Future<int> updateTopic(Map<String, dynamic> topic) async {
    final db = await database;
    return await db.update('topics', topic,
        where: 'topic_id = ?', whereArgs: [topic['topic_id']]);
  }

  Future<int> updateTopicTitle(int topicId, String newTitle) async {
    final db = await database;
    final Map<String, dynamic> topic = {
      'title': newTitle,
    };
    return await db.update('topics', topic,
        where: 'id = ?', whereArgs: [topicId]);
  }

  Future<int> deleteTopic(int topicId) async {
    final db = await database;
    return await db
        .delete('topics', where: 'id = ?', whereArgs: [topicId]);
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

  Future<List<Map<String, dynamic>>> getAllNotesByTopicId(
      int topicId) async {
    final db = await database;
    return await db
        .query('notes', where: 'topic_id = ?', whereArgs: [topicId]);
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
