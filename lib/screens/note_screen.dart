
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:markdown/markdown.dart' as md;


class NoteScreen extends StatefulWidget{
  @override 
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen>{
  String dropdownValue = "Markdown";
  String inputString = '';
  bool isEmpty = true;
  
  var codeTheme = {
    'root':
      TextStyle(backgroundColor: Color.fromARGB(237, 34, 34, 34), color: Color(0xffbababa)),
  'strong': TextStyle(color: Color(0xffa8a8a2)),
  'emphasis': TextStyle(color: Color(0xffa8a8a2), fontStyle: FontStyle.italic),
  'bullet': TextStyle(color: Color(0xff6896ba)),
  'quote': TextStyle(color: Color(0xff6896ba)),
  'link': TextStyle(color: Color(0xff6896ba)),
  'number': TextStyle(color: Color(0xff6896ba)),
  'regexp': TextStyle(color: Color(0xff6896ba)),
  'literal': TextStyle(color: Color(0xff6896ba)),
  'code': TextStyle(color: Color(0xffa6e22e)),
  'selector-class': TextStyle(color: Color(0xffa6e22e)),
  'keyword': TextStyle(color: Color(0xffcb7832)),
  'selector-tag': TextStyle(color: Color(0xffcb7832)),
  'section': TextStyle(color: Color(0xffcb7832)),
  'attribute': TextStyle(color: Color(0xffcb7832)),
  'name': TextStyle(color: Color(0xffcb7832)),
  'variable': TextStyle(color: Color(0xffcb7832)),
  'params': TextStyle(color: Color(0xffb9b9b9)),
  'string': TextStyle(color: Color(0xff6a8759)),
  'subst': TextStyle(color: Color(0xffe0c46c)),
  'type': TextStyle(color: Color(0xffe0c46c)),
  'built_in': TextStyle(color: Color(0xffe0c46c)),
  'builtin-name': TextStyle(color: Color(0xffe0c46c)),
  'symbol': TextStyle(color: Color(0xffe0c46c)),
  'selector-id': TextStyle(color: Color(0xffe0c46c)),
  'selector-attr': TextStyle(color: Color(0xffe0c46c)),
  'selector-pseudo': TextStyle(color: Color(0xffe0c46c)),
  'template-tag': TextStyle(color: Color(0xffe0c46c)),
  'template-variable': TextStyle(color: Color(0xffe0c46c)),
  'addition': TextStyle(color: Color(0xffe0c46c)),
  'comment': TextStyle(color: Color(0xff7f7f7f)),
  'deletion': TextStyle(color: Color(0xff7f7f7f)),
  'meta': TextStyle(color: Color(0xff7f7f7f)),
  };
  var items = [    
    'Markdown',
    'HTML',
    'Code',
  ];

  Widget displayNote(){
    if (dropdownValue == "Markdown" || dropdownValue == "HTML"){
      return  HtmlWidget(
                      inputString,
                    );
    }else{
      return HighlightView(
        inputString,
        language: 'dart',
        theme: codeTheme,
      );
    }
  }

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
                    if (value != ''){
                      setState(() {
                        isEmpty = false;
                      if (dropdownValue == "Markdown"){
                        inputString = md.markdownToHtml(value);
                      }else{
                        inputString = value;
                      }
                    });
                    }else{
                      setState(() {
                        isEmpty = true;
                      });
                    }
                    
                  },
                ),
              ),
            ],
          ),
        ),
        
        !isEmpty ? SingleChildScrollView(
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
                    child: displayNote(),
                  ),
                ),
              ),
            ],
          ),
        ) : Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.46,
                  
                  decoration: BoxDecoration(
                              color: Color.fromARGB(237, 34, 34, 34),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Write something.'),
                  ),
                ),
              ),
      ],
    );
  }
}
