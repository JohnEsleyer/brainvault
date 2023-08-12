import 'package:brainvault/colors.dart';
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
  late List<Map<String, dynamic>> _notes;
  int index = 0;

  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    _notes = [];
    try {
      var notes = await dbHelper.getAllNotes();

      // To improve performance, restrict notes to 50 of length only.
      if (notes.length > 50) {
        notes = getRandom50Elements(notes);
      }
      _notes.addAll(notes);
      _notes.shuffle();

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

  Widget _renderNote() {
      // If index is note
      return GestureDetector(
        onDoubleTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NoteScreen(
              readMode: true,
              noteId: _notes[index]['id'],
              content: _notes[index]['content'],

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
                markdown: _notes[index]['content'],
              ),
            ),
          ),
        ),
      );
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
                  child: _renderNote(),
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
                        index = (index + 1) % _notes.length;
                        _isLoading = true;
                      });

                      await Future.delayed(Duration(seconds: 1));
                      setState(() {
                        _isLoading = false;
                      });
                  
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
