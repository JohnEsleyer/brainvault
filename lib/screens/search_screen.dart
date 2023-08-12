import 'dart:io';

import 'package:brainvault/screens/topic_screen.dart';
import 'package:brainvault/screens/note_screen.dart';
import 'package:brainvault/services/database_service.dart';
import 'package:brainvault/widgets/markdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:brainvault/colors.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _resultsTopics = [];
  List<Map<String, dynamic>> _resultsNotes = [];
  bool _isLoading = false;
  bool _topicsVisibility = false;
  bool _notesVisibility = false;

  void _onSearchTextSubmitted(String query) async {
    setState(() {
      _isLoading = true;
    });
    if (query.isEmpty) {
      setState(() {
        _resultsTopics.clear();
        _resultsNotes.clear();
      });
      return;
    }
    _resultsTopics.clear();
    _resultsNotes.clear();
    DatabaseService databaseService = DatabaseService();
    List<Map<String, dynamic>> results =
        await databaseService.searchTopicsAndNotes(query);

    // Store topics and notes separately
    for (Map<String, dynamic> res in results) {
      if (res['table_name'] == 'topic') {
        setState(() {
          _resultsTopics.add(res);
        });
      } else {
        // Check if note has more than 5 lines.

        if (countLines(res['content']) > 5) {
          // Limit the content to 5 lines only

          var tempString = getFirstFiveLines(res['content']);

          // Add 'See more' text

          tempString = tempString + '\n\n\nSee more...';
          print('tempString: ${tempString}');

          Map<String, dynamic> tempMap = {};
          tempMap['id'] = res['id'];
          tempMap['topic_id'] = res['topic_id'];
          tempMap['table_name'] = res['table_name'];
          tempMap['position'] = res['position'];
          tempMap['type'] = res['id'];
          tempMap['content'] = tempString;
          setState(() {
            _resultsNotes.add(tempMap);
          });
        } else {
          setState(() {
            _resultsNotes.add(res);
          });
        }
      }
    }
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      if (_resultsTopics.length == 0) {
        _topicsVisibility = false;
      } else {
        _topicsVisibility = true;
      }
      if (_resultsNotes.length == 0) {
        _notesVisibility = false;
      } else {
        _notesVisibility = true;
      }
      _isLoading = false;
    });
    print('topics: $_resultsTopics');
    print('Notes: ${_resultsNotes}');
  }

  int countLines(String inputString) {
    List<String> lines = inputString.split('\n');
    return lines.length;
  }

  String getFirstFiveLines(String inputString) {
    List<String> lines = inputString.split('\n');
    int endIndex = lines.length < 5 ? lines.length : 5;
    return lines.sublist(0, endIndex).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: palette[3],
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Visibility(
              visible: Platform.isAndroid,
              child: SizedBox(
                height: 20,
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Hero(
                tag: 'search',
                child: Container(
                  decoration: BoxDecoration(
                    color: palette[2],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: MediaQuery.of(context).size.width * 0.90,
                  height: 50,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(Icons.close)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TextField(
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              focusColor: Colors.white,
                              hoverColor: Colors.white,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              hintText: 'Search keyword',
                            ),
                            controller: _searchController,
                            onSubmitted: _onSearchTextSubmitted,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.88,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _topicsVisibility
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'topics',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.20,
                                        decoration: BoxDecoration(
                                          color: palette[1],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              for (var result in _resultsTopics)
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                        builder: (context) {
                                                          return TopicScreen(
                                                              topicId:
                                                                  result['id'],
                                                             );
                                                        },
                                                      ));
                                                    },
                                                    child: Container(
                                                      height: 100,
                                                      width: 150,
                                                      decoration: BoxDecoration(
                                                        color: palette[2],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Center(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                            result['title']),
                                                      )),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            _notesVisibility
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Notes',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Wrap(
                                        children: [
                                          for (var result in _resultsNotes)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          NoteScreen(
                                                        noteId: result['id'],
                                                        readMode: true,
                                                        content: '',

                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: palette[2],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: MarkdownWidget(
                                                    markdown: result['content'],
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
