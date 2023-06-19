import 'package:flutter/material.dart';
import 'package:secondbrain/screens/main_screen.dart';
import 'package:secondbrain/screens/storage_edit.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      routes: {
        '/': (context) => StorageEdit(),
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
      body: MainScreen(),
    );
  }
}
