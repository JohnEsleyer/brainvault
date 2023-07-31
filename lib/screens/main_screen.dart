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
/////////////////////////// MOBILE ////////////////////////////////////
        return Scaffold(
          body: Container(
            width: double.infinity,
            color: Color.fromARGB(255, 25, 25, 25),
            child: Column(
              children: [
                Image.asset('assets/logo.png'),
                Text(
                  "Second Brain",
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
                Text(
                  "Second Brain is a software tool that acts as your personal knowledge base.",
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
                          await dbHelper.clearDatabase();
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
                        "Second Brain",
                        style: TextStyle(
                          fontSize: 40,
                        ),
                      ),
                      Text(
                        "Second Brain is a software tool that acts as your personal knowledge base.",
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
                      GestureDetector(
                        onTap: () async {
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
  List<String> collectionList = [];
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
                  List<Map<String, dynamic>> collections =
                      await dbHelper.getAllCollections();
                  if (collections.isNotEmpty) {
                    // Display the retrieved brain collections
                    print('Brain Collections:');
                    setState(() {
                      for (var collection in collections) {
                        collectionList.add(collection['title']);
                      }
                    });
                  } else {
                    print('No collections found.');
                  }
                } catch (e) {
                  print('Error while getting collections: $e');
                }
              },
              child: Text("Display all"),
            ),
            ElevatedButton(
              child: Text("Insert Collection"),
              onPressed: () async {
                var data = {
                  'title': 'Sample Collection',
                  'description': 'This is a sample brain collection.',
                  'created_at': DateTime.now().toIso8601String(),
                };
                try {
                  await dbHelper.insertCollection(data);
                } catch (e) {
                  print('Error while inserting a collection: $e');
                }
              },
            ),
            ElevatedButton(
              onPressed: () async {
                var data = {
                  'collection_id': 2,
                  'title': 'Sample Document',
                  'position': count,
                  'created_at': DateTime.now().toIso8601String(),
                  'last_reviewed': DateTime.now().toIso8601String(),
                  'next_review': DateTime.now().toIso8601String(), 
                  'spaced_repetition_level': 0,
                };

                try{
                  await dbHelper.insertDocument(data);
                  setState(() {
                    count++;
                  });
                }catch(e){
                  print('Error inserting document: $e');
                }
              },
              child: Text('Insert document'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popAndPushNamed('/dashboard');
              },
              child: Text('Dashboard'),
            ),
            Column(
              children: [
                for (var i = 0; i < collectionList.length; i++)
                  Text('Title: ${collectionList[i]}'),
              ],
            ),
            ElevatedButton(onPressed: (){
              dbHelper.generateAndDownloadJsonFile();
            }, child: Text('Download brain'))
          ],
        ),
      ),
    );
  }
}
