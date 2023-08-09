import 'package:flutter/material.dart';
import 'package:brainvault/colors.dart';
import 'package:brainvault/screens/topic_screen.dart';
import 'package:brainvault/services/database_service.dart';

class SubjectScreen extends StatefulWidget {
  final int subjectId;

  SubjectScreen({super.key, required this.subjectId});

  @override
  // ignore: library_private_types_in_public_api
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final dbHelper = DatabaseService();
  late List<Map<String, dynamic>> topics;
  late Map<String, dynamic> subject;
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
      subject = await dbHelper.getSubjectById(widget.subjectId);
      topics = await dbHelper.getTopicsBySubjectId(widget.subjectId);
      _titleController.text = subject['title'];
      _descriptionController.text = subject['description'];

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
      var col = await dbHelper.getSubjectById(widget.subjectId);
      var doc = await dbHelper.getTopicsBySubjectId(widget.subjectId);

      // When succesfull
      setState(
        () {
          subject = col;
          topics = doc;
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
    await dbHelper.updateSubjectTitle(widget.subjectId, _titleController.text);
  }

  void updateDescription() async {
    await dbHelper.updateSubjectDescription(
        widget.subjectId, _descriptionController.text);
  }

  void _deleteSubject() async {
    await dbHelper.deleteSubject(widget.subjectId);
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.black),
          onPressed: () async {
            var data = {
              'subject_id': widget.subjectId,
              'title': 'Untitled',
              'position': topics.length + 1,
              'table_name': 'topic',
            };
            try {
              int id = await dbHelper.insertTopic(data);

              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TopicScreen(
                  topicId: id,
                  studyMode: false,
                ),
              ));
              refreshData();
            } catch (e) {
              print("topic creation failed: $e");
            }
          },
          backgroundColor: palette[5],
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            color: palette[1],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                          Container(
                            width: MediaQuery.of(context).size.width * 0.70,
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
                            color: _isHoverDelete ? Colors.red : Colors.white,
                          ),
                        ),
                      ),
                    ],
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
                          for (var topic in topics)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                    builder: (_) => TopicScreen(
                                      topicId: topic['id'],
                                      studyMode: false,
                                    ),
                                  ));
                                  refreshData();
                                },
                                child: Container(
                                  height: 100,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: palette[4],
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
