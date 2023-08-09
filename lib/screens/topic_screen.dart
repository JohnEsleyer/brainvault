import 'dart:io';

import 'package:brainvault/widgets/loading_widget.dart';
import 'package:brainvault/widgets/markdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:brainvault/screens/note_screen.dart';
import 'package:brainvault/services/database_service.dart';
import 'package:flutter/rendering.dart';

import '../colors.dart';

class TopicScreen extends StatefulWidget {
  TopicScreen({required this.topicId, required this.studyMode});

  final bool studyMode;
  final int topicId;

  @override
  _TopicScreenState createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  bool isLoading = false;
  late Future<void> loadingData;

  final _dbHelper = DatabaseService();
  bool _isHoverDelete = false;
  int _loadingNote =
      -1; // -1 means no note is loading, stores the index of note that is loading

  late List<Map<String, dynamic>> _notes;
  final TextEditingController _titleController = TextEditingController();
  late Map<String, dynamic> _topic;

  @override
  void initState() {
    super.initState();

    loadingData = loadData();
  }

  Future<void> loadData() async {
    try {
      _topic = await _dbHelper.getTopicById(widget.topicId);
      _titleController.text = _topic['title'];
      _notes = await _dbHelper.getAllNotesByTopicId(widget.topicId);
    } catch (e) {
      print('Failed to load data: $e');
    }
  }

  void refreshData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var doc = await _dbHelper.getTopicById(widget.topicId);
      // var text = _Topic['title'];
      var notes = await _dbHelper.getAllNotesByTopicId(widget.topicId);
      setState(() {
        _topic = doc;
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
    await _dbHelper.updateTopicTitle(widget.topicId, _titleController.text);
  }

  void _deleteTopic() async {
    await _dbHelper.deleteTopic(widget.topicId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadingData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              backgroundColor: palette[1],
              floatingActionButton: Visibility(
                visible: !widget.studyMode,
                child: FloatingActionButton(
                  onPressed: () async {
                    // Create new note

                    Map<String, dynamic> data = {
                      'Topic_id': widget
                          .topicId, // Replace with the appropriate Topic_id of the associated Topic
                      'content': '',
                      'position': _notes.length + 1,

                      'type': 'markdown',
                      'table_name': 'note',
                    };
                    int noteId = await _dbHelper.insertNote(data);

                    await Navigator.of(context).push(MaterialPageRoute(
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
                      builder: (context) => TopicScreen(
                        topicId: widget.topicId,
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
                      Visibility(
                        visible: Platform.isAndroid,
                        child: SizedBox(
                          height: 20,
                        ),
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          left: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Visibility(
                                  visible: !widget.studyMode,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.70,
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
                            Row(
                              children: [
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
                                Visibility(
                                  visible: !widget.studyMode,
                                  child: GestureDetector(
                                    onTap: () async {
                                      await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: palette[2],
                                              title: Text('Delete this Topic?'),
                                              content: Text(
                                                  'This action cannot be undone.'),
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
                                                    _deleteTopic();
                                                    Navigator.pop(
                                                        context); // Close the dialog
                                                    Navigator.pop(
                                                        context); // Close the Topic screen
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: MouseRegion(
                                        onEnter: (even) {
                                          setState(() {
                                            _isHoverDelete = true;
                                          });
                                        },
                                        onExit: (event) {
                                          setState(() {
                                            _isHoverDelete = false;
                                          });
                                        },
                                        child: Icon(
                                          Icons.delete_forever,
                                          color: _isHoverDelete
                                              ? Colors.red
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                            physics: BouncingScrollPhysics(),
                            itemCount: _notes.length,
                            itemBuilder: (context, index) {
                              return LoadingIndicatorWidget(
                                isLoading: _loadingNote == index,
                                child: GestureDetector(
                                  onTap: () async {
                                    if (!widget.studyMode) {
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
                                      await Future.delayed(
                                          Duration(seconds: 1));
                                      setState(() {
                                        _loadingNote = -1;
                                      });
                                    }
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
              child:
                  Center(child: CircularProgressIndicator(color: Colors.white)),
            ));
          }
        });
  }
}
