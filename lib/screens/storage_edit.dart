import 'package:flutter/material.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

class StorageEdit extends StatefulWidget {
  @override
  _StorageEditState createState() => _StorageEditState();
}

class _StorageEditState extends State<StorageEdit> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return Container();
          } else {
            return Row(
              children: [
                Container(
                  width: 200,
                  color: Color.fromARGB(255, 34, 34, 34),
                ),
                Expanded(
                  child: Container(
                    height: double.infinity,
                    color: Color.fromARGB(255, 25, 25, 25),
                    child: SingleChildScrollView(
                      child: MarkdownAutoPreview(
                        controller: _controller,
                        emojiConvert: true,
                        markdownSyntax: " ",
                        toolbarBackground: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
