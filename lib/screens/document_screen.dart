import 'package:flutter/material.dart';
import 'package:brainvault/screens/note_screen.dart';
import 'package:brainvault/services/database_service.dart';

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
  bool isLoading = false;
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

  void refreshData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var doc = await dbHelper.getDocumentById(widget.documentId);
      // var text = _document['title'];
      var notes = await dbHelper.getAllNotesByDocumentId(widget.documentId);
      setState(() {
        _document = doc;
        // _titleController.text = text;
        _notes = notes;
      });
    } catch (e) {
      print('Failed to refresh data: $e');
    }

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  void updateTitle() async {
    await dbHelper.updateDocumentTitle(
        widget.documentId, _titleController.text);
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? FutureBuilder(
            future: loadingData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return LayoutBuilder(builder: ((context, constraints) {
                  if (constraints.maxWidth < 800) {
                    // Portrait View
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
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.90,
                                    child: EditableText(
                                      onChanged: (newText) {
                                        updateTitle();
                                      },
                                      expands: true,
                                      maxLines: null,
                                      minLines: null,
                                      backgroundCursorColor: palette[1],
                                      cursorColor: Colors.white,
                                      controller: _titleController,
                                      focusNode:
                                          FocusNode(canRequestFocus: true),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            for (var note in _notes)
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                    builder: (_) => NoteScreen(
                                      noteId: note['id'],
                                      readMode: false,
                                      
                                    ),
                                  ));
                                  refreshData();
                                },
                                child: NoteScreen(
                                  noteId: note['id'],
                                  readMode: true,
                                  content: note['content'],
                                  type: note['type'],
                                  onDelete: () {
                                    refreshData();
                                  },
                                ),
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

                                    'type': 'HTML',
                                    'table_name': 'note',
                                  };
                                  int noteId = await dbHelper.insertNote(data);

                                  await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                    builder: (_) => NoteScreen(
                                        noteId: noteId, readMode: false),
                                  ));
                                  refreshData();
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: palette[5],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Container(
                                      height: 50,
                                      width: 50,
                                      child: Icon(Icons.add, color: palette[1]),
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
                  // Landscape View
                  return Scaffold();
                }));
              } else {
                return Scaffold(
                    body: Center(
                        child: CircularProgressIndicator(color: Colors.white)));
              }
            })
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
  }
}
