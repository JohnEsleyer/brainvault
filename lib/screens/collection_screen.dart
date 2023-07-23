import 'package:flutter/material.dart';
import 'package:secondbrain/colors.dart';
import 'package:secondbrain/screens/document_screen.dart';
import 'package:secondbrain/services/database_service.dart';

class CollectionScreen extends StatefulWidget {
  final int collectionId;

  CollectionScreen({super.key, required this.collectionId});

  @override
  // ignore: library_private_types_in_public_api
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final dbHelper = DatabaseService();
  late List<Map<String, dynamic>> documents;
  late Map<String, dynamic> collection;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      collection = await dbHelper.getCollectionById(widget.collectionId);
      documents = await dbHelper.getDocumentsByCollectionId(widget.collectionId);

      // When successfull
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Loading Data Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          // Mobile View
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {},
              backgroundColor: palette[5],
            ),
            body: Container(
                width: MediaQuery.of(context).size.width,
                color: palette[1],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        collection['title'],
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Description and other buttons
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            collection['description'],
                          ),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: Colors.white),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.edit, color: Colors.white),
                              )),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Wrap(
                            children: [
                              for (var document in documents)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => DocumentScreen(documentId: document['id']),
                                    ));
                                  },
                                  child: Container(
                                    height: 100,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: palette[2],
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: Center(child: Text(document['title'])),
                                  ),
                                ),
                              ),
                            
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          );
        } else {
          // Desktop View
          return Scaffold();
        }
      });
    } else {
      return Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
  }
}
