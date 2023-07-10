import 'package:flutter/material.dart';
import 'package:secondbrain/screens/database_selector.dart';
import 'package:secondbrain/screens/main_screen.dart';
import 'package:secondbrain/screens/storage_edit.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:markdown/markdown.dart' as md;

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      routes: {
        '/': (context) => SecondBrainApp(),
        '/selector': (context) => DatabaseSelector(),
      },
    ),
  );
}

class SecondBrainApp extends StatefulWidget {
  @override
  _SecondBrainApp createState() => _SecondBrainApp();
}

class _SecondBrainApp extends State<SecondBrainApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoteWidget(),
    );
  }
}

class NoteWidget extends StatefulWidget{
  @override 
  _NoteWidgetState createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget>{
  String dropdownValue = "Markdown";
  String htmlString = "";
  var items = [    
    'Markdown',
    'HTML',
  ];

  @override 
  Widget build(BuildContext context){
    
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 37, 37, 37),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Container(
                  height: 40,
                  child: Row(
                    children: [
                      DropdownButton(
                        value: dropdownValue,
                        items: items.map((String items){
                          return DropdownMenuItem(
                            value: items, 
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged:(String? newValue){
                          setState(() {
                            dropdownValue = newValue!;
                          });
                          Scaffold.of(context).build(context);
                        }),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.50,
                height: MediaQuery.of(context).size.height - 40,
                child: TextField(
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  onChanged: (String value){
                    setState(() {
                      if (dropdownValue == "Markdown"){
                        htmlString = md.markdownToHtml(value);
                      }else{
                        htmlString = value;
                      }                      
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.46,
                  
                  decoration: BoxDecoration(
                              color: Color.fromARGB(237, 34, 34, 34),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HtmlWidget(
                      htmlString,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
