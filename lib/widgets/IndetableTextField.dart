import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IndentableTextField extends StatefulWidget {
  final Function(String) onChanged;
  final TextEditingController controller;
  IndentableTextField({required this.controller, required this.onChanged});
  @override
  _IndentableTextFieldState createState() => _IndentableTextFieldState();
}

class _IndentableTextFieldState extends State<IndentableTextField> {
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(canRequestFocus: true),
      onKey: (RawKeyEvent event) {
        if (event.runtimeType == RawKeyDownEvent &&
            event.isKeyPressed(LogicalKeyboardKey.tab)) {
          _insertTab();
        }
      },
      child: TextField(
        focusNode: FocusNode(
          canRequestFocus: true,
          skipTraversal: true,
        ),
        // enabled: true,
        // autofocus: true,
        
        keyboardType: TextInputType.multiline,
        cursorColor: Colors.white,
        style: TextStyle(
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Start typing',
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          border: InputBorder.none,
        ),
        expands: true,
        maxLines: null,
        minLines: null,
        onChanged: widget.onChanged,

        controller: widget.controller,

        textInputAction: TextInputAction.newline,
      ),
    );
  }

  void _insertTab() {
    final int cursorPosition = widget.controller.selection.baseOffset;
    final String currentText = widget.controller.text;
    final String newText = currentText.substring(0, cursorPosition) +
        '  ' + // You can use '\t' for a tab character instead of two spaces
        currentText.substring(cursorPosition);

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: cursorPosition + 2), // Adjust the offset as needed
    );
  }

}
