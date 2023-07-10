import 'package:flutter/material.dart';
import 'package:secondbrain/screens/database_selector.dart';
import 'package:secondbrain/screens/main_screen.dart';
import 'package:secondbrain/screens/storage_edit.dart';

import 'screens/note_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      routes: {
        '/': (context) => SecondBrainApp(),
        '/selector': (context) => DatabaseSelector(),
      },
    ),
  );
}

class SecondBrainApp extends StatefulWidget {
  @override
  _SecondBrainApp createState() => _SecondBrainApp();
}

class _SecondBrainApp extends State<SecondBrainApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoteScreen(),
    );
  }
}


