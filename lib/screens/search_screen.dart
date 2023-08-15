import 'dart:developer';
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

        setState(() {
          _resultsNotes.add(res);
        });
      }
    }
    await Future.delayed(const Duration(seconds: 1));
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
  }

  void _openNoteScreen(result) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteScreen(
          noteId: result['id'],
          readMode: true,
          content: result['content'],
        ),
      ),
    );
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
              child: const SizedBox(
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
                            child: const Icon(Icons.close)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TextField(
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
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
                      const Padding(
                        padding: EdgeInsets.all(8.0),
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
                                      const Text(
                                        'Topics',
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
                                      const Text(
                                        'Notes',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      MediaQuery.of(context).size.width < 650
                                          ?

                                          // Portrait view
                                          Column(
                                              children: [
                                                for (var result
                                                    in _resultsNotes)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: GestureDetector(
                                                      onTap: (){
                                                        _openNoteScreen(result);
                                                      },
                                                      child: Container(
                                                        width: double.maxFinite,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: palette[2],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: MarkdownWidget(
                                                            previewMode: true,
                                                            markdown: result[
                                                                'content'],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            )
                                          :

                                          // Landscape view
                                          Wrap(
                                              children: [
                                                for (var result
                                                    in _resultsNotes)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        _openNoteScreen(result);
                                                      },
                                                      child: Container(
                                                        width: 300,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: palette[2],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: MarkdownWidget(
                                                            previewMode: true,
                                                            markdown: result[
                                                                'content'],
                                                          ),
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
