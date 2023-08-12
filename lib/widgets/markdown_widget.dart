import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

import '../colors.dart';

// ignore: must_be_immutable
class MarkdownWidget extends StatefulWidget {
  final String markdown;
  bool? previewMode;

  MarkdownWidget({required this.markdown, this.previewMode = false});

  @override
  _MarkdownWidgetState createState() => _MarkdownWidgetState();
}

class _MarkdownWidgetState extends State<MarkdownWidget> {
  List<Widget> _rendered = [];
  List<List<Widget>> _flashcardWidgets = [[]];
  bool _isFlashcard = false;
  int _flashcardCounter = 0;
  bool _startCounter = false;
  bool _codeMode = false;
  String _codeString = '';

  @override
  void initState() {
    super.initState();
    _parseMarkdown();
  }

  void _imagePressed(imageUrl) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Container(
        color: palette[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.arrow_back),
                ),
              ],
            ),
            SizedBox(
              width: 500,
              height: 300,
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                ),
              ),
            ),
            Text(
              imageUrl,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'Calibri',
                decoration: TextDecoration.none,
                fontWeight: FontWeight.normal,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }));
  }

  void _parseMarkdown() {
    List<String> lines = widget.markdown.split('\n');

    for (String line in lines) {
      if (_codeMode == true) {
        if (line.startsWith('```')) {
          _codeMode = false;
          var code = _codeString;
          _codeString = ' ';

          if (!_isFlashcard) {
            _rendered.add(
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.maxFinite,
                  child: HighlightView(
                    code,
                    language: 'python',
                    theme: atomOneDarkTheme,
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ),
            );
          } else {
            _flashcardWidgets[_flashcardWidgets.length > 0
                    ? _flashcardWidgets.length - 1
                    : 0]
                .add(
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.maxFinite,
                  child: HighlightView(
                    code,
                    language: 'python',
                    theme: atomOneDarkTheme,
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ),
            );
          }

          continue;
        }
        _codeString += line + '\n';
        continue;
      }

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
    Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          line.substring(2), // Assuming 'line' is your text content
          softWrap: true,
          style: TextStyle(
            decoration: TextDecoration.none,
            fontWeight: FontWeight.normal,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    ),
  ],
),

          );
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
            textAlign: TextAlign.left,
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
              _rendered.add(GestureDetector(
                onTap: () => _imagePressed(imageUrl),
                child: SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Hero(
                      tag: imageUrl,
                      child: Image.network(
                        imageUrl,
                      ),
                    ),
                  ),
                ),
              ));
            } else {
              _flashcardWidgets[_flashcardWidgets.length > 0
                      ? _flashcardWidgets.length - 1
                      : 0]
                  .add(GestureDetector(
                onTap: () => _imagePressed(imageUrl),
                child: SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Hero(
                      tag: imageUrl,
                      child: Image.network(
                        imageUrl,
                      ),
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
      } else if (line.startsWith('```')) {
        _codeMode = true;
      } else if (line.startsWith('---')) {
        _rendered.add(
          const Divider(
            color: Colors.white,
          ),
        );
      } else if (line.startsWith('//')) {
        // Comment
        // Do nothing
      } else {
        // Normal text
        if (!_isFlashcard) {
          _rendered.add(
            Text(
              line,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'Calibri',
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
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'Calibri',
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
    // If markdown is in preview mode, only show 3 elements
    if ((widget.previewMode ?? false) && _rendered.length > 5) {
      var temp = _rendered.sublist(0, 5);
      temp.add(
        const Text(
          '...\nRead more',
          style: TextStyle(
            decoration: TextDecoration.none,
            fontWeight: FontWeight.normal,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      );
      _rendered = temp;
    }

    return widget.previewMode ?? true ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _rendered,
      ) : SelectableRegion(
      selectionControls: materialTextSelectionControls,
      focusNode: FocusNode(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _rendered,
      ),
    );
  }
}

// Flashcard Widget
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
                    style: const TextStyle(
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
          Padding(
              padding: EdgeInsets.all(8.0),
              child: _showFront
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.front,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.back,
                    )),
        ],
      ),
    );
  }
}
