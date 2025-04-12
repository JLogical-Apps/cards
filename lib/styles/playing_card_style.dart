import 'package:card_game/card_game.dart';
import 'package:flutter/material.dart';
import 'package:solitaire/model/card_back.dart';
import 'package:solitaire/styles/playing_card_builder.dart';

CardGameStyle<SuitedCard> playingCardStyle({double sizeMultiplier = 1, required CardBack cardBack}) => CardGameStyle(
      cardSize: Size(69, 93) * sizeMultiplier,
      emptyGroupBuilder: (state) => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          color: switch (state) {
            CardState.regular => Colors.white,
            CardState.highlighted => Color(0xFF9FC7FF),
            CardState.error => Color(0xFFFFADAD),
          }
              .withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      cardBuilder: (value, flipped, cardState) => AnimatedFlippable(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        isFlipped: flipped,
        front: Stack(
          fit: StackFit.expand,
          children: [
            PlayingCardBuilder(card: value),
            Center(
              child: AnimatedContainer(
                margin: EdgeInsets.all(2),
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  color: switch (cardState) {
                    CardState.regular => null,
                    CardState.highlighted => Color(0xFF9FC7FF).withValues(alpha: 0.5),
                    CardState.error => Color(0xFFFFADAD).withValues(alpha: 0.5),
                  },
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        back: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.hardEdge,
          child: Container(
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: cardBack.build(),
          ),
        ),
      ),
    );
