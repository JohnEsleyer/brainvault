import 'package:brainvault/screens/random_study_screen.dart';
import 'package:flutter/material.dart';

import 'package:brainvault/colors.dart';
import 'package:brainvault/screens/subject_screen.dart';
import 'package:brainvault/screens/search_screen.dart';

import '../services/database_service.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _dbHelper = DatabaseService();
  late Future<List<Map<String, dynamic>>> _allSubjects;

  @override
  void initState() {
    super.initState();
    _allSubjects = _dbHelper.getAllSubjects();
  }

  void _refreshData() async {
    try {
      Future<List<Map<String, dynamic>>> subjects = _dbHelper.getAllSubjects();
      // When succesfull
      setState(() {
        _allSubjects = subjects;
      });
    } catch (e) {
      print('Failed to refreshd data: $e');
    }
  }

  void _addNewSubject() async {
    var data = {
      'title': 'Untitled subject',
      'description':
          'This is the description of the subject. Press me to start editing.',
    };
    try {
      await _dbHelper.insertSubject(data);
    } catch (e) {
      print('Error while inserting a subject: $e');
    }
    _dbHelper.saveJSON();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    // Container size
    double conWidth = MediaQuery.of(context).size.width * 0.90;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          title: const Text('BrainVault'),
          centerTitle: true,
          backgroundColor: palette[2],
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: (){
              _dbHelper.closeDatabase();
              Navigator.popAndPushNamed(context, '/');
            },
            child: const Icon(
              Icons.logout,
            ),
          ),
        ),
      ),
      body: Container(
        color: palette[1],
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Column(
            children: [
              // Search
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ));
                },
                child: Hero(
                  tag: 'search',
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: palette[2],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: conWidth,
                      height: 50,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.search, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // subjects
              Container(
                width: conWidth,
                decoration: BoxDecoration(
                  color: palette[2],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                    right: 6.0,
                    left: 6.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "subjects",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: _addNewSubject,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  border: Border.all(color: Colors.white),
                                ),
                                child: Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 130,
                        child: FutureBuilder(
                          future: _allSubjects,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child: CircularProgressIndicator(
                                      color: Colors
                                          .white)); // Display a loading indicator while waiting for data.
                            } else if (snapshot.hasError) {
                              print(
                                  "Error fetching brain subjects: ${snapshot.error}");
                              return Text("Error fetching brain subjects");
                            } else {
                              // Handle the case when the future is complete and data is available.
                              if (snapshot.data != null) {
                                print(snapshot.data);
                                // Process the data and display it in the UI.
                                // ...
                                List<dynamic>? data = snapshot.data;

                                return ListView.builder(
                                    shrinkWrap: false,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: data?.length,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              int id = await data?[index]['id'];
                                              await Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (_) {
                                                return SubjectScreen(
                                                    subjectId: id);
                                              }));
                                              _refreshData();
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 100,
                                                width: 130,
                                                decoration: BoxDecoration(
                                                  color: palette[6],
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${data?[index]['title']}',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      );
                                    });
                              } else {
                                return Text("No brain subjects available.");
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Study Mode
              Padding(
                padding: EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RandomStudy(),
                      ),
                    );
                  },
                  child: Container(
                    width: conWidth,
                    height: 100,
                    decoration: BoxDecoration(
                      color: palette[6],
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.casino, color: Colors.black),
                          Text(
                            'Study Randomly',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
