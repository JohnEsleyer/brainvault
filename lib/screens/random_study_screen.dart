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
      // Convert the immutable notes list to a mutable list
      _notes = List<Map<String, dynamic>>.from(notes);

      _notes.shuffle();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load data: $e');
    }
  }

  List<T> getRandom50Elements<T>(List<T> list) {
    final random = Random();
    var originalList = List<T>.from(list); // Create a copy of the input list
    var _randomList = <T>[];

    for (var i = 0; i < 50; i++) {
      var index = random.nextInt(originalList.length - i);
      _randomList.add(originalList[index]);
      originalList.removeAt(index); // Remove from the copy, not the input list
    }

    return _randomList;
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }
    return Study(
      notes: _notes,
    );
  }
}
