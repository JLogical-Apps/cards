import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum CardBack {
  redStripes,
  orangeStripes,
  purpleStripes,
  greyStripes,
  blueStripes,
  tealStripes;

  Widget build() => switch (this) {
        CardBack.redStripes => _colorStripeBack(Colors.red),
        CardBack.orangeStripes => _colorStripeBack(Colors.orange),
        CardBack.purpleStripes => _colorStripeBack(Colors.purple),
        CardBack.greyStripes => _colorStripeBack(Colors.grey),
        CardBack.blueStripes => _colorStripeBack(Colors.blue),
        CardBack.tealStripes => _colorStripeBack(Colors.teal),
      };

  Widget _colorStripeBack(Color color) => SvgPicture.asset(
        'assets/backs/back.svg',
        theme: SvgTheme(currentColor: color),
        fit: BoxFit.cover,
        placeholderBuilder: (_) => ColoredBox(color: color),
      );
}
