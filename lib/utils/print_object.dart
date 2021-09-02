import 'dart:convert';

import 'package:flutter/material.dart';

void printObject(Object? object) {
  if (object == null) return debugPrint('The object to print is null');
  // Encode your object and then decode your object to Map variable
  Map jsonMapped = json.decode(json.encode(object));

  // Using JsonEncoder for spacing
  JsonEncoder encoder = JsonEncoder.withIndent('  ');

  // encode it to string
  String prettyPrint = encoder.convert(jsonMapped);

  // print or debugPrint your object
  debugPrint(prettyPrint);
}
