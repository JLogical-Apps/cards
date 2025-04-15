import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Background {
  green,
  blueGrey,
  brown,
  grey;

  Widget build() => switch (this) {
        Background.green => ColoredBox(color: Colors.green),
        Background.blueGrey => ColoredBox(color: Colors.blueGrey),
        Background.brown => ColoredBox(color: Colors.brown),
        Background.grey => ColoredBox(color: Colors.grey),
      };
}
