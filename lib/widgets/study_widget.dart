import 'package:flutter/material.dart';

import '../colors.dart';
import '../screens/note_screen.dart';
import 'loading_widget.dart';
import 'markdown_widget.dart';

// ignore: must_be_immutable
class Study extends StatefulWidget {
  List<dynamic> notes;
  Study({required this.notes});

  @override
  _StudyState createState() => _StudyState();
}

class _StudyState extends State<Study> {
  bool _isLoading = false;

  int index = 0;

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
                child: widget.notes.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: palette[1],
                        ),
                        child: LoadingIndicatorWidget(
                          isStudy: true,
                          child: GestureDetector(
                            onDoubleTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => NoteScreen(
                                  readMode: true,
                                  noteId: widget.notes[index]['id'],
                                  content: widget.notes[index]['content'],
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
                                  physics: BouncingScrollPhysics(),
                                  child: MarkdownWidget(
                                    markdown: widget.notes[index]['content'],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          isLoading: _isLoading,
                        ),
                      )
                    : const Center(child: Text('Unable to find any notes'))),

            // Bottom bar
            Visibility(
              visible: widget.notes.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          index = (index - 1) % widget.notes.length;
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
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Back",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          index = (index + 1) % widget.notes.length;
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
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
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
            ),
          ],
        ),
      ),
    );
  }
}
