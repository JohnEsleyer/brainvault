import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  int _flashcardCounter = 0;
  bool _startCounter = false;

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
                    fontSize: 14,
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
                    fontSize: 14,
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
              fontSize: 14,
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
              fontSize: 14,
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
              fontSize: 14,
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
              fontSize: 14,
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
        _startCounter = true;
        continue; // Continue to the next iteration to avoid incrementing _flashcardCounter
      } else if (line.startsWith(',') && _isFlashcard) {
        _startCounter = false;
      } else if (line.startsWith('}!') && _isFlashcard) {
        _isFlashcard = false;

        // Divide the map into two, front and back
        var currentMap = _flashcardWidgets[
            _flashcardWidgets.length > 0 ? _flashcardWidgets.length - 1 : 0];

        List<List<Widget>> sections = [[], []];
        // print('FlashcarCounter: $_flashcardCounter');
        // print('currentMap: ${currentMap.length}');
        // print('currentMapWidgets: $currentMap');

        for (int i = 0; i < currentMap.length; i++) {
          if (i + 1 <= _flashcardCounter) {
            sections[0].add(currentMap[i]);
          } else {
            sections[1].add(currentMap[i]);
          }
        }
        print(sections);

        // Add flashcard to _rendered list
        _rendered.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Flashcard(
              front: sections[0],
              back: sections[1],
            ),
          ),
        );

        _flashcardWidgets.add([]); // Add empty array
        _flashcardCounter = 0;
      } else if (line.startsWith('//')){
        // Comment
        // Do nothing
      }else {
        // Normal text
        if (!_isFlashcard) {
          _rendered.add(
            Text(
              line,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontWeight: FontWeight.normal,
                color: Colors.white,
                fontSize: 14,
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
                fontSize: 14,
              ),
            ),
          );
        }
      }
      if (_startCounter) {
        _flashcardCounter++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_flashcardWidgets);
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 8.0,
      ),
      child: SelectableRegion(
        selectionControls: materialTextSelectionControls,
        focusNode: FocusNode(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _rendered,
        ),
      ),
    );
  }
}

class Flashcard extends StatefulWidget {
  final List<Widget> front;
  final List<Widget> back;

  Flashcard({required this.front, required this.back});

  @override
  _FlashcardState createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard> {
  bool _showFront = true;

  void _flipCard() {
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: _flipCard,
              child: Row(
                children: [
                  Icon(Icons.flip, color: Colors.black),
                  SizedBox(width: 5),
                  Text(
                    _showFront ? 'Front' : 'Back',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            // width: 300,
            // height: 200,
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.circular(10),
            //   boxShadow: [
            //     BoxShadow(
            //       color: Colors.grey.withOpacity(0.3),
            //       spreadRadius: 2,
            //       blurRadius: 5,
            //       offset: Offset(0, 3),
            //     ),
            //   ],
            // ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
                child: _showFront
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.front,
                      )
                    : Column(
                        children: widget.back,
                      )),
          ),
        ],
      ),
    );
  }
}
