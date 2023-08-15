import 'dart:async';
import 'dart:io';

import 'package:brainvault/widgets/IndetableTextField.dart';
import 'package:brainvault/widgets/loading_widget.dart';
import 'package:brainvault/widgets/markdown_widget.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../services/database_service.dart';

class NoteScreen extends StatefulWidget {
  final bool readMode;
  final String content; // if empty => load data from db
  final int noteId;

  NoteScreen({
    required this.readMode,
    required this.content,
    required this.noteId,
  });

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  TextEditingController _editingController = TextEditingController();
  final DatabaseService _dbHelper = DatabaseService();
  late bool _editMode;
  bool _isLoading = false;
  bool _isHoverDelete = false;
  bool _isReadLandscapeLoading = false;
  TextEditingController _textEditingController = TextEditingController();
  Timer? _debounceTimer;

  void initState() {
    super.initState();
    if (widget.readMode == true) {
      _editMode = false;
      _loadData();
    } else {
      _editMode = true;
      _loadData();
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
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
    _dbHelper.saveJSON();
  }

  Widget _display() {
    if (_editMode == true) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.88,
        child: Scaffold(
          backgroundColor: palette[2],
          // resizeToAvoidBottomInset: false,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 22, 21, 21),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 9.0,
                  top: 5.0,
                ),
                child: IndentableTextField(
                  controller: _editingController,
                  onChanged: (value) {
                    _updateDb();
                  },
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      if (!_isLoading) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.85,
          color: palette[2],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: MarkdownWidget(
                markdown: _editingController.text,
              ),
            ),
          ),
        );
      } else {
        return Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }
    }
  }

  void _deleteNote() async {
    await _dbHelper.deleteNote(widget.noteId);
    _dbHelper.saveJSON();
  }

  Widget _deleteNoteWidget() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        right: 8.0,
        left: 8.0,
      ),
      child: GestureDetector(
        onTap: () async {
          await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: palette[2],
                  title: Text('Delete this note?'),
                  content: Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _deleteNote();
                        Navigator.pop(context); // Close the dialog
                        Navigator.pop(context); // Close the note screen
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              });
        },
        child: MouseRegion(
          onHover: (event) {
            setState(() {
              _isHoverDelete = true;
            });
          },
          onExit: (event) {
            setState(() {
              _isHoverDelete = false;
            });
          },
          child: Tooltip(
            message: 'Delete this note',
            child: Icon(
              Icons.delete_forever,
              color: _isHoverDelete ? Colors.red : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _popScreenWidget() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          left: 8.0,
          right: 8.0,
        ),
        child: Icon(
          Icons.arrow_back,
        ),
      ),
    );
  }

  Widget _topBar() {
    if (MediaQuery.of(context).size.width < 650) {
      // Portrait view of top bar
      return Row(
        children: [
          _popScreenWidget(),
          // Read Mode
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _editMode = false;
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
                  _editMode = true;
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
          _deleteNoteWidget(),
        ],
      );
    } else {
      // Landscape view of top bar
      return Row(
        children: [
          _popScreenWidget(),
          // Read Mode
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: palette[2],
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
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
          // Edit Mode
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: palette[1],
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
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
          _deleteNoteWidget(),
        ],
      );
    }
  }

  // Executed when editor in landscape layout is active
  void _onTextChangedLandscape(String newText) {
    // Load the read section in landscape layout
    setState(() {
      _isReadLandscapeLoading = true;
    });
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      // Stop the loading of read section
      setState(() {
        _isReadLandscapeLoading = false;
      });
      // Update db
      _updateDb();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: Platform.isAndroid,
            child: const SizedBox(
              height: 30,
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
                    _topBar(),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.89,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: palette[2],
                      ),
                      child: MediaQuery.of(context).size.width < 650
                          ?
                          // Portrait view
                          SingleChildScrollView(
                              child: _display(),
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height * 0.90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: palette[2],
                              ),
                              child: Row(
                                children: [
                                  // Read view (Landscape)
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.89,
                                      color: palette[2],
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SingleChildScrollView(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          child: LoadingIndicatorWidget(
                                            isReadView: true,
                                            isLoading: _isReadLandscapeLoading,
                                            child: MarkdownWidget(
                                              markdown: _editingController.text,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Editor (Landscape)
                                  Expanded(
                                    flex: 1,
                                    child: Scaffold(
                                      backgroundColor: palette[1],
                                      body: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color:
                                              const Color.fromARGB(255, 22, 21, 21),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 9.0,
                                            top: 5.0,
                                          ),
                                          child: IndentableTextField(
                                            controller: _editingController,
                                            onChanged: _onTextChangedLandscape
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
