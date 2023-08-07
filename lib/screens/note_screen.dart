import 'package:brainvault/widgets/markdown_widget.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../services/database_service.dart';

class NoteScreen extends StatefulWidget {
  final bool readMode;
  final String content; // if empty => load data from db
  final int noteId;
  final String type; // Flash card note type or not and other future types

  NoteScreen(
      {required this.readMode,
      required this.content,
      required this.noteId,
      required this.type});

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  TextEditingController _editingController = TextEditingController();
  final DatabaseService _dbHelper = DatabaseService();
  late bool _editMode;
  bool _isLoading = false;

  void initState() {
    if (widget.readMode == true) {
      _editMode = false;
      _loadData();
    } else {
      _editMode = true;
      _loadData();
    }
  }

  void _loadData() async {
    if (widget.content == '') {
      // If no content hasn't been provided from previous screen.
      try {
        setState(() {
          _isLoading = true;
        });

        Map<String, dynamic> temp = await _dbHelper.getNoteById(widget.noteId);

        setState(() {
          _editingController.text = temp['content'];
        });
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('Fetching note data failed: $e');
      }
    } else {
      // If content has been provided by previous screen.
      _editingController.text = widget.content;
    }
  }

  void _updateDb() {
    _dbHelper.updateNoteContent(widget.noteId, _editingController.text);
  }

  Widget _display() {
    if (_editMode == true) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.81,
        child: Scaffold(
          body: Container(
            color: palette[2],
            child: Padding(
              padding: const EdgeInsets.only(
                left: 9.0,
                top: 5.0,
              ),
              child: TextField(
                cursorColor: Colors.white,
                style: TextStyle(
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                expands: true,
                maxLines: null,
                minLines: null,
                controller: _editingController,
                onChanged: (value) {
                  _updateDb();
                },
              ),
            ),
          ),
        ),
      );
    } else {
      if (!_isLoading) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.81,
          color: palette[2],
          child: SingleChildScrollView(
            child: MarkdownWidget(
              markdown: _editingController.text,
            ),
          ),
        );
      }else{
        return Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),

        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_editingController.text);
    return Container(
      color: palette[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_back,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: palette[1],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Read Mode
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _editMode = !_editMode;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                color: _editMode ? palette[1] : palette[2],
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Read View',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Edit Mode
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _editMode = !_editMode;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                color: _editMode ? palette[2] : palette[1],
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Editor',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.83,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: palette[2],
                      ),
                      child: SingleChildScrollView(
                        child: _display(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
