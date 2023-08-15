

import 'package:flutter/material.dart';


import 'package:brainvault/screens/dashboard.dart';

import 'package:brainvault/screens/main_screen.dart';
import 'package:brainvault/widgets/custom_scroll_behavior.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';



void main() async {
  
  runApp(
    MaterialApp(
      theme: ThemeData(

        textTheme: ThemeData.dark().textTheme,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        scrollbarTheme: const ScrollbarThemeData(
          thumbColor: MaterialStatePropertyAll(Colors.white),
          trackColor:  MaterialStatePropertyAll(Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.white,
          ),
          hintStyle: TextStyle(
            color: Color.fromARGB(255, 139, 139, 139),
          ),
        ),
      ),
    
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
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          children: [
            Text(userString),
            ElevatedButton(onPressed: () async {

              var db = await openDatabase('brain.db', version: 1);
                 var temp = await db.query('users');

                for (var user in temp) {
                  setState(() {
                    users.add(user['name'] as String);
                  });
                  
                }
            }, child: const Text("Display all"),),
            ElevatedButton(
              child: const Text("Press Me"),
              onPressed: () async {
            
                setState(() {
                  userString = 'uploaded';
                });
                var db = await openDatabase('brain.db', version: 1);
                 var temp = await db.query('users');

              },
            ),
            ElevatedButton(onPressed: (){

            }, child: const Text('Download DB'),),
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

