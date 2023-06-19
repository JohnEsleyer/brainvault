import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 800) {
        // Mobile
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
                      Row(
                        children: [
                          Icon(Icons.folder_open),
                          Text("Open brain"),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.create_new_folder_outlined),
                          Text("Create new brain"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Desktop
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
                      Row(
                        children: [
                          Icon(Icons.folder_open),
                          Text("Open brain"),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.create_new_folder_outlined),
                          Text("Create new brain"),
                        ],
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
