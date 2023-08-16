

import 'package:flutter/material.dart';


import 'package:brainvault/screens/dashboard.dart';

import 'package:brainvault/screens/main_screen.dart';
import 'package:brainvault/widgets/custom_scroll_behavior.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';



void main() async {
  

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
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



