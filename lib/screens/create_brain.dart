import 'dart:io';

import 'package:brainvault/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../colors.dart';

class CreateBrain extends StatefulWidget {
  @override
  _CreateBrainState createState() => _CreateBrainState();
}

class _CreateBrainState extends State<CreateBrain> {
  TextEditingController _controller = TextEditingController();
  DatabaseService _dbHelper = DatabaseService();
  Directory? _dir = null;

  void initState() {
    super.initState();
  }

  void _setFilename() {
     _dbHelper.setFilename(_controller.text + '.brain');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: palette[2],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: TextField(
                        onChanged: (value){
                          _setFilename();
                        },
                        controller: _controller,
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                          hintText: 'Type the name of the .brain file',
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () async {
                          await _dbHelper.openDirectoryPicker();
                          setState(() {
                            _dir = _dbHelper.getDirectory;
                          });
                        },
                        child: Icon(
                          Icons.folder_open,
                        ),
                      ),
                      Text("File Path: "),
                      Container(
                        width: MediaQuery.of(context).size.width - 122,
                          child:
                              Text(_dir != null ? _dir?.path as String : 'Press the folder icon to select a folder')),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Create button
                  GestureDetector(
                    onTap: (){
                      Navigator.popAndPushNamed(context, '/dashboard');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Create',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
