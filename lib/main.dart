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
  Widget build(BuildContext context) {
    
    return Column(
      children: [
        Container(
          height: 100,
          child: TextField(
            expands: true,
            minLines: null,
            maxLines: null,
            onChanged: (String data){
              setState(() {
                inputString = data;
              });
            },
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.70,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MarkdownWidget(
              data: inputString,
              styleConfig: StyleConfig(markdownTheme: MarkdownTheme.darkTheme),
            ),
          ),
        ),
      ],
    );
  }
}
