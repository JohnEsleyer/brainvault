import 'package:flutter/material.dart';

import 'package:secondbrain/colors.dart';
import 'package:secondbrain/screens/collection_screen.dart';

import '../services/database_service.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final dbHelper = DatabaseService();
  late Future<List<Map<String, dynamic>>> allCollections;
  
  @override
  void initState() {
    super.initState();
    allCollections = dbHelper.getAllCollections();
  }

  void refreshData() async {
    try{
      Future<List<Map<String, dynamic>>> collections = dbHelper.getAllCollections();
      // When succesfull
      setState(() {
        allCollections = collections;
      });
    }catch(e){
      print('Failed to refreshd data: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    // Container size
    double con_width = MediaQuery.of(context).size.width * 0.90;

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 800) {
        // Mobile
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: AppBar(
              title: Text('Second-Brain'),
              centerTitle: true,
              backgroundColor: palette[2],
              automaticallyImplyLeading: false,
            ),
          ),
          body: Container(
            color: palette[1],
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: con_width,
                    decoration: BoxDecoration(
                      color: palette[5],
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Collections",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          Container(
                            height: 130,
                            child: FutureBuilder(
                              future: allCollections,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator(
                                          color: Colors
                                              .white)); // Display a loading indicator while waiting for data.
                                } else if (snapshot.hasError) {
                                  print(
                                      "Error fetching brain collections: ${snapshot.error}");
                                  return Text(
                                      "Error fetching brain collections");
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
                                                  await Navigator.of(context).push(MaterialPageRoute(
                                                    builder: (_){
                                                      return CollectionScreen(collectionId: id);
                                                    }
                                                  ));
                                                  refreshData();
                                                },
                                                child: Container(
                                                  height: 100,
                                                  width: 130,
                                                  decoration: BoxDecoration(
                                                    color: palette[4],
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
                                              SizedBox(
                                                width: 10,
                                              )
                                            ],
                                          );
                                        });
                                  } else {
                                    return Text(
                                        "No brain collections available.");
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // Desktop
        return Scaffold(
          body: Container(),
        );
      }
    });
  }
}
