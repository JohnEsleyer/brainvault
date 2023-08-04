

import 'dart:io';

import 'package:flutter/material.dart';


import 'package:brainvault/screens/dashboard.dart';

import 'package:brainvault/screens/main_screen.dart';
import 'package:brainvault/widgets/custom_scroll_behavior.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';



void main() async {
  
  if (Platform.isWindows || Platform.isLinux){
    sqfliteFfiInit();
  }
  databaseFactory = databaseFactoryFfi;
  
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,

      routes: {
        '/': (context) => MainScreen(),
        '/dashboard': (context) => Dashboard(),
      },
    ),
  );
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
