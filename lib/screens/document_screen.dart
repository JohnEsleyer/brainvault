import 'package:flutter/material.dart';
import 'package:secondbrain/screens/note_screen.dart';
import 'package:secondbrain/services/database_service.dart';

import '../colors.dart';

class DocumentScreen extends StatefulWidget {
  final int documentId;

  DocumentScreen({required this.documentId});

  @override
  _DocumentScreenState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final dbHelper = DatabaseService();
  final TextEditingController _titleController = TextEditingController();
  late Map<String, dynamic> _document;
  late List<Map<String, dynamic>> _notes;

  late Future<void> loadingData;

  @override
  void initState() {
    super.initState();
    loadingData = loadData();
  }

  Future<void> loadData() async {
    try {
      _document = await dbHelper.getDocumentById(widget.documentId);
      _titleController.text = _document['title'];
      _notes = await dbHelper.getAllNotesByDocumentId(widget.documentId);
    } catch (e) {
      print('Failed to load data: $e');
    }
  }

  void updateTitle() async {
    await dbHelper.updateDocumentTitle(
        widget.documentId, _titleController.text);
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadingData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return LayoutBuilder(builder: ((context, constraints) {
              if (constraints.maxWidth < 800) {
                // Mobile View
                return Scaffold(
                  body: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: palette[1],
                    child: ListView(
                      children: [
                        // Title
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: EditableText(
                            onChanged: (newText) {
                              updateTitle();
                            },
                            backgroundCursorColor: palette[1],
                            cursorColor: Colors.white,
                            controller: _titleController,
                            focusNode: FocusNode(canRequestFocus: true),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        for (var note in _notes)
                          NoteScreen(
                            noteId: note['id'],
                            readMode: true,
                          ),

                        Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.02),
                          child: GestureDetector(
                            onTap: () async {
                              // Create new note

                              var data = {
                                'document_id': widget
                                    .documentId, // Replace with the appropriate document_id of the associated document
                                'content': '',
                                'position': _notes.length + 1,
                                'created_at':
                                    DateTime.now().millisecondsSinceEpoch,
                                'last_reviewed':
                                    DateTime.now().millisecondsSinceEpoch,
                                'next_review': DateTime.now()
                                        .millisecondsSinceEpoch +
                                    86400000, // Adding 1 day in milliseconds
                                'spaced_repetition_level': 0,
                              };
                              int noteId = await dbHelper.insertNote(data);

                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => NoteScreen(
                                    noteId: noteId, readMode: false),
                              ));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: palette[2],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                    child: Container(
                                  height: 50,
                                  width: 50,
                                  child: Icon(Icons.add),
                                )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              // Desktop View
              return Scaffold();
            }));
          } else {
            return Scaffold(
                body: Center(
                    child: CircularProgressIndicator(color: Colors.white)));
          }
        });
  }
}
