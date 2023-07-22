import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secondbrain/colors.dart';

import '../services/database_service.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final dbHelper = DatabaseService();

  // @override 
  // void initState(){
  //   super.initState();

  // }

  @override
  Widget build(BuildContext context) {

    // Container size
    double con_width = MediaQuery.of(context).size.width * 0.90;

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 800) {
        // Mobile
        return Scaffold(
          body: Container(
            color: palette[4],
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: con_width,
                    decoration: BoxDecoration(
                      color: palette[0],
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Collections", style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
                          Container(
                            height: 130,
                            child: FutureBuilder(
                              future: dbHelper.getAllCollections(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator(color: Colors.white)); // Display a loading indicator while waiting for data.
                                } else if (snapshot.hasError) {
                                  print(
                                      "Error fetching brain collections: ${snapshot.error}");
                                  return Text("Error fetching brain collections");
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
                                              Container(
                                                height: 100,
                                                width: 130,
                                                decoration: BoxDecoration(
                                                  color: palette[3],
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(10)),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                          '${data?[index]['title']}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                                ),
                                              ),
                                              SizedBox(width: 10,)
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
