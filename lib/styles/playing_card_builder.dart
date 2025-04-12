import 'package:card_game/card_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solitaire/styles/playing_card_asset_bundle_cache.dart';
import 'package:vector_graphics/vector_graphics.dart';

class PlayingCardBuilder extends StatelessWidget {
  final SuitedCard card;

  const PlayingCardBuilder({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      padding: EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          // 6 of clubs optimization is weird - use regular SVG for that card only.
          child: card.value == NumberSuitedCardValue(value: 6) && card.suit == CardSuit.clubs
              ? SvgPicture.asset(
                  PlayingCardAssetBundleCache.getSvgPath(card),
                  fit: BoxFit.contain,
                )
              : VectorGraphic(
                  loader: PlayingCardAssetBundleCache.getLoader(card),
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
