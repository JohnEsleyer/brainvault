import 'package:brainvault/widgets/loading_widget.dart';
import 'package:brainvault/widgets/markdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:brainvault/screens/note_screen.dart';
import 'package:brainvault/services/database_service.dart';
import 'package:flutter/rendering.dart';

import '../colors.dart';

class DocumentScreen extends StatefulWidget {
  final int documentId;
  final bool studyMode;

  DocumentScreen({required this.documentId, required this.studyMode});

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
  int _loadingNote = -1; // -1 means no note is loading, stores the index of note that is loading


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

    return FutureBuilder(
        future: loadingData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              floatingActionButton: Visibility(
                visible: !widget.studyMode,
                child: FloatingActionButton(
                  onPressed: () async {
                                // Create new note
                          
                                Map<String, dynamic> data = {
                                  'document_id': widget
                                      .documentId, // Replace with the appropriate document_id of the associated document
                                  'content': '',
                                  'position': _notes.length + 1,
                            
                                  'type': 'markdown',
                                  'table_name': 'note',
                                };
                                int noteId = await dbHelper.insertNote(data);
                            
                                await Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (_) => NoteScreen(
                                    content: data['content'],
                                    noteId: noteId,
                                    readMode: false,
                                    type: 'markdown',
                                  ),
                                ));
                                refreshData();
                              },
                              child: Icon(Icons.add, color: Colors.black),
                              backgroundColor: Colors.white,
                              
                ),
              ),
              body: GestureDetector(
                onDoubleTap: () {
                  if (widget.studyMode)
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DocumentScreen(
                        documentId: widget.documentId,
                        studyMode: false,
                      ),
                    ));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: palette[1],
                  child: Column(
                    children: [
                      // Title
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          left: 8.0,

                        ),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                Visibility(
                                  visible: !widget.studyMode,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                          
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.80,
                                  child: EditableText(
                                    onChanged: (newText) {
                                      updateTitle();
                                    },
                                    expands: true,
                                    maxLines: null,
                                    minLines: null,
                                    readOnly: widget.studyMode,
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
                              ],
                            ),
                            Visibility(
                              visible: isLoading,
                              child: Container(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                                        
                          ),
                          child: ListView.builder(
 
                            itemCount: _notes.length,
                            itemBuilder: (context, index) {
                              return LoadingIndicatorWidget(
                                isLoading: _loadingNote == index,
                                child: GestureDetector(
                                  onTap: () async {
                                    if (!widget.studyMode)
                                      await Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return NoteScreen(
                                            readMode: true,
                                            content: _notes[index]['content'],
                                            noteId: _notes[index]['id'],
                                            type: 'markdown');
                                      }));
                                      refreshData();
                                      setState(() {
                                        _loadingNote = index;
                                      });
                                      await Future.delayed(Duration(seconds: 1));
                                      setState(() {
                                        _loadingNote = -1;
                                      });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: palette[2],
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: MarkdownWidget(
                                        markdown: _notes[index]['content'],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                
                     
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Scaffold(
                body: Container(
                  color: palette[1],
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                ));
          }
        });
  }
}
