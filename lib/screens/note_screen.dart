import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:brainvault/functions.dart';
import 'package:tex_markdown/tex_markdown.dart';

import '../colors.dart';
import '../services/database_service.dart';

class NoteScreen extends StatefulWidget {
  final int noteId;
  final bool readMode;
  final Function? onDelete;
  final String? content; // used only when readMode is true
  final String? type; // used only when readMode is true
  NoteScreen(
      {required this.noteId,
      required this.readMode,
      this.onDelete,
      this.content,
      this.type});

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  // Initialize database helper
  final dbHelper = DatabaseService();

  // Dropdown value
  String dropdownValue = "Markdown";

  // Input data obtained from the Editor section used by the renderer component
  String inputString = '';

  // TextField input controller
  TextEditingController inputController = TextEditingController();

  // Checks if editor or widget.content is empty
  late bool isEmpty;

  // flag for image mode
  bool imageMode = false;

  // Image URL
  String imageUrl = '';

  // Note data
  late Map<String, dynamic> note;

  List<Color> deleteColor = [Colors.white30, Color.fromARGB(255, 43, 43, 43)];

  var codeTheme = {
    'root': TextStyle(
        backgroundColor: Color.fromARGB(237, 34, 34, 34),
        color: Color(0xffbababa)),
    'strong': TextStyle(color: Color(0xffa8a8a2)),
    'emphasis':
        TextStyle(color: Color(0xffa8a8a2), fontStyle: FontStyle.italic),
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
    'Image + Markdown',
  ];

  @override
  void initState() {
    super.initState();
    // If the given widget.content is empty or null set isEmpty to true
    isEmpty = widget.content == '' || widget.content == null;

    loadData();
  }

  Widget render() {
    // If user selected 'HTML' option
    if (dropdownValue == 'HTML') {
      return HtmlWidget(
        inputString,
      );
    }
    // If user selected 'Markdown' option
    else if (dropdownValue == 'Markdown') {
      return TexMarkdown(
        inputString,
      );
    }
    // If user selected 'Code' option
    else if (dropdownValue == 'Code') {
      return HighlightView(
        inputString,
        language: 'dart',
        theme: codeTheme,
      );
    }
    // If user selected 'Image' option
    else if (dropdownValue == 'Image + Markdown') {
      // Check if Input String is URL or not
      if (isUrl(imageUrl)) {
        return Column(
          children: [
            Image.network(
              imageUrl,
              errorBuilder: (context, error, stackTrace) {
                return const Text("Invalid URL");
              },
            ),
            TexMarkdown(
              inputString,
            ),
          ],
        );
      } else {
        return const Text("Invalid URL");
      }
    }

    return Container();
  }

  void loadData() async {
    // READ MODE
    if (widget.readMode == true) {
      // Initialize inputString and dropdownValue in read mode.
      inputString = widget.content ?? '';
      dropdownValue = widget.type ?? 'Markdown';

      if (widget.type == "Image + Markdown") {
        // Image + Markdown type has a JSON content that needs to be parsed
        Map<String, dynamic> data = jsonDecode(widget.content ?? '');

        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            inputString = data['content'];
            dropdownValue = widget.type ?? 'Markdown';
            inputController.text = data['content'];
            imageUrl = data['imageUrl'];
          });
        }
      } else {
        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            inputString = widget.content ?? '';
            dropdownValue = widget.type ?? 'Markdown';
            inputController.text = widget.content ?? '';
            
          });
        }
      }

      if (inputController.text.length > 0) {
        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            isEmpty = false;
          });
        }
      }

      // EDIT MODE
    } else {
      note = await dbHelper.getNoteById(widget.noteId);

      if (note['type'] == "Image + Markdown") {
        // Image + Markdown type has a JSON content that needs to be parsed
        Map<String, dynamic> data = jsonDecode(note['content']);

        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            inputString = data['content'];
            inputController.text = data['content'];
            dropdownValue = note['type'];
            imageUrl = data['imageUrl'];
          });
        }
      } else {
        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            inputString = note['content'];
            inputController.text = note['content'];
            dropdownValue = note['type'];
          });
        }
      }

      if (inputController.text.length > 0) {
        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            isEmpty = false;
          });
        }
      }
    }
  }

  void updateData() async {
    setState(() {
      // This will allow the renderer component to be rerender when TextField changes.
      inputString = inputController.text;
    });

    if (dropdownValue == "Image + Markdown") {
      // Creating JSON
      Map<String, dynamic> data = {
        'content': inputString,
        'imageUrl': imageUrl,
      };
      String jsonString = jsonEncode(data);
      dbHelper.updateNoteContent(widget.noteId, jsonString);
    } else {
      await dbHelper.updateNoteContent(widget.noteId, inputController.text);
    }

    await dbHelper.updateNoteType(widget.noteId, dropdownValue);
  }

  Future<void> deleteNote(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          backgroundColor: palette[1],
          title: const Text('Delete this note?'),
          content: const Text(
            'This cannot be undone.',
            style: TextStyle(fontSize: 15),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await dbHelper.deleteNote(widget.noteId);
                Navigator.of(context).pop();
                widget.onDelete?.call();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: toHeroContext.widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.readMode) {
      // READING MODE

      return Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.02,
          top: 5,
          bottom: 5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  dropdownValue,
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 10,
                  ),
                ),
                Text(
                  ' | ',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 10,
                  ),
                ),
                MouseRegion(
                  onHover: (event) {
                    setState(() {
                      deleteColor = [Colors.red, Colors.red];
                    });
                  },
                  onExit: (event) {
                    setState(() {
                      deleteColor = [
                        Colors.white30,
                        Color.fromARGB(255, 43, 43, 43)
                      ];
                    });
                  },
                  child: GestureDetector(
                    onTap: () {
                      deleteNote(context);
                    },
                    child: Row(
                      children: [
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: deleteColor[0],
                            fontSize: 10,
                          ),
                        ),
                        Icon(
                          Icons.delete_forever,
                          color: deleteColor[1],
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Hero(
              flightShuttleBuilder: _flightShuttleBuilder,
              tag: 'note-${widget.noteId}',
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: palette[2],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.02),
                  child: isEmpty
                      ? Text('This note is empty. Press me to open the editor.')
                      : render(),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            // Editor section
            Container(
              decoration: BoxDecoration(
                color: palette[2],
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
                              items: items.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownValue = newValue!;
                                  if (dropdownValue == 'Image + Markdown') {
                                    imageMode = true;
                                  } else {
                                    imageMode = false;
                                  }
                                });
                                // Scaffold.of(context).build(context);
                              }),
                        ],
                      ),
                    ),
                  ),
                  !imageMode
                      ?
                      // If Image mode is false
                      Container(
                          width: MediaQuery.of(context).size.width * 0.50,
                          height: MediaQuery.of(context).size.height - 40,
                          child: TextField(
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              hintText: 'Type something...',
                              hoverColor: Colors.white,
                              focusColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            expands: true,
                            maxLines: null,
                            minLines: null,
                            controller: inputController,
                            onChanged: (String value) {
                              if (value != '') {
                                setState(() {
                                  isEmpty = false;
                                });
                              } else {
                                setState(() {
                                  isEmpty = true;
                                });
                              }
                              updateData();
                            },
                          ),
                        )
                      :
                      // If Image mode is true
                      Container(
                          width: MediaQuery.of(context).size.width * 0.50,
                          height: MediaQuery.of(context).size.height - 40,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                // Ask Image URL
                                Column(
                              children: [
                                TextField(
                                  cursorColor: Colors.white,
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    hintText: 'Enter image URL',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  expands: false,
                                  minLines: 1,
                                  onChanged: (String value) {
                                    if (value != '') {
                                      setState(() {
                                        isEmpty = false;

                                        imageUrl = value;
                                      });
                                    } else {
                                      setState(() {
                                        isEmpty = true;
                                      });
                                    }
                                  },
                                ),

                                // Image Description
                                SizedBox(height: 15),
                                Expanded(
                                  child: TextField(
                                    cursorColor: Colors.white,
                                    decoration: const InputDecoration(
                                      isCollapsed: true,
                                      hintText: 'Type something...',
                                      hoverColor: Colors.white,
                                      focusColor: Colors.white,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    expands: true,
                                    maxLines: null,
                                    minLines: null,
                                    controller: inputController,
                                    onChanged: (String value) {
                                      if (value != '') {
                                        setState(() {
                                          isEmpty = false;
                                        });
                                      } else {
                                        setState(() {
                                          isEmpty = true;
                                        });
                                      }
                                      updateData();
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

            // Renderer Component
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.02),
                    child: Hero(
                      flightShuttleBuilder: _flightShuttleBuilder,
                      tag: 'note-${widget.noteId}',
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.46,
                        decoration: BoxDecoration(
                          color: palette[2],
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: !isEmpty
                              ? render()
                              : Text('Write something on the editor.'),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                          color: palette[5],
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: Text(
                            'Go Back',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: palette[1],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
