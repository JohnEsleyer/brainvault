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
                              MaterialPageRoute(builder: (context) => Test()));
                        },
                        child: Row(
                          children: [
                            Icon(Icons.folder_open),
                            Text("Open brain"),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          dbHelper.openDirectoryPicker();
                          // dbHelper.clearDatabase();
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Test()));
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

                          await dbHelper.uploadAndInsertJsonData();
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Test()));
                        },
                        child: Row(
                          children: [
                            Icon(Icons.folder_open),
                            Text("Open brain"),
                          ],
                        ),
                      ),

                      // Create New Brain button
                      GestureDetector(
                        onTap: () async {

                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Test()));
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

//// TEMP
class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  String userString = '__';
  List<String> subjectList = [];
  final dbHelper = DatabaseService();
  int count = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(userString),
            ElevatedButton(
              onPressed: () async {
                try {
                  List<Map<String, dynamic>> subjects =
                      await dbHelper.getAllSubjects();
                  if (subjects.isNotEmpty) {
                    // Display the retrieved brain subjects
                    print('Brain subjects:');
                    setState(() {
                      for (var subject in subjects) {
                        subjectList.add(subject['title']);
                      }
                    });
                  } else {
                    print('No subjects found.');
                  }
                } catch (e) {
                  print('Error while getting subjects: $e');
                }
              },
              child: Text("Display all"),
            ),
            ElevatedButton(
              child: Text("Insert subject"),
              onPressed: () async {
                var data = {
                  'title': 'Sample subject',
                  'description': 'This is a sample brain subject.',
                
                };
                try {
                  await dbHelper.insertSubject(data);
                } catch (e) {
                  print('Error while inserting a subject: $e');
                }
              },
            ),
            ElevatedButton(
              onPressed: () async {
                var data = {
                  'subject_id': 2,
                  'title': 'Sample topic',
                  'position': count,
                  'created_at': DateTime.now().toIso8601String(),
                  'last_reviewed': DateTime.now().toIso8601String(),
                  'next_review': DateTime.now().toIso8601String(), 
                  'spaced_repetition_level': 0,
                };

                try{
                  await dbHelper.insertTopic(data);
                  setState(() {
                    count++;
                  });
                }catch(e){
                  print('Error inserting topic: $e');
                }
              },
              child: Text('Insert topic'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popAndPushNamed('/dashboard');
              },
              child: Text('Dashboard'),
            ),
            Column(
              children: [
                for (var i = 0; i < subjectList.length; i++)
                  Text('Title: ${subjectList[i]}'),
              ],
            ),
            // ElevatedButton(onPressed: (){
            //   dbHelper.generateAndDownloadJsonFile();
            // }, child: Text('Download brain'))
          ],
        ),
      ),
    );
  }
}
