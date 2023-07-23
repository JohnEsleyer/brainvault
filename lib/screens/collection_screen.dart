import 'package:flutter/material.dart';

class CollectionScreen extends StatefulWidget{
  int collectionId;

  CollectionScreen({required this.collectionId});

  @override 
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>{
  @override 
  Widget build(BuildContext context){
    
    return LayoutBuilder(builder: (context, constraints){
      if (constraints.maxWidth < 800) {
        // Mobile View
        return Scaffold(
          body: Container(
            child: Center(
              child: Text('jipwejfpwe'),
            ),
          ),
        );
      }else{
        // Desktop View
        return Scaffold();
      }
    });
  }
}