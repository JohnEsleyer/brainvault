import 'package:brainvault/screens/document_screen.dart';
import 'package:brainvault/screens/note_screen.dart';
import 'package:brainvault/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:brainvault/colors.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  void _onSearchTextChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    DatabaseService databaseService = DatabaseService();
    List<Map<String, dynamic>> results =
        await databaseService.searchDocumentsAndNotes(query);

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
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
                            onChanged: _onSearchTextChanged,
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
            Expanded(
              // Wrap the ListView.builder with Expanded
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> result = _searchResults[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _searchResults[index]['table_name'] == 'document'
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return DocumentScreen(
                                      documentId: _searchResults[index]['id'],
                                      studyMode: false);
                                }));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: palette[2],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.edit_document),
                                    ),
                                    Text(result['title']),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : NoteScreen(
                            noteId: _searchResults[index]['id'],
                            readMode: true,
                            studyMode: true,
                            content: _searchResults[index]['content'],
                            type: _searchResults[index]['type'],
                            func: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DocumentScreen(
                                      documentId: _searchResults[index]
                                          ['document_id'],
                                      studyMode: false)));
                            },
                          ),
                  );

                  // return ListTile(
                  //   title:
                  //       Text(result['title'] ?? result['content'] ?? 'Unknown'),
                  //   // Add more widgets to display additional information if needed
                  // );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
