import 'package:brainvault/colors.dart';
import 'package:brainvault/screens/topic_screen.dart';
import 'package:brainvault/screens/note_screen.dart';
import 'package:brainvault/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import '../services/database_service.dart';
import '../widgets/markdown_widget.dart';

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
      var docs = await dbHelper.getAllTopics();
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

  Widget _renderDocNote() {
    if (_docsNNotes[index]['table_name'] == 'topic') {
      // if index is topic
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.81,
          color: palette[2],
          child: TopicScreen(
            topicId: _docsNNotes[index]['id'],
            studyMode: true,
          ),
        ),
      );
    } else {
      // If index is note
      return GestureDetector(
        onDoubleTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NoteScreen(
              readMode: true,
              noteId: _docsNNotes[index]['id'],
              content: _docsNNotes[index]['content'],
              type: 'markdown',
            ),
          ));
        },
        child: Container(
         width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: palette[2],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: MarkdownWidget(
                markdown: _docsNNotes[index]['content'],
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
      body: Container(
        color: palette[0],
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            // Top
            Expanded(
              flex: 1,
              child: Padding(
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
            ),
            // Body
            Expanded(
              flex: 15,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: palette[1],
                ),
                child: LoadingIndicatorWidget(
                  child: _renderDocNote(),
                  isLoading: _isLoading,
                ),
              ),
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
      ),
    );
  }
}
