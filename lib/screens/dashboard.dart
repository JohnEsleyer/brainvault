import 'dart:io';

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
  bool _expandSubjects = false;

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
      print('Failed to refresh data: $e');
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

  Widget _addSubjectWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: _addNewSubject,
        child: Tooltip(
          message: 'Add subject',
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.white),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Container size
    double conWidth = MediaQuery.of(context).size.width * 0.90;

    return _expandSubjects
        ? Scaffold(
            body: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              color: palette[2],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: Platform.isAndroid,
                    child: SizedBox(height: 20),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _expandSubjects = false;
                            });
                          },
                          child: const Icon(
                            Icons.close,
                          ),
                        ),
                      ),
                     _addSubjectWidget(),
                    ],
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: _allSubjects,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors
                                      .white)); // Display a loading indicator while waiting for data.
                        } else if (snapshot.hasError) {
                          return const Text("Error fetching brain subjects");
                        } else {
                          // Handle the case when the future is complete and data is available.
                          if (snapshot.data != null) {
                            // Process the data and display it in the UI.
                            // ...
                            List<dynamic>? data = snapshot.data;

                            return Wrap(
                              children: [
                                for (var sub in data ?? [])
                                  GestureDetector(
                                    onTap: () async {
                                      int id = await sub['id'];
                                      await Navigator.of(context)
                                          .push(MaterialPageRoute(builder: (_) {
                                        return SubjectScreen(subjectId: id);
                                      }));
                                      _refreshData();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 100,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          color: palette[6],
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${sub['title']}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          } else {
                            return const Text("No brain subjects available.");
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: AppBar(
                title: const Text('BrainVault'),
                centerTitle: true,
                backgroundColor: palette[2],
                automaticallyImplyLeading: false,
                leading: GestureDetector(
                  onTap: () {
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
                                  child:
                                      Icon(Icons.search, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Subjects
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
                                const Text(
                                  "Subjects",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    // Expand subjects
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _expandSubjects = true;
                                        });
                                      },
                                      child: Tooltip(
                                        message: 'See all',
                                        child: const Icon(Icons.open_in_full),
                                      ),
                                    ),
                                    // Add new subject
                                    _addSubjectWidget(),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 130,
                              child: FutureBuilder(
                                future: _allSubjects,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator(
                                            color: Colors
                                                .white)); // Display a loading indicator while waiting for data.
                                  } else if (snapshot.hasError) {
                                    return const Text(
                                        "Error fetching brain subjects");
                                  } else {
                                    // Handle the case when the future is complete and data is available.
                                    if (snapshot.data != null) {
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
                                                    int id = await data?[index]
                                                        ['id'];
                                                    await Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                            builder: (_) {
                                                      return SubjectScreen(
                                                          subjectId: id);
                                                    }));
                                                    _refreshData();
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      height: 100,
                                                      width: 130,
                                                      decoration: BoxDecoration(
                                                        color: palette[6],
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    10)),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '${data?[index]['title']}',
                                                          style:
                                                              const TextStyle(
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
                                                const SizedBox(
                                                  width: 10,
                                                )
                                              ],
                                            );
                                          });
                                    } else {
                                      return const Text(
                                          "No brain subjects available.");
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Random Study Mode
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const Center(
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
