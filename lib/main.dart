

import 'package:flutter/material.dart';


import 'package:secondbrain/screens/dashboard.dart';

import 'package:secondbrain/screens/main_screen.dart';
import 'package:secondbrain/widgets/custom_scroll_behavior.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart';

import 'screens/note_screen.dart';




void main() async {
  if (kIsWeb) {
    // Change default factory on the web
    databaseFactory = databaseFactoryFfiWeb;
  }
  
  runApp(
    MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,

      routes: {
        '/': (context) => MainScreen(),
        '/dashboard': (context) => Dashboard(),
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

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  String userString = '__';
  List<String> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(userString),
            ElevatedButton(onPressed: () async {
              print(users);
              var db = await openDatabase('brain.db', version: 1);
                 var temp = await db.query('users');

                for (var user in temp) {
                  print('User: ${user['id']}, ${user['name']}');
                  setState(() {
                    users.add(user['name'] as String);
                  });
                  
                }
            }, child: Text("Display all"),),
            ElevatedButton(
              child: Text("Press Me"),
              onPressed: () async {
                print('upload db file');

                print('db file uploaded');
                setState(() {
                  userString = 'uploaded';
                });
                var db = await openDatabase('brain.db', version: 1);
                 var temp = await db.query('users');

                for (var user in temp) {
                  print('User: ${user['name']}');
                }
              },
            ),
            ElevatedButton(onPressed: (){

            }, child: Text('Download DB'),),
            Column(children: [
              for (var i=0;i<users.length;i++)
                Text('User: ${users[i]}'),
            ],)
          ],
        ),
      ),
    );
  }
}
