import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:solitaire/styles/playing_card_asset_bundle_cache.dart';
import 'package:vector_graphics/vector_graphics.dart';

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

  Widget _colorStripeBack(Color color) => VectorGraphic(
        loader: PlayingCardAssetBundleCache.cardBackLoader,
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(color, BlendMode.lighten),
        placeholderBuilder: (_) => ColoredBox(color: color),
      );
}
