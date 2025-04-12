import 'package:card_game/card_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
                  'assets/faces/${getSuitName(card)}-${getValueName(card)}.svg',
                  fit: BoxFit.contain,
                )
              : VectorGraphic(
                  loader: AssetBytesLoader('assets/faces/${getSuitName(card)}-${getValueName(card)}.svg.vec'),
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }

  String getSuitName(SuitedCard card) => switch (card.suit) {
        CardSuit.hearts => 'HEART',
        CardSuit.diamonds => 'DIAMOND',
        CardSuit.clubs => 'CLUB',
        CardSuit.spades => 'SPADE',
      };

  String getValueName(SuitedCard card) => switch (card.value) {
        NumberSuitedCardValue(:final value) => value.toString(),
        JackSuitedCardValue() => '11-JACK',
        QueenSuitedCardValue() => '12-QUEEN',
        KingSuitedCardValue() => '13-KING',
        AceSuitedCardValue() => '1',
      };
}
