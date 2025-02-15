import 'package:card_game/card_game.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:solitaire/widgets/card_scaffold.dart';
import 'package:solitaire/widgets/delayed_auto_move_listener.dart';

class SolitaireState {
  final List<List<SuitedCard>> hiddenCards;
  final List<List<SuitedCard>> revealedCards;
  final List<SuitedCard> deck;
  final List<SuitedCard> revealedDeck;
  final Map<CardSuit, List<SuitedCard>> completedCards;

  final List<SolitaireState> history;

  SolitaireState({
    required this.hiddenCards,
    required this.revealedCards,
    required this.deck,
    required this.revealedDeck,
    required this.completedCards,
    required this.history,
  });

  static SolitaireState get initialState {
    var deck = SuitedCard.deck.shuffled();

    final hiddenCards = List.generate(7, (i) {
      final column = deck.take(i).toList();
      deck = deck.skip(i).toList();
      return column;
    });

    final revealedCards = deck.take(7).map((card) => [card]).toList();
    deck = deck.skip(7).toList();

    return SolitaireState(
      hiddenCards: hiddenCards,
      revealedCards: revealedCards,
      deck: deck,
      revealedDeck: [],
      completedCards: Map.fromEntries(CardSuit.values.map((suit) => MapEntry(suit, []))),
      history: [],
    );
  }

  SolitaireState withDrawOrRefresh() {
    return deck.isEmpty
        ? copyWith(deck: revealedDeck.reversed.toList(), revealedDeck: [])
        : copyWith(deck: deck.sublist(0, deck.length - 1), revealedDeck: revealedDeck + [deck.last]);
  }

  int getCardValue(SuitedCard card) => SuitedCardValueMapper.aceAsLowest.getValue(card);

  SolitaireState withAutoTap(int column, List<SuitedCard> cards) {
    if (cards.length == 1 && canComplete(cards.first)) {
      return withAttemptToComplete(column);
    }

    final newColumn = List.generate(7, (i) => canMove(cards, i)).indexOf(true);
    if (newColumn == -1) {
      return this;
    }

    return withMoveFromColumn(cards, column, newColumn);
  }

  SolitaireState withAutoMoveFromDeck() {
    final card = revealedDeck.last;
    if (canComplete(card)) {
      return withAttemptToCompleteFromDeck();
    }

    final newColumn = List.generate(7, (i) => canMove([card], i)).indexOf(true);
    if (newColumn == -1) {
      return this;
    }

    return withMoveFromDeck([card], newColumn);
  }

  SolitaireState withAutoMoveFromCompleted(CardSuit suit) {
    final card = completedCards[suit]!.last;

    final newColumn = List.generate(7, (i) => canMove([card], i)).indexOf(true);
    if (newColumn == -1) {
      return this;
    }

    return withMoveFromCompleted(suit, newColumn);
  }

  bool canComplete(SuitedCard card) {
    final completedSuitCards = completedCards[card.suit]!;
    return completedSuitCards.isEmpty && card.value == AceSuitedCardValue() ||
        (completedSuitCards.isNotEmpty && getCardValue(completedSuitCards.last) + 1 == getCardValue(card));
  }

  SolitaireState withAttemptToComplete(int column) {
    final card = revealedCards[column].lastOrNull;
    if (card != null && canComplete(card)) {
      final newRevealedCards = [...revealedCards];
      newRevealedCards[column] = [...revealedCards[column]]..removeLast();

      final newHiddenCards = [...hiddenCards];
      final lastHiddenCard = hiddenCards[column].lastOrNull;

      if (newRevealedCards[column].isEmpty && lastHiddenCard != null) {
        newRevealedCards[column] = [lastHiddenCard];
        newHiddenCards[column] = [...newHiddenCards[column]]..removeLast();
      }

      return copyWith(
        revealedCards: newRevealedCards,
        hiddenCards: newHiddenCards,
        completedCards: {
          ...completedCards,
          card.suit: [...completedCards[card.suit]!, card],
        },
      );
    }

    return this;
  }

  SolitaireState withAttemptToCompleteFromDeck() {
    final revealedCard = revealedDeck.lastOrNull;
    if (revealedCard == null) {
      return this;
    }

    if (canComplete(revealedCard)) {
      return copyWith(
        revealedDeck: [...revealedDeck]..removeLast(),
        completedCards: {
          ...completedCards,
          revealedCard.suit: [...completedCards[revealedCard.suit]!, revealedCard],
        },
      );
    }

    return this;
  }

  bool canMove(List<SuitedCard> cards, int newColumn) {
    final newColumnCard = revealedCards[newColumn].lastOrNull;
    final topMostCard = cards.first;

    return (newColumnCard == null && topMostCard.value == KingSuitedCardValue()) ||
        (newColumnCard != null &&
            getCardValue(topMostCard) + 1 == getCardValue(newColumnCard) &&
            newColumnCard.suit.color != topMostCard.suit.color);
  }

  SolitaireState withMove(List<SuitedCard> cards, dynamic oldColumn, int newColumn) {
    return oldColumn == 'revealed-deck'
        ? withMoveFromDeck(cards, newColumn)
        : oldColumn is CardSuit
            ? withMoveFromCompleted(oldColumn, newColumn)
            : withMoveFromColumn(cards, oldColumn, newColumn);
  }

  SolitaireState withMoveFromColumn(List<SuitedCard> cards, int oldColumn, int newColumn) {
    final newRevealedCards = [...revealedCards];
    newRevealedCards[oldColumn] =
        newRevealedCards[oldColumn].sublist(0, newRevealedCards[oldColumn].length - cards.length);
    newRevealedCards[newColumn] = [...newRevealedCards[newColumn], ...cards];

    final newHiddenCards = [...hiddenCards];

    final lastHiddenCard = hiddenCards[oldColumn].lastOrNull;
    if (newRevealedCards[oldColumn].isEmpty && lastHiddenCard != null) {
      newRevealedCards[oldColumn] = [lastHiddenCard];
      newHiddenCards[oldColumn] = [...newHiddenCards[oldColumn]]..removeLast();
    }

    return copyWith(
      revealedCards: newRevealedCards,
      hiddenCards: newHiddenCards,
    );
  }

  SolitaireState withMoveFromDeck(List<SuitedCard> cards, int newColumn) {
    final newRevealedCards = [...revealedCards];
    newRevealedCards[newColumn] = [...newRevealedCards[newColumn], ...cards];

    final newRevealedDeck = [...revealedDeck]..removeLast();

    return copyWith(
      revealedCards: newRevealedCards,
      revealedDeck: newRevealedDeck,
    );
  }

  SolitaireState withMoveFromCompleted(CardSuit suit, int column) {
    final completedCard = completedCards[suit]!.last;
    final newRevealedCards = [...revealedCards];
    newRevealedCards[column] = [...newRevealedCards[column], completedCard];

    final newCompletedCards = {
      ...completedCards,
      suit: [...completedCards[suit]!]..removeLast(),
    };

    return copyWith(
      revealedCards: newRevealedCards,
      completedCards: newCompletedCards,
    );
  }

  SolitaireState withUndo() {
    return history.last;
  }

  SolitaireState? withAutoMove() {
    final lowestCompletedValue =
        completedCards.values.map((cards) => cards.lastOrNull).map((card) => card == null ? 0 : getCardValue(card)).min;

    bool canAutoMove(SuitedCard? card) {
      if (card == null) {
        return false;
      }

      final canMove = canComplete(card);
      if (!canMove) {
        return false;
      }

      final value = getCardValue(card);
      return lowestCompletedValue + 2 >= value;
    }

    final cardsAutoMoveIndex = revealedCards.indexWhere((cards) => cards.isEmpty ? false : canAutoMove(cards.last));
    if (cardsAutoMoveIndex != -1) {
      return withAttemptToComplete(cardsAutoMoveIndex);
    }

    if (revealedDeck.isNotEmpty && canAutoMove(revealedDeck.last)) {
      return withAttemptToCompleteFromDeck();
    }

    return null;
  }

  bool get isVictory => completedCards.values.every((cards) => cards.length == 13);

  SolitaireState copyWith({
    List<List<SuitedCard>>? hiddenCards,
    List<List<SuitedCard>>? revealedCards,
    List<SuitedCard>? deck,
    List<SuitedCard>? revealedDeck,
    Map<CardSuit, List<SuitedCard>>? completedCards,
  }) {
    return SolitaireState(
      hiddenCards: hiddenCards ?? this.hiddenCards,
      revealedCards: revealedCards ?? this.revealedCards,
      deck: deck ?? this.deck,
      revealedDeck: revealedDeck ?? this.revealedDeck,
      completedCards: completedCards ?? this.completedCards,
      history: history + [this],
    );
  }
}

class Solitaire extends HookWidget {
  const Solitaire({super.key});

  @override
  Widget build(BuildContext context) {
    final state = useState(SolitaireState.initialState);

    return DelayedAutoMoveListener(
      stateGetter: () => state.value,
      nextStateGetter: (state) => state.withAutoMove(),
      onNewState: (newState) => state.value = newState,
      child: CardScaffold(
        onNewGame: () => state.value = SolitaireState.initialState,
        onRestart: () => state.value = state.value.history.firstOrNull ?? state.value,
        onUndo: state.value.history.isEmpty ? null : () => state.value = state.value.withUndo(),
        isVictory: state.value.isVictory,
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight - (6 * 4);
          final cardHeight = availableHeight / 7;

          return CardGame(
            style: deckCardStyle(sizeMultiplier: cardHeight / 89),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: List<Widget>.generate(7, (i) {
                          final hiddenCards = state.value.hiddenCards[i];
                          final revealedCards = state.value.revealedCards[i];

                          return CardRow<SuitedCard, dynamic>(
                            value: i,
                            spacing: 30,
                            values: hiddenCards + revealedCards,
                            canCardBeGrabbed: (_, card) => revealedCards.contains(card),
                            isCardFlipped: (_, card) => hiddenCards.contains(card),
                            onCardPressed: (card) {
                              if (hiddenCards.contains(card)) {
                                return;
                              }

                              final cardIndex = revealedCards.indexOf(card);

                              state.value = state.value.withAutoTap(i, revealedCards.sublist(cardIndex));
                            },
                            canMoveCardHere: (move) => state.value.canMove(move.cardValues, i),
                            onCardMovedHere: (move) =>
                                state.value = state.value.withMove(move.cardValues, move.fromGroupValue, i),
                          );
                        }).toList()),
                  ),
                  SizedBox(width: 4),
                  Column(
                    children: [
                      SizedBox(height: 4),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => state.value = state.value.withDrawOrRefresh(),
                        child: CardDeck<SuitedCard, dynamic>.flipped(
                          value: 'deck',
                          values: state.value.deck,
                        ),
                      ),
                      SizedBox(height: 4),
                      CardDeck<SuitedCard, dynamic>(
                        value: 'revealed-deck',
                        values: state.value.revealedDeck,
                        canMoveCardHere: (_) => false,
                        onCardPressed: (card) => state.value = state.value.withAutoMoveFromDeck(),
                        canGrab: true,
                      ),
                      Spacer(),
                      ...state.value.completedCards.entries.expand((entry) => [
                            CardDeck<SuitedCard, dynamic>(
                              value: entry.key,
                              values: entry.value,
                              canGrab: true,
                              onCardPressed: (card) => state.value = state.value.withAutoMoveFromCompleted(entry.key),
                            ),
                            SizedBox(height: 4),
                          ]),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
