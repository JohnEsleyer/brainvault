import 'package:flutter/material.dart';
import 'package:secondbrain/screens/DesktopScreen.dart';
import 'package:secondbrain/screens/MobileScreen.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    home: SecondBrainApp(),
  ));
}

class SecondBrainApp extends StatefulWidget {
  @override
  _SecondBrainApp createState() => _SecondBrainApp();
}

class _SecondBrainApp extends State<SecondBrainApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          // Mobile
          return MobileScreen();
        } else {
          // Desktop
          return DesktopScreen();
        }
      }),
    );
  }
}
