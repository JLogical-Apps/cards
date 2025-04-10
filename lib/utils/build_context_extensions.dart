import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  void pushReplacement(Widget Function() page) =>
      Navigator.of(this).pushReplacement(MaterialPageRoute(builder: (_) => page()));
}
