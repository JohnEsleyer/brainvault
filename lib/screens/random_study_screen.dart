import 'package:brainvault/colors.dart';
import 'package:brainvault/screens/document_screen.dart';
import 'package:brainvault/screens/note_screen.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import '../services/database_service.dart';

class RandomStudy extends StatefulWidget {
  @override
  _RandomStudyState createState() => _RandomStudyState();
}

class _RandomStudyState extends State<RandomStudy> {
  bool _isLoading = true;
  final dbHelper = DatabaseService();
  late List<Map<String, dynamic>> _docsNNotes;
  int index = 0;

  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    _docsNNotes = [];
    try {
      var docs = await dbHelper.getAllDocuments();
      var notes = await dbHelper.getAllNotes();

      // To improve performance, restrict elements to 50 of length only.
      if (docs.length > 50) {
        docs = getRandom50Elements(docs);
      }
      if (notes.length > 50) {
        notes = getRandom50Elements(notes);
      }
      _docsNNotes.addAll(docs);
      _docsNNotes.addAll(notes);
      _docsNNotes.shuffle();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load data: $e');
    }
  }

  List<T> getRandom50Elements<T>(List<T> list) {
    final random = new Random();
    var _randomList = <T>[];

    for (var i = 0; i < 50; i++) {
      var index = random.nextInt(list.length - i);
      _randomList.add(list[index]);
      list.removeAt(index);
    }

    return _randomList;
  }

  //  void refreshData() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {

  //     // var text = _document['title'];
  //     _docsNNotes[index] = await dbHelper.getAllNotesByDocumentId(widget.documentId);
  //     setState(() {
  //       _document = doc;
  //       // _titleController.text = text;
  //       _notes = notes;
  //     });
  //   } catch (e) {
  //     print('Failed to refresh data: $e');
  //   }

  //   await Future.delayed(Duration(seconds: 1));
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  Widget renderDocNNote() {
    if (_docsNNotes[index]['table_name'] == 'document') {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: palette[1],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DocumentScreen(
              documentId: _docsNNotes[index]['id'],
              studyMode: true,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width * 0.70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: palette[2],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DocumentScreen(
                      documentId: _docsNNotes[index]['document_id'],
                      studyMode: false),
                ));
              },
              child: NoteScreen(
                readMode: true,
                noteId: _docsNNotes[index]['id'],
                content: _docsNNotes[index]['content'],
                type: 'markdown',
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // App bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.arrow_back),
                ),
              ],
            ),
          ),
          // Body
          Container(
            height: MediaQuery.of(context).size.height * 0.82,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : renderDocNNote(),
          ),

          // Bottom bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      index = (index + 1) % _docsNNotes.length;
                      _isLoading = true;
                    });

                    await Future.delayed(Duration(seconds: 1));
                    setState(() {
                      _isLoading = false;
                    });
                    print('=========================');
                    print('LENGTH: ${_docsNNotes.length}');
                    print('INDEX: $index');
                    print(_docsNNotes[index]);
                    print(_docsNNotes[index]['content']);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Next",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
