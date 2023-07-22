

import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:js/js_util.dart' as jsUtil;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

bool isUrl(String input) {
  final regex = RegExp(
      r"^(?:http|https):\/\/(?:(?:[A-Z0-9][A-Z0-9_-]*)(?:\.[A-Z0-9][A-Z0-9_-]*)+)(?::\d{1,5})?(?:\/[^\s]*)?$",
      caseSensitive: false);
  return regex.hasMatch(input);
}


