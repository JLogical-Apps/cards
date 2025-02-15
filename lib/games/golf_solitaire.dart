import 'package:card_game/card_game.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:solitaire/widgets/card_scaffold.dart';

class GolfSolitaireState {
  final List<List<SuitedCard>> cards;
  final List<SuitedCard> deck;
  final List<SuitedCard> completedCards;

  final List<GolfSolitaireState> history;

  GolfSolitaireState({
    required this.cards,
    required this.deck,
    required this.completedCards,
    required this.history,
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
      deck: deck,
      completedCards: [],
      history: [],
    );
  }

  bool canSelect(SuitedCard card) {
    return completedCards.isEmpty || SuitedCardDistanceMapper.rollover.getDistance(completedCards.last, card) == 1;
  }

  GolfSolitaireState withSelection(SuitedCard card) => GolfSolitaireState(
        cards: cards.map((column) => [...column]..remove(card)).toList(),
        deck: deck,
        completedCards: completedCards + [card],
        history: history + [this],
      );

  bool get canDraw => deck.isNotEmpty;

  GolfSolitaireState withDraw() => GolfSolitaireState(
        cards: cards,
        deck: deck.sublist(0, deck.length - 1),
        completedCards: completedCards + [deck.last],
        history: history + [this],
      );

  GolfSolitaireState withUndo() => history.last;

  bool get isVictory => cards.every((column) => column.isEmpty);
}

class GolfSolitaire extends HookWidget {
  const GolfSolitaire({super.key});

  @override
  Widget build(BuildContext context) {
    final state = useState(GolfSolitaireState.initialState);

    return CardScaffold(
      onNewGame: () => state.value = GolfSolitaireState.initialState,
      onRestart: () => state.value = state.value.history.firstOrNull ?? state.value,
      onUndo: state.value.history.isEmpty ? null : () => state.value = state.value.withUndo(),
      isVictory: state.value.isVictory,
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight - (6 * 4);
        final cardHeight = availableHeight / 7;

        return CardGame<SuitedCard, dynamic>(
          style: deckCardStyle(sizeMultiplier: cardHeight / 89),
          children: [
            Row(
              children: [
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
          ],
        );
      },
    );
  }
}
