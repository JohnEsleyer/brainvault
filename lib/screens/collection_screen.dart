import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';

class CollectionScreen extends StatefulWidget{
  int collectionId;

  CollectionScreen({required this.collectionId});

  @override 
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>{
  @override 
  Widget build(BuildContext context){
    
    return Scaffold(
      body: Container(
        
        child: Column(
          
        )
      ),
    );
  }
}