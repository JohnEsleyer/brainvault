import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:typed_data';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


class BrainProvider{
  
  late Database db;

  /// Upload .brain
  Future<void> uploadBrain() async {
    
  }


  // Download brain
  Future<void> downloadBrain() async {

  }

  // Create brain
  Future<void> createBrain() async {
    String dbPath = 'brain.db';

    db = await openDatabase(
      dbPath,
      version: 1,
      onCreate:(db, version) async {
        await db.execute(
          '''
          CREATE TABLE collections (
            collection_id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT,
            created_at INTEGER
          );
          '''
        );

        await db.execute(
          '''
          CREATE TABLE chunks (
            chunk_id INTEGER PRIMARY KEY,
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
            note_id INTEGER PRIMARY KEY,
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
      },
    );
    print("Brain successfully created");
  }

    // Get all brain collections
    Future<List<Map<String, dynamic>>> getBrainCollections() async {
      return await db.query('collections');
    }

    // Save a brain collection
    Future<int> insertBrainCollection(Map<String, dynamic> collectionData) async {
      return await db.insert('collections', collectionData);
    }

    // Get all brain chunks within a collection
    Future<List<Map<String, dynamic>>> getBrainChunks(int collectionId) async {
      return await db.query('chunks', where: 'collection_id = ?', whereArgs: [collectionId]);
    }

    // Save a brain chunk within a collection
    Future<int> insertBrainChunk(Map<String, dynamic> chunkData) async {
      return await db.insert('chunks', chunkData);
    }

    // Get all notes within a chunk
    Future<List<Map<String, dynamic>>> getNotesInChunk(int chunkId) async {
      return await db.query('notes', where: 'chunk_id = ?', whereArgs: [chunkId]);
    }

    // Save a note within a chunk
    Future<int> insertNoteInChunk(Map<String, dynamic> noteData) async {
      return await db.insert('notes', noteData);
    }
}
