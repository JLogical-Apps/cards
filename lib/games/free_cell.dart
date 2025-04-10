import 'dart:math';

import 'package:card_game/card_game.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/game.dart';
import 'package:solitaire/styles/playing_card_style.dart';
import 'package:solitaire/utils/axis_extensions.dart';
import 'package:solitaire/utils/constraints_extensions.dart';
import 'package:solitaire/widgets/card_scaffold.dart';
import 'package:solitaire/widgets/delayed_auto_move_listener.dart';

// Abstract base class for all group values
abstract class GroupValue extends Equatable {
  const GroupValue();
}

// Tableau column group value
class TableauGroupValue extends GroupValue {
  final int columnIndex;

  const TableauGroupValue(this.columnIndex);

  @override
  List<Object?> get props => [columnIndex];
}

// Free cell group value
class FreeCellGroupValue extends GroupValue {
  final int cellIndex;

  const FreeCellGroupValue(this.cellIndex);

  @override
  List<Object?> get props => [cellIndex];
}

// Foundation group value
class FoundationGroupValue extends GroupValue {
  final CardSuit suit;

  const FoundationGroupValue(this.suit);

  @override
  List<Object?> get props => [suit];
}

class FreeCellState {
  final List<List<SuitedCard>> tableauCards;
  final List<SuitedCard?> freeCells;
  final Map<CardSuit, List<SuitedCard>> foundationCards;

  final bool canAutoMove;
  final List<FreeCellState> history;

  FreeCellState({
    required this.tableauCards,
    required this.freeCells,
    required this.foundationCards,
    required this.canAutoMove,
    required this.history,
  });

  static FreeCellState getInitialState({required int freeCellCount, required bool acesAtBottom}) {
    var deck = SuitedCard.deck.shuffled();

    final aces = deck.where((card) => card.value == AceSuitedCardValue()).toList();
    if (acesAtBottom) {
      deck = deck.where((card) => card.value != AceSuitedCardValue()).toList();
    }

    // In Free Cell, we start with 8 columns (tableau)
    final tableauCards = List.generate(8, (i) {
      final cardsPerColumn = i < 4 ? 7 : 6; // First 4 columns have 7 cards, last 4 have 6
      final cardsToTake = cardsPerColumn - (acesAtBottom && i < 4 ? 1 : 0);

      final column = deck.take(cardsToTake).toList();
      deck = deck.skip(cardsToTake).toList();

      if (acesAtBottom && i < 4 && aces.isNotEmpty) {
        column.insert(0, aces.removeAt(0));
      }

      return column;
    });

    return FreeCellState(
      tableauCards: tableauCards,
      freeCells: List.filled(freeCellCount, null),
      foundationCards: Map.fromEntries(CardSuit.values.map((suit) => MapEntry(suit, []))),
      history: [],
      canAutoMove: true,
    );
  }

  int getCardValue(SuitedCard card) => SuitedCardValueMapper.aceAsLowest.getValue(card);

  // Calculate how many cards can be moved at once based on free cells and empty tableaus
  int get maxMoveSize {
    final emptyCells = freeCells.where((cell) => cell == null).length;
    final emptyTableaux = tableauCards.where((column) => column.isEmpty).length;

    // Basic formula: (emptyCells + 1) * 2^emptyTableaux
    return (emptyCells + 1) * pow(2, emptyTableaux).toInt();
  }

  // Calculate the maximum movable stack size for a specific move
  int getMaxMoveSizeForTarget(int targetColumn) {
    final emptyCells = freeCells.where((cell) => cell == null).length;
    final emptyTableauxCount = tableauCards.where((column) => column.isEmpty).length;

    // If target is an empty column, we need to exclude it from our empty tableaux count
    final effectiveEmptyTableauxCount = tableauCards[targetColumn].isEmpty
        ? max(0, emptyTableauxCount - 1) // Exclude the destination column if it's empty
        : emptyTableauxCount;

    // Apply the FreeCell formula
    return (emptyCells + 1) * pow(2, effectiveEmptyTableauxCount).toInt();
  }

  // Check if a card can be added to foundation
  bool canAddToFoundation(SuitedCard card) {
    final foundationSuitCards = foundationCards[card.suit]!;
    return (foundationSuitCards.isEmpty && card.value == AceSuitedCardValue()) ||
        (foundationSuitCards.isNotEmpty && getCardValue(foundationSuitCards.last) + 1 == getCardValue(card));
  }

  // Check if a sequence of cards is valid (alternating colors, descending values)
  bool isValidSequence(List<SuitedCard> cards) {
    if (cards.isEmpty) return true;

    for (var i = 0; i < cards.length - 1; i++) {
      final currentCard = cards[i];
      final nextCard = cards[i + 1];

      if (currentCard.suit.color == nextCard.suit.color || getCardValue(currentCard) != getCardValue(nextCard) + 1) {
        return false;
      }
    }

    return true;
  }

  // Check if cards can be moved to tableau
  bool canMoveToTableau(List<SuitedCard> cards, int targetColumn) {
    if (cards.isEmpty) return false;

    // Calculate max move size for this specific target
    final effectiveMaxMoveSize = getMaxMoveSizeForTarget(targetColumn);

    // First check if move size is allowed
    if (cards.length > effectiveMaxMoveSize) {
      return false;
    }

    // Then check if target column is empty or has a valid target card
    if (tableauCards[targetColumn].isEmpty) {
      // Any card can be placed in an empty column (size already checked)
      return true;
    } else {
      // For non-empty columns, check if move is valid
      final targetTopCard = tableauCards[targetColumn].last;
      final movingBottomCard = cards.first;

      return movingBottomCard.suit.color != targetTopCard.suit.color &&
          getCardValue(movingBottomCard) + 1 == getCardValue(targetTopCard);
    }
  }

  // Check if a card can be moved to a free cell
  bool canMoveToFreeCell(SuitedCard card, int cellIndex) => freeCells[cellIndex] == null;

  // Move cards from one tableau column to another
  FreeCellState withMoveFromTableauToTableau(List<SuitedCard> cards, int fromColumn, int toColumn) {
    // Double-check using the canMoveToTableau method
    if (!canMoveToTableau(cards, toColumn)) {
      return this;
    }

    final newTableauCards = [...tableauCards];

    // Remove cards from source column
    newTableauCards[fromColumn] =
        newTableauCards[fromColumn].sublist(0, newTableauCards[fromColumn].length - cards.length);

    // Add cards to destination column
    newTableauCards[toColumn] = [...newTableauCards[toColumn], ...cards];

    return copyWith(
      tableauCards: newTableauCards,
      canAutoMove: true,
    );
  }

  // Move a card from tableau to free cell
  FreeCellState withMoveFromTableauToFreeCell(int fromColumn, int toCellIndex) {
    if (tableauCards[fromColumn].isEmpty || freeCells[toCellIndex] != null) {
      return this;
    }

    final card = tableauCards[fromColumn].last;
    final newTableauCards = [...tableauCards];
    newTableauCards[fromColumn] = [...tableauCards[fromColumn]]..removeLast();

    final newFreeCells = [...freeCells];
    newFreeCells[toCellIndex] = card;

    return copyWith(
      tableauCards: newTableauCards,
      freeCells: newFreeCells,
      canAutoMove: true,
    );
  }

  // Move a card from free cell to tableau
  FreeCellState withMoveFromFreeCellToTableau(int fromCellIndex, int toColumn) {
    final card = freeCells[fromCellIndex];

    if (card == null) {
      return this;
    }

    if (!canMoveToTableau([card], toColumn)) {
      return this;
    }

    final newFreeCells = [...freeCells];
    newFreeCells[fromCellIndex] = null;

    final newTableauCards = [...tableauCards];
    newTableauCards[toColumn] = [...tableauCards[toColumn], card];

    return copyWith(
      tableauCards: newTableauCards,
      freeCells: newFreeCells,
      canAutoMove: true,
    );
  }

  // Move a card from tableau to foundation
  FreeCellState withMoveFromTableauToFoundation(int fromColumn) {
    if (tableauCards[fromColumn].isEmpty) {
      return this;
    }

    final card = tableauCards[fromColumn].last;

    if (!canAddToFoundation(card)) {
      return this;
    }

    final newTableauCards = [...tableauCards];
    newTableauCards[fromColumn] = [...tableauCards[fromColumn]]..removeLast();

    final newFoundationCards = {
      ...foundationCards,
      card.suit: [...foundationCards[card.suit]!, card],
    };

    return copyWith(
      tableauCards: newTableauCards,
      foundationCards: newFoundationCards,
      canAutoMove: true,
    );
  }

  // Move a card from free cell to foundation
  FreeCellState withMoveFromFreeCellToFoundation(int fromCellIndex) {
    final card = freeCells[fromCellIndex];

    if (card == null || !canAddToFoundation(card)) {
      return this;
    }

    final newFreeCells = [...freeCells];
    newFreeCells[fromCellIndex] = null;

    final newFoundationCards = {
      ...foundationCards,
      card.suit: [...foundationCards[card.suit]!, card],
    };

    return copyWith(
      freeCells: newFreeCells,
      foundationCards: newFoundationCards,
      canAutoMove: true,
    );
  }

  // Move a card from one free cell to another free cell
  FreeCellState withMoveFromFreeCellToFreeCell(int fromCellIndex, int toCellIndex) {
    final card = freeCells[fromCellIndex];

    if (card == null || freeCells[toCellIndex] != null) {
      return this;
    }

    final newFreeCells = [...freeCells];
    newFreeCells[fromCellIndex] = null;
    newFreeCells[toCellIndex] = card;

    return copyWith(
      freeCells: newFreeCells,
      canAutoMove: true,
    );
  }

// Move a card from foundation to tableau
  FreeCellState withMoveFromFoundationToTableau(CardSuit suit, int toColumn) {
    final foundationPile = foundationCards[suit]!;

    if (foundationPile.isEmpty) {
      return this;
    }

    final card = foundationPile.last;

    if (!canMoveToTableau([card], toColumn)) {
      return this;
    }

    final newFoundationCards = {
      ...foundationCards,
      suit: [...foundationPile]..removeLast(),
    };

    final newTableauCards = [...tableauCards];
    newTableauCards[toColumn] = [...tableauCards[toColumn], card];

    return copyWith(
      tableauCards: newTableauCards,
      foundationCards: newFoundationCards,
      canAutoMove: false, // Set to false to prevent auto-move from moving it back
    );
  }

  // Update the withMove method to use the new group value types
  FreeCellState withMove(List<SuitedCard> cards, GroupValue fromValue, GroupValue toValue) {
    // Move from tableau to tableau
    if (fromValue is TableauGroupValue && toValue is TableauGroupValue) {
      return withMoveFromTableauToTableau(cards, fromValue.columnIndex, toValue.columnIndex);
    }

    // Move from tableau to free cell
    if (fromValue is TableauGroupValue && toValue is FreeCellGroupValue) {
      return withMoveFromTableauToFreeCell(fromValue.columnIndex, toValue.cellIndex);
    }

    // Move from free cell to tableau
    if (fromValue is FreeCellGroupValue && toValue is TableauGroupValue) {
      return withMoveFromFreeCellToTableau(fromValue.cellIndex, toValue.columnIndex);
    }

    // Move from free cell to free cell
    if (fromValue is FreeCellGroupValue && toValue is FreeCellGroupValue) {
      return withMoveFromFreeCellToFreeCell(fromValue.cellIndex, toValue.cellIndex);
    }

    // Move from tableau to foundation
    if (fromValue is TableauGroupValue && toValue is FoundationGroupValue) {
      return withMoveFromTableauToFoundation(fromValue.columnIndex);
    }

    // Move from free cell to foundation
    if (fromValue is FreeCellGroupValue && toValue is FoundationGroupValue) {
      return withMoveFromFreeCellToFoundation(fromValue.cellIndex);
    }

    // Move from foundation to tableau
    if (fromValue is FoundationGroupValue && toValue is TableauGroupValue) {
      return withMoveFromFoundationToTableau(fromValue.suit, toValue.columnIndex);
    }

    return this;
  }

  FreeCellState? withAutoMove(
      {TableauGroupValue? tableauGroup,
      FreeCellGroupValue? freeCellGroup,
      FoundationGroupValue? foundationGroup,
      int? cardIndexInTableau}) {
    // 1. If a specific tableau column was clicked
    if (tableauGroup != null) {
      final column = tableauCards[tableauGroup.columnIndex];

      // Empty column - nothing to do
      if (column.isEmpty) {
        return null;
      }

      // If a specific card in the stack was clicked (not just the top card)
      if (cardIndexInTableau != null && cardIndexInTableau < column.length - 1) {
        // Check if the subsequence is valid and within move size limits
        final subsequence = column.sublist(cardIndexInTableau);
        if (isValidSequence(subsequence) && subsequence.length <= maxMoveSize) {
          // Collect all valid destinations, separating empty and non-empty columns
          List<int> validNonEmptyColumns = [];
          List<int> validEmptyColumns = [];

          // Try to move this stack to each other tableau column
          for (int i = 0; i < tableauCards.length; i++) {
            if (i != tableauGroup.columnIndex && canMoveToTableau(subsequence, i)) {
              if (tableauCards[i].isEmpty) {
                validEmptyColumns.add(i);
              } else {
                validNonEmptyColumns.add(i);
              }
            }
          }

          // Prioritize non-empty columns
          if (validNonEmptyColumns.isNotEmpty) {
            return withMoveFromTableauToTableau(subsequence, tableauGroup.columnIndex, validNonEmptyColumns.first);
          }
          // Fall back to empty columns if necessary
          else if (validEmptyColumns.isNotEmpty) {
            return withMoveFromTableauToTableau(subsequence, tableauGroup.columnIndex, validEmptyColumns.first);
          }
        }
        return null;
      }

      // For top card clicks, we'll also prioritize non-empty columns
      final card = column.last;

      // 1a. Try to move to foundation if possible
      if (canAddToFoundation(card)) {
        return withMoveFromTableauToFoundation(tableauGroup.columnIndex);
      }

      // 1b. Try to move to another tableau column
      // Collect valid non-empty and empty destinations
      List<int> validNonEmptyColumns = [];
      List<int> validEmptyColumns = [];

      for (int i = 0; i < tableauCards.length; i++) {
        if (i != tableauGroup.columnIndex && canMoveToTableau([card], i)) {
          if (tableauCards[i].isEmpty) {
            validEmptyColumns.add(i);
          } else {
            validNonEmptyColumns.add(i);
          }
        }
      }

      // Prioritize non-empty columns
      if (validNonEmptyColumns.isNotEmpty) {
        return withMoveFromTableauToTableau([card], tableauGroup.columnIndex, validNonEmptyColumns.first);
      }
      // Fall back to empty columns
      else if (validEmptyColumns.isNotEmpty) {
        return withMoveFromTableauToTableau([card], tableauGroup.columnIndex, validEmptyColumns.first);
      }

      // 1c. Try to move to a free cell if possible
      for (int i = 0; i < freeCells.length; i++) {
        if (freeCells[i] == null) {
          return withMoveFromTableauToFreeCell(tableauGroup.columnIndex, i);
        }
      }
    }

    // 2. If a specific free cell was clicked
    else if (freeCellGroup != null) {
      final card = freeCells[freeCellGroup.cellIndex];
      if (card == null) {
        return null;
      }

      // 2a. Try to move to foundation if possible
      if (canAddToFoundation(card)) {
        return withMoveFromFreeCellToFoundation(freeCellGroup.cellIndex);
      }

      // 2b. Try to move to tableau if possible (with prioritization)
      List<int> validNonEmptyColumns = [];
      List<int> validEmptyColumns = [];

      for (int i = 0; i < tableauCards.length; i++) {
        if (canMoveToTableau([card], i)) {
          if (tableauCards[i].isEmpty) {
            validEmptyColumns.add(i);
          } else {
            validNonEmptyColumns.add(i);
          }
        }
      }

      // Prioritize non-empty columns
      if (validNonEmptyColumns.isNotEmpty) {
        return withMoveFromFreeCellToTableau(freeCellGroup.cellIndex, validNonEmptyColumns.first);
      }
      // Fall back to empty columns
      else if (validEmptyColumns.isNotEmpty) {
        return withMoveFromFreeCellToTableau(freeCellGroup.cellIndex, validEmptyColumns.first);
      }
    }

    // 3. If a foundation pile was clicked
    else if (foundationGroup != null) {
      final foundationPile = foundationCards[foundationGroup.suit]!;
      if (foundationPile.isEmpty) {
        return null;
      }

      final card = foundationPile.last;

      // 3a. Try to move to tableau if possible
      for (int i = 0; i < tableauCards.length; i++) {
        if (canMoveToTableau([card], i)) {
          return withMoveFromFoundationToTableau(foundationGroup.suit, i);
        }
      }
    }

    // 4. Global auto-move logic (no specific click)
    else {
      // Find the lowest foundation value across all suits
      final lowestFoundationValue =
          foundationCards.values.map((cards) => cards.isEmpty ? 0 : getCardValue(cards.last)).reduce(min);

      // Define safe auto-move threshold (lowest foundation value + 2)
      final safeAutoMoveThreshold = lowestFoundationValue + 2;

      // Check if a card is safe to auto-move to foundation
      bool isSafeToAutoMove(SuitedCard card) {
        return canAddToFoundation(card) && getCardValue(card) <= safeAutoMoveThreshold;
      }

      // Try to move from tableau to foundation (only if safe)
      for (int i = 0; i < tableauCards.length; i++) {
        if (tableauCards[i].isNotEmpty) {
          final card = tableauCards[i].last;
          if (isSafeToAutoMove(card)) {
            return withMoveFromTableauToFoundation(i);
          }
        }
      }

      // Try to move from free cells to foundation (only if safe)
      for (int i = 0; i < freeCells.length; i++) {
        final card = freeCells[i];
        if (card != null && isSafeToAutoMove(card)) {
          return withMoveFromFreeCellToFoundation(i);
        }
      }
    }

    return null;
  }

  // Undo move
  FreeCellState withUndo() {
    return history.last.copyWith(canAutoMove: false, saveNewStateToHistory: false);
  }

  // Check if game is won
  bool get isVictory => foundationCards.values.every((cards) => cards.length == 13);

  FreeCellState copyWith({
    List<List<SuitedCard>>? tableauCards,
    List<SuitedCard?>? freeCells,
    Map<CardSuit, List<SuitedCard>>? foundationCards,
    bool? canAutoMove,
    bool saveNewStateToHistory = true,
  }) {
    return FreeCellState(
      tableauCards: tableauCards ?? this.tableauCards,
      freeCells: freeCells ?? this.freeCells,
      foundationCards: foundationCards ?? this.foundationCards,
      canAutoMove: canAutoMove ?? this.canAutoMove,
      history: history + [if (saveNewStateToHistory) this],
    );
  }
}

class FreeCell extends HookWidget {
  final Difficulty difficulty;

  const FreeCell({super.key, required this.difficulty});

  FreeCellState get initialState => FreeCellState.getInitialState(
        freeCellCount: switch (difficulty) {
          Difficulty.classic => 4,
          Difficulty.royal || Difficulty.ace => 3,
        },
        acesAtBottom: difficulty == Difficulty.ace,
      );

  @override
  Widget build(BuildContext context) {
    final state = useState(initialState);

    return DelayedAutoMoveListener(
      stateGetter: () => state.value,
      nextStateGetter: (state) => state.canAutoMove ? state.withAutoMove() : null,
      onNewState: (newState) => state.value = newState,
      child: CardScaffold(
        game: Game.freeCell,
        difficulty: difficulty,
        onNewGame: () => state.value = initialState,
        onRestart: () => state.value = state.value.history.firstOrNull ?? state.value,
        onUndo: state.value.history.isEmpty ? null : () => state.value = state.value.withUndo(),
        isVictory: state.value.isVictory,
        builder: (context, constraints, gameKey) {
          final axis = constraints.largestAxis;
          final minSize = constraints.smallest.longestSide;
          final spacing = minSize / 100;

          final sizeMultiplier = constraints.findCardSizeMultiplier(
            maxRows: axis == Axis.horizontal ? 4 : 8,
            maxCols: axis == Axis.horizontal ? 8 : 2,
            spacing: spacing,
          );

          final cardOffset = sizeMultiplier * 25;

          return CardGame<SuitedCard, GroupValue>(
            gameKey: gameKey,
            style: playingCardStyle(sizeMultiplier: sizeMultiplier),
            children: [
              Flex(
                direction: axis.inverted,
                children: [
                  Flex(
                    direction: axis,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ...state.value.freeCells.mapIndexed((i, card) => CardDeck<SuitedCard, GroupValue>(
                            value: FreeCellGroupValue(i),
                            values: card == null ? [] : [card],
                            canGrab: true,
                            canMoveCardHere: (move) => move.cardValues.length == 1 && card == null,
                            onCardMovedHere: (move) => state.value =
                                state.value.withMove(move.cardValues, move.fromGroupValue, FreeCellGroupValue(i)),
                            onCardPressed: (card) {
                              // Use auto-move logic for free cell clicks
                              final newState = state.value.withAutoMove(freeCellGroup: FreeCellGroupValue(i));
                              if (newState != null) {
                                state.value = newState;
                              }
                            },
                          )),
                      ...List.filled(
                        4 - state.value.freeCells.length,
                        SizedBox.fromSize(size: Size(69, 93) * sizeMultiplier),
                      ),
                      SizedBox.square(dimension: spacing),
                      ...state.value.foundationCards.entries.map<Widget>((entry) => CardDeck<SuitedCard, GroupValue>(
                            value: FoundationGroupValue(entry.key),
                            values: entry.value,
                            canGrab: true,
                            canMoveCardHere: (move) =>
                                move.cardValues.length == 1 &&
                                canAddToFoundation(move.cardValues.first, entry.key, entry.value),
                            onCardMovedHere: (move) {
                              state.value = state.value
                                  .withMove(move.cardValues, move.fromGroupValue, FoundationGroupValue(entry.key));
                            },
                            onCardPressed: (card) {
                              // Use auto-move logic for foundation card clicks
                              final newState = state.value.withAutoMove(
                                foundationGroup: FoundationGroupValue(entry.key),
                              );
                              if (newState != null) {
                                state.value = newState;
                              }
                            },
                          )),
                    ],
                  ),
                  SizedBox.square(dimension: spacing),

                  // Tableau
                  Expanded(
                    child: Flex(
                      direction: axis,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List<Widget>.generate(
                        8,
                        (i) {
                          final columnCards = state.value.tableauCards[i];

                          return CardLinearGroup<SuitedCard, GroupValue>(
                            value: TableauGroupValue(i),
                            cardOffset: axis.inverted.offset * cardOffset,
                            maxGrabStackSize: state.value.maxMoveSize,
                            values: columnCards,
                            canCardBeGrabbed: (index, card) {
                              // Only check if this card and all cards below it form a valid sequence
                              // Don't check move size limits here - we want to allow dragging
                              final subsequence = columnCards.sublist(index);
                              return state.value.isValidSequence(subsequence);
                            },
                            canMoveCardHere: (move) => state.value.canMoveToTableau(move.cardValues, i),
                            onCardMovedHere: (move) => state.value =
                                state.value.withMove(move.cardValues, move.fromGroupValue, TableauGroupValue(i)),
                            onCardPressed: (card) {
                              final cardIndex = columnCards.indexOf(card);

                              // Try to auto-move the card and any valid sequence below it
                              final newState = state.value
                                  .withAutoMove(tableauGroup: TableauGroupValue(i), cardIndexInTableau: cardIndex);

                              if (newState != null) {
                                state.value = newState;
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper function for foundation validation
  static bool canAddToFoundation(SuitedCard card, CardSuit suit, List<SuitedCard> foundationPile) {
    if (card.suit != suit) return false;

    final cardValue = SuitedCardValueMapper.aceAsLowest.getValue(card);

    return foundationPile.isEmpty && card.value == AceSuitedCardValue() ||
        (foundationPile.isNotEmpty && SuitedCardValueMapper.aceAsLowest.getValue(foundationPile.last) + 1 == cardValue);
  }
}
