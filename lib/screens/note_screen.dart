import 'package:brainvault/widgets/markdown_widget.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../services/database_service.dart';

class NoteScreen extends StatefulWidget {
  final bool readMode;
  final String content;
  final int noteId;
  final String type; // Flash card note type or not and other future types

  NoteScreen(
      {required this.readMode,
      required this.content,
      required this.noteId,
      required this.type});

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  TextEditingController _editingController = TextEditingController();
  final DatabaseService _dbHelper = DatabaseService();
  late bool _editMode;

  void initState() {
    if (widget.readMode == true) {
      _editMode = false;
      _editingController.text = widget.content;
    } else {
      _editMode = true;
      _editingController.text = widget.content;
    }
  }

  void _updateDb() {
    _dbHelper.updateNoteContent(widget.noteId, _editingController.text);
  }

  Widget _display() {
    if (_editMode == true) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: palette[2],
            child: TextField(
              cursorColor: Colors.white,
              decoration: InputDecoration(
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              expands: true,
              maxLines: null,
              minLines: null,
              controller: _editingController,
              onChanged: (value) {
                _updateDb();
              },
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: palette[2],
        width: MediaQuery.of(context).size.width,
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: MarkdownWidget(
            markdown: _editingController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette[1],
      child: Column(
        children: [
           GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              print(_editMode);
              setState(() {
                _editMode = !_editMode;
              });
            },
            child: Text('Change'),
          ),
          _display(),
        ],
      ),
    );
  }
}
