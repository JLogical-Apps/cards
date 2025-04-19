import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:solitaire/styles/color_library.dart';

@JsonEnum()
enum Background {
  green(fallbackColor: ColorLibrary.green600),
  blue(fallbackColor: ColorLibrary.red400),
  slate(fallbackColor: ColorLibrary.slate400),
  grey(fallbackColor: ColorLibrary.stone400);

  final Color fallbackColor;

  const Background({required this.fallbackColor});

  Widget build() => ColoredBox(color: fallbackColor);
}
