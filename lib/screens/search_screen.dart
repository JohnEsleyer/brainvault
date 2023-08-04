import 'package:flutter/material.dart';
import 'package:brainvault/colors.dart';


class SearchScreen extends StatefulWidget{

  @override 
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        color: palette[1],
        child: Column(
          children: [
            Hero(
              tag: 'search',
              child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: palette[2],
                          borderRadius: BorderRadius.circular(10),),
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: 50,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.search, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}