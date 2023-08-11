import 'package:flutter/material.dart';

class MarkdownWidget extends StatefulWidget {
  final String markdown;

  const MarkdownWidget({required this.markdown});

  @override
  _MarkdownWidgetState createState() => _MarkdownWidgetState();
}

class _MarkdownWidgetState extends State<MarkdownWidget> {
  List<Widget> _rendered = [];
  List<List<Widget>> _flashcardWidgets = [[]];
  bool _isFlashcard = false;

  @override
  void initState() {
    super.initState();
    _parseMarkdown();
  }

  void _parseMarkdown() {
    List<String> lines = widget.markdown.split('\n');

    for (String line in lines) {
      print(line);
      if (line.startsWith('# ')) {
        // Header
        if (!_isFlashcard) {
          _rendered.add(
            Text(
              line.substring(2),
              style: TextStyle(
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          );
        } else {
          _flashcardWidgets[_flashcardWidgets.length > 0
                  ? _flashcardWidgets.length - 1
                  : 0]
              .add(
            Text(
              line.substring(2),
              style: TextStyle(
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.black,
              ),
            ),
          );
        }
      } else if (line.startsWith('## ')) {
        // Subheader

        if (!_isFlashcard) {
          _rendered.add(
            Text(
              line.substring(3),
              style: TextStyle(
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.white,
              ),
            ),
          );
        } else {
          _flashcardWidgets[_flashcardWidgets.length > 0
                  ? _flashcardWidgets.length - 1
                  : 0]
              .add(
            Text(
              line.substring(3),
              style: TextStyle(
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.black,
              ),
            ),
          );
        }
      } else if (line.startsWith('### ')) {
        // Subheader 2
        if (!_isFlashcard) {
          _rendered.add(
            Text(
              line.substring(4),
              style: TextStyle(
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          );
        } else {
          _flashcardWidgets[_flashcardWidgets.length > 0
                  ? _flashcardWidgets.length - 1
                  : 0]
              .add(
            Text(
              line.substring(4),
              style: TextStyle(
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black,
              ),
            ),
          );
        }
      } else if (line.startsWith('- ')) {
        // Bullet

        if (!_isFlashcard) {
          _rendered.add(Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Icon(
                  Icons.circle,
                  size: 10,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  line.substring(2),
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ));
        } else {
          _flashcardWidgets[_flashcardWidgets.length > 0
                  ? _flashcardWidgets.length - 1
                  : 0]
              .add(Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Icon(
                  Icons.circle,
                  size: 10,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  line.substring(2),
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ));
        }
      } else if (line.startsWith('**') && line.endsWith('**')) {
        // Bold
        if (!_isFlashcard) {
          _rendered.add(Text(
            line.substring(2, line.length - 2),
            style: TextStyle(
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ));
        } else {
          _flashcardWidgets[_flashcardWidgets.length > 0
                  ? _flashcardWidgets.length - 1
                  : 0]
              .add(Text(
            line.substring(2, line.length - 2),
            style: TextStyle(
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
          ));
        }
      } else if (line.startsWith('_') && line.endsWith('_')) {
        // Italic
        if (!_isFlashcard) {
          _rendered.add(Text(
            line.substring(1, line.length - 1),
            style: TextStyle(
              decoration: TextDecoration.none,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.normal,
              color: Colors.white,
              fontSize: 16,
            ),
          ));
        } else {
          _flashcardWidgets[_flashcardWidgets.length > 0
                  ? _flashcardWidgets.length - 1
                  : 0]
              .add(Text(
            line.substring(1, line.length - 1),
            style: TextStyle(
              decoration: TextDecoration.none,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: 16,
            ),
          ));
        }
      } else if (line.startsWith('![') && line.endsWith(')')) {
        // Image with URL
        RegExp regex = RegExp(r'!\[.*\]\((.*?)\)');
        Match? match = regex.firstMatch(line);
        if (match != null && match.groupCount == 1) {
          String imageUrl = match.group(1) ?? '';
          if (imageUrl.isNotEmpty) {
            if (!_isFlashcard) {
              _rendered.add(Center(
                child: Container(
                  height: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                    ),
                  ),
                ),
              ));
            } else {
              _flashcardWidgets[_flashcardWidgets.length > 0
                      ? _flashcardWidgets.length - 1
                      : 0]
                  .add(Center(
                child: Container(
                  height: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                    ),
                  ),
                ),
              ));
            }
          }
        }
      } else if (line.startsWith('!{') && !_isFlashcard) {
        _isFlashcard = true;
      } else if (line.startsWith('}!') && _isFlashcard) {
        _isFlashcard = false;

        

        _rendered.add(
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: _flashcardWidgets[_flashcardWidgets.length > 0
                  ? _flashcardWidgets.length - 1
                  : 0],
            ),
          ),
        );

        _flashcardWidgets.add([]); // Add empty array

        // _flashcardWidgets.clear();
      } else {
        // Normal text
        if (!_isFlashcard) {
          _rendered.add(
            Text(
              line,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontWeight: FontWeight.normal,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          );
        } else {
          _flashcardWidgets[_flashcardWidgets.length > 0
                  ? _flashcardWidgets.length - 1
                  : 0]
              .add(
            Text(
              line,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_flashcardWidgets);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _rendered,
      ),
    );
  }
}
