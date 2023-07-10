import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

import 'package:secondbrain/screens/database_selector.dart';

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

class Temp extends StatefulWidget {
  @override
  _TempState createState() => _TempState();
}

class _TempState extends State<Temp>{

  String inputString = '# Hello';

  @override
  Widget build(BuildContext context){
    return Image.network('https://images7.alphacoders.com/131/1316242.jpg');
  }
}
