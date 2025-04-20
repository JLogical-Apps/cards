import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:solitaire/model/achievement.dart';
import 'package:solitaire/styles/color_library.dart';
import 'package:solitaire/styles/playing_card_asset_bundle_cache.dart';
import 'package:vector_graphics/vector_graphics.dart';

@JsonEnum()
enum CardBack {
  redStripes(assetName: 'back', fallbackColor: ColorLibrary.red400),
  stoneStripes(assetName: 'back', fallbackColor: ColorLibrary.stone400, achievementLock: Achievement.speedDealer),
  skyStripes(assetName: 'back', fallbackColor: ColorLibrary.sky400, achievementLock: Achievement.grandSlam),
  violetStripes(assetName: 'back', fallbackColor: ColorLibrary.violet400, achievementLock: Achievement.suitedUp),
  redPoly(assetName: 'red-poly', fallbackColor: ColorLibrary.red400, achievementLock: Achievement.deckWhisperer),
  stonePoly(assetName: 'stone-poly', fallbackColor: ColorLibrary.stone400, achievementLock: Achievement.fullHouse),
  skyPoly(assetName: 'sky-poly', fallbackColor: ColorLibrary.sky400, achievementLock: Achievement.birdie),
  violetPoly(
    assetName: 'violet-poly',
    fallbackColor: ColorLibrary.violet400,
    achievementLock: Achievement.stackTheDeck,
  ),
  redSteps(assetName: 'red-steps', fallbackColor: ColorLibrary.red400, achievementLock: Achievement.royalFlush),
  stoneSteps(assetName: 'stone-steps', fallbackColor: ColorLibrary.stone400, achievementLock: Achievement.cleanSweep),
  skySteps(assetName: 'sky-steps', fallbackColor: ColorLibrary.sky400, achievementLock: Achievement.perfectPlanning),
  violetSteps(
    assetName: 'violet-steps',
    fallbackColor: ColorLibrary.violet400,
    achievementLock: Achievement.aceUpYourSleeve,
  );

  final String assetName;
  final Color fallbackColor;
  final Achievement? achievementLock;

  const CardBack({required this.assetName, required this.fallbackColor, this.achievementLock});

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
