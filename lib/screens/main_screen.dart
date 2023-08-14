import 'package:brainvault/screens/create_brain.dart';
import 'package:brainvault/screens/dashboard.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final dbHelper = DatabaseService();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 800) {
/////////////////////////// Portrait view ////////////////////////////////////
        return Scaffold(
          body: Container(
            width: double.infinity,
            color: Color.fromARGB(255, 25, 25, 25),
            child: Column(
              children: [
                Image.asset('assets/logo.png'),
                Text(
                  "BrainVault",
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
                Text(
                  "BrainVault is a software tool that acts as your personal knowledge base.",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 90),
                Container(
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await dbHelper.uploadAndInsertJsonData();
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Dashboard()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  color: Colors.black,
                                ),
                                Text(
                                  'Import .brain',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () async {
                          // dbHelper.openDirectoryPicker();
                          // dbHelper.clearDatabase();
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => CreateBrain()));
                        },
                        child:Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  color: Colors.black,
                                ),
                                Text(
                                  'Create new brain',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
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
      } else {
/////////////////////////// DESKTOP / WEB ////////////////////////////////////
        return Scaffold(
          body: Row(
            children: [
              Container(
                height: double.infinity,
                width: MediaQuery.of(context).size.width / 2,
                color: Color.fromARGB(237, 34, 34, 34),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/logo.png'),
                      Text(
                        "BrainVault",
                        style: TextStyle(
                          fontSize: 40,
                        ),
                      ),
                      Text(
                        "BrainVault is a software tool that acts as your personal knowledge base.",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                width: MediaQuery.of(context).size.width / 2,
                color: Color.fromARGB(255, 25, 25, 25),
                child: Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Open Brain button
                      GestureDetector(
                        onTap: () async {
                          try{
                            await dbHelper.uploadAndInsertJsonData();
                              Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Dashboard()));
                          }catch(e){
                            print('Failed to open file');
                          }
                        
                        },
                        child: Container(
                          child: Row(
                            children: [
                              Icon(Icons.folder_open),
                              Text('Import .brain'),
                            ],
                          ),
                        ),
                      ),

                      // Create New Brain button
                      GestureDetector(
                        onTap: () async {
                          

                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Dashboard()));
                        },
                        child: Row(
                          children: [
                            Icon(Icons.folder_open),
                            Text("Create new brain"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }
}

