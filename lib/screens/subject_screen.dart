import 'dart:io';

import 'package:flutter/material.dart';
import 'package:brainvault/colors.dart';
import 'package:brainvault/screens/topic_screen.dart';
import 'package:brainvault/services/database_service.dart';

import '../widgets/study_widget.dart';

class SubjectScreen extends StatefulWidget {
  final int subjectId;

  SubjectScreen({super.key, required this.subjectId});

  @override
  // ignore: library_private_types_in_public_api
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final _dbHelper = DatabaseService();
  late List<Map<String, dynamic>> _topics;
  late Map<String, dynamic> _subject;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool isLoading = true;
  bool hidden = true;
  bool _isHoverDelete = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      _subject = await _dbHelper.getSubjectById(widget.subjectId);
      _topics = await _dbHelper.getTopicsBySubjectId(widget.subjectId);
      _titleController.text = _subject['title'];
      _descriptionController.text = _subject['description'];

      // When successfull
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Loading Data Failed: $e");
    }
  }

  void refreshData() async {
    setState(() {
      hidden = false;
    });
    try {
      var col = await _dbHelper.getSubjectById(widget.subjectId);
      var doc = await _dbHelper.getTopicsBySubjectId(widget.subjectId);

      // When succesfull
      setState(
        () {
          _subject = col;
          _topics = doc;
        },
      );
    } catch (e) {
      print('Failed to refreshd data: $e');
    }
    setState(() {
      hidden = true;
    });
  }

  void updateTitle() async {
    await _dbHelper.updateSubjectTitle(widget.subjectId, _titleController.text);
    _dbHelper.saveJSON();
  }

  void updateDescription() async {
    await _dbHelper.updateSubjectDescription(
        widget.subjectId, _descriptionController.text);
    _dbHelper.saveJSON();
  }

  void _deleteSubject() async {
    await _dbHelper.deleteSubject(widget.subjectId);
    _dbHelper.saveJSON();
  }

  // Obtain all notes from the subject
  Future<List<Map<String, dynamic>>> _obtainAllNotes() async {
    return _dbHelper.getNotesForSubject(widget.subjectId);
  }

  void _createNewTopic() async {
    var data = {
      'subject_id': widget.subjectId,
      'title': 'Untitled Topic',
      'table_name': 'topic',
    };
    try {
      int id = await _dbHelper.insertTopic(data);

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TopicScreen(
          topicId: id,
        ),
      ));

      // Save data to brain file
      _dbHelper.saveJSON();

      refreshData();
    } catch (e) {
      print("Topic creation failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.black),
          onPressed: _createNewTopic,
          backgroundColor: palette[6],
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            color: palette[1],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: Platform.isAndroid,
                  child: SizedBox(
                    height: 20,
                  ),
                ),
                // Title
                IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.60,
                          child: Row(
                            children: [
                              GestureDetector(
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
                              Expanded(
                                     
                                child: TextField(
                                  
                                  enabled: true,
                                  focusNode: FocusNode(
                                    canRequestFocus: true,
                                    skipTraversal: true,
                                  ),
                                  // keyboardType: TextInputType.multiline,
                                  cursorColor: Colors.white,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Subject Title',
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    border: InputBorder.none,
                                  ),
                                  expands: true,
                                  maxLines: null,
                                  minLines: null,
                                  onChanged: (newText) {
                                    updateTitle();
                                  },
                                  controller: _titleController,
                                  textInputAction: TextInputAction.newline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                var notes = await _obtainAllNotes();
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return Study(notes: notes);
                                }));
                              },
                              child: Tooltip(
                                message:
                                    'Study the notes from this subject randomly',
                                child: Icon(
                                  Icons.menu_book,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: palette[2],
                                        title: Text('Delete this subject?'),
                                        content:
                                            Text('This action cannot be undone.'),
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
                                              _deleteSubject();
                                              Navigator.pop(
                                                  context); // Close the dialog
                                              Navigator.pop(
                                                  context); // Close the topic screen
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
                                child: Icon(
                                  Icons.delete_forever,
                                  color:
                                      _isHoverDelete ? Colors.red : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Description and other buttons
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        child: EditableText(
                          onChanged: (newText) {
                            updateDescription();
                          },
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          backgroundCursorColor: palette[1],
                          cursorColor: Colors.white,
                          controller: _descriptionController,
                          focusNode: FocusNode(canRequestFocus: true),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (!hidden)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Wrap(
                        children: [
                          for (var topic in _topics)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                    builder: (_) => TopicScreen(
                                      topicId: topic['id'],
                                    ),
                                  ));
                                  refreshData();
                                },
                                child: Container(
                                  height: 100,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: palette[6],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      topic['title'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
  }
}
