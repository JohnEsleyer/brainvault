import 'package:brainvault/screens/create_brain.dart';

import 'package:flutter/material.dart';

import '../services/database_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final dbHelper = DatabaseService();

  @override
  void initState() {
    super.initState();
  }

  void _importBrain() async {
    bool isSuccessful = await dbHelper.uploadAndInsertJsonData();
    if (isSuccessful) {
      Navigator.of(context).popAndPushNamed('/dashboard');
    }
  }

  @override 
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 800) {
/////////////////////////// Portrait view ////////////////////////////////////
        return Scaffold(
          body: Container(
            width: double.infinity,
            color: const Color.fromARGB(255, 25, 25, 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "BrainVault",
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
       
                const SizedBox(height: 90),
                SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _importBrain,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
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
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () async {
                          // dbHelper.openDirectoryPicker();
                          // dbHelper.clearDatabase();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CreateBrain()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add,
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
/////////////////////////// LANDSCAPE VIEW ////////////////////////////////////
        return Scaffold(
          body: Row(
            children: [
              Container(
                height: double.infinity,
                width: MediaQuery.of(context).size.width / 2,
                color: Color.fromARGB(237, 34, 34, 34),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "BrainVault",
                        style: TextStyle(
                          fontSize: 40,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                width: MediaQuery.of(context).size.width / 2,
                color: const Color.fromARGB(255, 25, 25, 25),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Import brain
                      GestureDetector(
                        onTap: _importBrain,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
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
                      ),

                      // Create new brain
                      GestureDetector(
                        onTap: () async {

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CreateBrain()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
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
