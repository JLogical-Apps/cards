import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:solitaire/styles/color_library.dart';
import 'package:solitaire/styles/playing_card_asset_bundle_cache.dart';
import 'package:vector_graphics/vector_graphics.dart';

@JsonEnum()
enum CardBack {
  redStripes(assetName: 'back', fallbackColor: ColorLibrary.red400),
  stoneStripes(assetName: 'back', fallbackColor: ColorLibrary.stone400),
  skyStripes(assetName: 'back', fallbackColor: ColorLibrary.sky400),
  violetStripes(assetName: 'back', fallbackColor: ColorLibrary.violet400),
  redPoly(assetName: 'red-poly', fallbackColor: ColorLibrary.red400),
  stonePoly(assetName: 'stone-poly', fallbackColor: ColorLibrary.stone400),
  skyPoly(assetName: 'sky-poly', fallbackColor: ColorLibrary.sky400),
  violetPoly(assetName: 'violet-poly', fallbackColor: ColorLibrary.violet400),
  redSteps(assetName: 'red-steps', fallbackColor: ColorLibrary.red400),
  stoneSteps(assetName: 'stone-steps', fallbackColor: ColorLibrary.stone400),
  skySteps(assetName: 'sky-steps', fallbackColor: ColorLibrary.sky400),
  violetSteps(assetName: 'violet-steps', fallbackColor: ColorLibrary.violet400);

  final String assetName;
  final Color fallbackColor;

  const CardBack({required this.assetName, required this.fallbackColor});

  Widget build() => switch (this) {
        CardBack.redStripes ||
        CardBack.stoneStripes ||
        CardBack.skyStripes ||
        CardBack.violetStripes =>
          _colorStripeBack(),
        _ => _vectorImage(),
      };

  Widget _colorStripeBack() => VectorGraphic(
        loader: PlayingCardAssetBundleCache.getCardBackLoader(this),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(fallbackColor, BlendMode.lighten),
        placeholderBuilder: (_) => ColoredBox(color: fallbackColor),
      );

  Widget _vectorImage() => VectorGraphic(
        loader: PlayingCardAssetBundleCache.getCardBackLoader(this),
        fit: BoxFit.cover,
        placeholderBuilder: (_) => ColoredBox(color: fallbackColor),
      );
}
