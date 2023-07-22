import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secondbrain/functions.dart';
import '../providers/brain_provider.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    // Brain provider
    var brainProvider = Provider.of<BrainProvider>(context);
    brainProvider.initialize();

    // Container size
    double con_width = MediaQuery.of(context).size.width * 0.90;

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 800) {
        // Mobile
        return Scaffold(
          body: Container(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: con_width,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(237, 34, 34, 34),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Collections", style: TextStyle(fontSize: 30)),
                          Container(
                            height: 130,
                            child: FutureBuilder(
                              future: brainProvider.getBrainCollections(),
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
                                                  color: const Color.fromARGB(255, 49, 49, 49),
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(10)),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                          '${data?[index]['title']}'),
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
