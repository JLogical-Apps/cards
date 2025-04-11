import 'package:card_game/card_game.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/game.dart';
import 'package:solitaire/styles/playing_card_style.dart';
import 'package:solitaire/utils/axis_extensions.dart';
import 'package:solitaire/utils/constraints_extensions.dart';
import 'package:solitaire/widgets/card_scaffold.dart';

class GolfSolitaireState {
  final List<List<SuitedCard>> cards;
  final List<SuitedCard> deck;
  final List<SuitedCard> completedCards;
  final bool canRollover;

  final List<GolfSolitaireState> history;

  GolfSolitaireState({
    required this.cards,
    required this.deck,
    required this.completedCards,
    required this.canRollover,
    required this.history,
  });

  static GolfSolitaireState getInitialState({required bool startWithDraw, required bool canRollover}) {
    var deck = SuitedCard.deck.shuffled();

    final cards = List.generate(7, (i) {
      final column = deck.take(5).toList();
      deck = deck.skip(5).toList();
      return column;
    });

    var completedCards = <SuitedCard>[];
    if (startWithDraw) {
      completedCards.add(deck.first);
      deck = deck.skip(1).toList();
    }

    return GolfSolitaireState(
      cards: cards,
      deck: deck,
      completedCards: completedCards,
      canRollover: canRollover,
      history: [],
    );
  }

  SuitedCardDistanceMapper get distanceMapper =>
      canRollover ? SuitedCardDistanceMapper.rollover : SuitedCardDistanceMapper.aceToKing;

  bool canSelect(SuitedCard card) =>
      completedCards.isEmpty || distanceMapper.getDistance(completedCards.last, card) == 1;

  GolfSolitaireState withSelection(SuitedCard card) => GolfSolitaireState(
        cards: cards.map((column) => [...column]..remove(card)).toList(),
        deck: deck,
        completedCards: completedCards + [card],
        canRollover: canRollover,
        history: history + [this],
      );

  bool get canDraw => deck.isNotEmpty;

  GolfSolitaireState withDraw() => GolfSolitaireState(
        cards: cards,
        deck: deck.sublist(0, deck.length - 1),
        completedCards: completedCards + [deck.last],
        canRollover: canRollover,
        history: history + [this],
      );

  GolfSolitaireState withUndo() => history.last;

  bool get isVictory => cards.every((column) => column.isEmpty);
}

class GolfSolitaire extends HookWidget {
  final Difficulty difficulty;

  const GolfSolitaire({super.key, required this.difficulty});

  GolfSolitaireState get initialState => GolfSolitaireState.getInitialState(
        startWithDraw: difficulty.index >= Difficulty.royal.index,
        canRollover: difficulty != Difficulty.ace,
      );

  @override
  Widget build(BuildContext context) {
    final state = useState(initialState);

    return CardScaffold(
      game: Game.golf,
      difficulty: difficulty,
      onNewGame: () => state.value = initialState,
      onRestart: () => state.value = state.value.history.firstOrNull ?? state.value,
      onUndo: state.value.history.isEmpty ? null : () => state.value = state.value.withUndo(),
      isVictory: state.value.isVictory,
      builder: (context, constraints, cardBack, gameKey) {
        final axis = constraints.largestAxis;
        final minSize = constraints.smallest.longestSide;
        final spacing = minSize / 100;

        final sizeMultiplier = constraints.findCardSizeMultiplier(
          maxRows: axis == Axis.horizontal ? 2 : 7,
          maxCols: axis == Axis.horizontal ? 8 : 1,
          spacing: spacing,
        );

        final cardOffset = sizeMultiplier * 25;

        return CardGame<SuitedCard, dynamic>(
          gameKey: gameKey,
          style: playingCardStyle(sizeMultiplier: sizeMultiplier, cardBack: cardBack),
          children: [
            Row(
              children: [
                Expanded(
                  child: Flex(
                    direction: axis,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: state.value.cards
                        .mapIndexed((i, column) => CardLinearGroup<SuitedCard, dynamic>(
                              cardOffset: axis.inverted.offset * cardOffset,
                              value: i,
                              values: column,
                              canCardBeGrabbed: (_, __) => false,
                              maxGrabStackSize: 0,
                              onCardPressed: (card) {
                                final lastCard = state.value.cards[i].lastOrNull;
                                if (lastCard != card) {
                                  return;
                                }
                                if (state.value.canSelect(card)) {
                                  state.value = state.value.withSelection(card);
                                }
                              },
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(width: spacing),
                Column(
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
              ],
            ),
          ],
        );
      },
    );
  }
}
