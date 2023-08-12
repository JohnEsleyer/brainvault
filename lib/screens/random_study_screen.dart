import 'package:flutter/material.dart';

import 'dart:math';

import '../services/database_service.dart';
import '../widgets/study_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    print(_notes);
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Study(
      notes: _notes,
    );
  }
}
