import 'package:flutter/material.dart';


class DatabaseSelector extends StatefulWidget{

  @override 
  _DatabaseSelectorState createState() => _DatabaseSelectorState();
}

class _DatabaseSelectorState extends State<DatabaseSelector>{
  
  @override
  Widget build(BuildContext context){

    // Container size
    double con_width = MediaQuery.of(context).size.width * 0.80;

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
                    height: 120,
                    width: con_width,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(237, 34, 34, 34),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Text("Database Name 1"),
                       ),
                     ],
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