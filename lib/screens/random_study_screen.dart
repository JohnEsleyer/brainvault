
import 'package:brainvault/colors.dart';
import 'package:brainvault/screens/document_screen.dart';
import 'package:brainvault/screens/note_screen.dart';
import 'package:flutter/material.dart';
  
import 'dart:math';

import '../services/database_service.dart';

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
      var docs = await dbHelper.getAllDocuments();
      var notes = await dbHelper.getAllNotes();
      
      // To improve performance, restrict elements to 50 of length only.
      if (docs.length > 50){
        docs = getRandom50Elements(docs);
      }
      if (notes.length > 50){
        notes = getRandom50Elements(notes);
      }
      _docsNNotes.addAll(docs);
      _docsNNotes.addAll(notes);
      _docsNNotes.shuffle();

      setState(() {
        _isLoading = false;
      });
    }catch(e){
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

Widget renderDocNNote(){
  if (_docsNNotes[index]['table_name'] == 'document'){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: palette[2],
      ),
      child: DocumentScreen(
        documentId: _docsNNotes[index]['id'],
      ),
    );
  }else{
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: palette[2],
      ),
      child: NoteScreen(
        readMode: true,
        noteId: _docsNNotes[index]['id'],
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // App bar
          Padding(
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
          // Body
          Container(
            height: MediaQuery.of(context).size.height * 0.82,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : renderDocNNote(),
          ),

          // Bottom bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: (){
                    if (index > _docsNNotes.length){
                      setState(() {
                        index = 0;
                      });
                    }
                    setState(() {
                      index++;
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
    );
  }
}
