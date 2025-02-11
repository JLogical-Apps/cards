import 'package:card_game/card_game.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class GolfSolitaireState {
  final List<List<SuitedCard>> cards;
  final List<SuitedCard> deck;
  final List<SuitedCard> completedCards;

  GolfSolitaireState({
    required this.cards,
    required this.deck,
    required this.completedCards,
  });

  static GolfSolitaireState get initialState {
    var deck = SuitedCard.deck.shuffled();

    final cards = List.generate(7, (i) {
      final column = deck.take(5).toList();
      deck = deck.skip(5).toList();
      return column;
    });

    return GolfSolitaireState(
      cards: cards,
      deck: deck.skip(1).toList(),
      completedCards: [deck.first],
    );
  }

  bool canSelect(SuitedCard card) {
    return SuitedCardDistanceMapper.rollover.getDistance(completedCards.last, card) == 1;
  }

  GolfSolitaireState withSelection(SuitedCard card) => GolfSolitaireState(
        cards: cards.map((column) => [...column]..remove(card)).toList(),
        deck: deck,
        completedCards: completedCards + [card],
      );

  bool get canDraw => deck.isNotEmpty;

  GolfSolitaireState withDraw() => GolfSolitaireState(
        cards: cards,
        deck: deck.sublist(0, deck.length - 1),
        completedCards: completedCards + [deck.last],
      );
}

class GolfSolitaire extends HookWidget {
  const GolfSolitaire({super.key});

  @override
  Widget build(BuildContext context) {
    final state = useState(GolfSolitaireState.initialState);

    return CardGame<SuitedCard, dynamic>(
      style: deckCardStyle(sizeMultiplier: 1.2),
      children: [
        SafeArea(
          child: Row(
            children: [
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: state.value.cards
                      .mapIndexed((i, column) => CardRow<SuitedCard, dynamic>(
                            value: i,
                            values: column,
                            spacing: 30,
                            maxGrabStackSize: 0,
                            onCardPressed: (card) {
                              if (state.value.canSelect(card)) {
                                state.value = state.value.withSelection(card);
                              }
                            },
                          ))
                      .toList(),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 40,
                  children: [
                    CardDeck<SuitedCard, dynamic>.flipped(
                      value: 'deck',
                      values: state.value.deck,
                      onCardPressed: (_) => state.value = state.value.withDraw(),
                    ),
                    CardDeck<SuitedCard, dynamic>(
                      value: 'completed',
                      values: state.value.completedCards,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
