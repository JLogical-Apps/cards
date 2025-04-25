import 'dart:math';

import 'package:card_game/card_game.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solitaire/group/exposed_deck.dart';
import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/game.dart';
import 'package:solitaire/services/achievement_service.dart';
import 'package:solitaire/services/audio_service.dart';
import 'package:solitaire/styles/playing_card_asset_bundle_cache.dart';
import 'package:solitaire/styles/playing_card_style.dart';
import 'package:solitaire/utils/axis_extensions.dart';
import 'package:solitaire/utils/constraints_extensions.dart';
import 'package:solitaire/widgets/card_scaffold.dart';
import 'package:solitaire/widgets/delayed_auto_move_listener.dart';
import 'package:solitaire/widgets/game_tutorial.dart';
import 'package:utils/utils.dart';
import 'package:vector_graphics/vector_graphics.dart';

class SolitaireState {
  final int drawAmount;

  final List<List<SuitedCard>> hiddenCards;
  final List<List<SuitedCard>> revealedCards;
  final List<SuitedCard> deck;
  final List<SuitedCard> revealedDeck;
  final Map<CardSuit, List<SuitedCard>> completedCards;

  final bool usedUndo;
  final bool restartedDeck;
  final bool canAutoMove;
  final List<SolitaireState> history;

  SolitaireState({
    this.drawAmount = 1,
    required this.hiddenCards,
    required this.revealedCards,
    required this.deck,
    required this.revealedDeck,
    required this.completedCards,
    required this.usedUndo,
    required this.restartedDeck,
    required this.canAutoMove,
    required this.history,
  });

  static SolitaireState getInitialState({required int drawAmount, required bool acesAtBottom}) {
    var deck = SuitedCard.deck.shuffled();

    final aces = deck.where((card) => card.value == AceSuitedCardValue()).toList();
    if (acesAtBottom) {
      deck = deck.where((card) => card.value != AceSuitedCardValue()).toList();
    }

    final hiddenCards = List.generate(7, (i) {
      List<SuitedCard> column = [];

      if (acesAtBottom && i >= 3 && i < 7 && aces.isNotEmpty) {
        column.add(aces.removeAt(0));
        column.addAll(deck.take(i - 1));
        deck = deck.skip(i - 1).toList();
      } else {
        column = deck.take(i).toList();
        deck = deck.skip(i).toList();
      }

      return column;
    });

    final revealedCards = List.generate(7, (i) {
      final card = deck.first;
      deck = deck.skip(1).toList();
      return [card];
    });

    return SolitaireState(
      hiddenCards: hiddenCards,
      revealedCards: revealedCards,
      deck: deck,
      revealedDeck: [],
      completedCards: Map.fromEntries(CardSuit.values.map((suit) => MapEntry(suit, []))),
      history: [],
      usedUndo: false,
      restartedDeck: false,
      canAutoMove: true,
      drawAmount: drawAmount,
    );
  }

  SolitaireState withDrawOrRefresh() {
    return deck.isEmpty
        ? copyWith(
            deck: revealedDeck.reversed.toList(),
            revealedDeck: [],
            canAutoMove: true,
            restartedDeck: true,
          )
        : copyWith(
            deck: deck.sublist(0, max(0, deck.length - drawAmount)),
            revealedDeck: revealedDeck + deck.reversed.take(drawAmount).toList(),
            canAutoMove: true,
          );
  }

  int getCardValue(SuitedCard card) => SuitedCardValueMapper.aceAsLowest.getValue(card);

  SolitaireState withAutoTap(int column, List<SuitedCard> cards, {required Function() onSuccess}) {
    if (cards.length == 1 && canComplete(cards.first)) {
      onSuccess();
      return withAttemptToComplete(column);
    }

    final newColumn = List.generate(7, (i) => canMove(cards, i)).indexOf(true);
    if (newColumn == -1) {
      return this;
    }

    onSuccess();
    return withMoveFromColumn(cards, column, newColumn);
  }

  SolitaireState withAutoMoveFromDeck({required Function() onSuccess}) {
    final card = revealedDeck.last;
    if (canComplete(card)) {
      onSuccess();
      return withAttemptToCompleteFromDeck();
    }

    final newColumn = List.generate(7, (i) => canMove([card], i)).indexOf(true);
    if (newColumn == -1) {
      return this;
    }

    onSuccess();
    return withMoveFromDeck([card], newColumn);
  }

  SolitaireState withAutoMoveFromCompleted(CardSuit suit, {required Function() onSuccess}) {
    final card = completedCards[suit]!.last;

    final newColumn = List.generate(7, (i) => canMove([card], i)).indexOf(true);
    if (newColumn == -1) {
      return this;
    }

    onSuccess();
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
        canAutoMove: true,
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
        canAutoMove: true,
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
      canAutoMove: true,
    );
  }

  SolitaireState withMoveFromDeck(List<SuitedCard> cards, int newColumn) {
    final newRevealedCards = [...revealedCards];
    newRevealedCards[newColumn] = [...newRevealedCards[newColumn], ...cards];

    final newRevealedDeck = [...revealedDeck]..removeLast();

    return copyWith(
      revealedCards: newRevealedCards,
      revealedDeck: newRevealedDeck,
      canAutoMove: true,
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
      canAutoMove: false,
    );
  }

  SolitaireState withUndo() {
    return history.last.copyWith(
      canAutoMove: false,
      saveNewStateToHistory: false,
      usedUndo: true,
    );
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
    bool? usedUndo,
    bool? restartedDeck,
    bool? canAutoMove,
    bool saveNewStateToHistory = true,
  }) {
    return SolitaireState(
      hiddenCards: hiddenCards ?? this.hiddenCards,
      revealedCards: revealedCards ?? this.revealedCards,
      deck: deck ?? this.deck,
      revealedDeck: revealedDeck ?? this.revealedDeck,
      completedCards: completedCards ?? this.completedCards,
      drawAmount: drawAmount,
      usedUndo: usedUndo ?? this.usedUndo,
      restartedDeck: restartedDeck ?? this.restartedDeck,
      canAutoMove: canAutoMove ?? this.canAutoMove,
      history: history + [if (saveNewStateToHistory) this],
    );
  }
}

class Solitaire extends HookConsumerWidget {
  final Difficulty difficulty;
  final bool startWithTutorial;

  const Solitaire({super.key, required this.difficulty, this.startWithTutorial = false});

  int get drawAmount => switch (difficulty) {
        Difficulty.classic => 1,
        Difficulty.royal || Difficulty.ace => 3,
      };

  SolitaireState get initialState => SolitaireState.getInitialState(
        drawAmount: drawAmount,
        acesAtBottom: difficulty == Difficulty.ace,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = useState(initialState);

    final tableauKey = useMemoized(() => GlobalKey());
    final foundationKey = useMemoized(() => GlobalKey());
    final drawPileKey = useMemoized(() => GlobalKey());
    final wastePileKey = useMemoized(() => GlobalKey());

    void startTutorial() {
      showGameTutorial(
        context,
        screens: [
          TutorialScreen.key(
            key: tableauKey,
            message:
                'Welcome to Solitaire! The tableau contains seven piles of cards. Only the top card of each pile is face-up. Build down in alternating colors (red on black, black on red) in descending order.',
          ),
          TutorialScreen.key(
            key: foundationKey,
            message:
                'Your goal is to build four foundation piles, one for each suit, from Ace to King. Move Aces here first, then build up in suit order.',
          ),
          TutorialScreen.key(key: drawPileKey, message: 'When you need more cards, tap the draw pile to flip cards.'),
          TutorialScreen.key(
            key: wastePileKey,
            message:
                'Cards drawn from the draw pile appear here. The top card can be played to the tableau or foundations.',
          ),
          TutorialScreen.everything(
            message:
                'Win by moving all cards to the foundations. You can move groups of properly sequenced cards between tableau piles. Empty tableau spaces can only be filled with Kings. Tap to begin playing!',
          ),
        ],
      );
    }

    useOneTimeEffect(() {
      if (startWithTutorial) {
        Future.delayed(Duration(milliseconds: 200)).then((_) => startTutorial());
      }
      return null;
    });

    return CardScaffold(
      game: Game.klondike,
      difficulty: difficulty,
      onNewGame: () => state.value = initialState,
      onRestart: () => state.value = (state.value.history.firstOrNull ?? state.value).copyWith(usedUndo: false),
      onTutorial: startTutorial,
      onUndo: state.value.history.isEmpty ? null : () => state.value = state.value.withUndo(),
      isVictory: state.value.isVictory,
      onVictory: () => ref
          .read(achievementServiceProvider)
          .checkSolitaireCompletionAchievements(state: state.value, difficulty: difficulty),
      builder: (context, constraints, cardBack, autoMoveEnabled, gameKey) {
        final axis = constraints.largestAxis;
        final minSize = constraints.smallest.longestSide;
        final spacing = minSize / 100;

        final sizeMultiplier = constraints.findCardSizeMultiplier(
          maxRows: axis == Axis.horizontal ? 4 : 7,
          maxCols: axis == Axis.horizontal ? 10 : 2,
          spacing: spacing,
        );

        final cardOffset = sizeMultiplier * 25;

        final hiddenDeck = GestureDetector(
          key: drawPileKey,
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (state.value.deck.isEmpty) {
              ref.read(audioServiceProvider).playRedraw();
            } else {
              ref.read(audioServiceProvider).playDraw();
            }
            state.value = state.value.withDrawOrRefresh();
          },
          child: CardDeck<SuitedCard, dynamic>.flipped(
            value: 'deck',
            values: state.value.deck,
          ),
        );
        final exposedDeck = ExposedCardDeck<SuitedCard, dynamic>(
          key: wastePileKey,
          value: 'revealed-deck',
          values: state.value.revealedDeck,
          amountExposed: drawAmount,
          overlayOffset: Offset(0, 1) * cardOffset,
          canMoveCardHere: (_) => false,
          onCardPressed: (_) {
            state.value = state.value.withAutoMoveFromDeck(onSuccess: () => ref.read(audioServiceProvider).playPlace());
          },
          canGrab: true,
        );

        final completedDecks = state.value.completedCards.entries
            .map((entry) => CardDeck<SuitedCard, dynamic>(
                  value: entry.key,
                  values: entry.value,
                  canGrab: true,
                  onCardPressed: (card) => state.value = state.value.withAutoMoveFromCompleted(
                    entry.key,
                    onSuccess: () => ref.read(audioServiceProvider).playPlace(),
                  ),
                ))
            .toList();

        return DelayedAutoMoveListener(
          enabled: autoMoveEnabled,
          stateGetter: () => state.value,
          nextStateGetter: (state) => state.canAutoMove ? state.withAutoMove() : null,
          onNewState: (newState) {
            ref.read(audioServiceProvider).playPlace();
            state.value = newState;
          },
          gameKey: gameKey,
          child: CardGame<SuitedCard, dynamic>(
            gameKey: gameKey,
            style: playingCardStyle(
              sizeMultiplier: sizeMultiplier,
              cardBack: cardBack,
              emptyGroupOverlayBuilder: (group) => group is CardSuit
                  ? VectorGraphic(
                      loader: PlayingCardAssetBundleCache.getSuitLoader(group),
                      colorFilter: ColorFilter.mode(Colors.white30, BlendMode.srcIn),
                    )
                  : null,
            ),
            children: [
              Row(
                children: [
                  if (axis == Axis.horizontal) ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: spacing,
                      children: [
                        hiddenDeck,
                        exposedDeck,
                      ],
                    ),
                    SizedBox(width: spacing),
                  ],
                  Expanded(
                    child: Flex(
                        key: tableauKey,
                        direction: axis,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: spacing,
                        children: List<Widget>.generate(7, (i) {
                          final hiddenCards = state.value.hiddenCards[i];
                          final revealedCards = state.value.revealedCards[i];

                          return CardLinearGroup<SuitedCard, dynamic>(
                            value: i,
                            cardOffset: axis.inverted.offset * cardOffset,
                            maxGrabStackSize: null,
                            values: hiddenCards + revealedCards,
                            canCardBeGrabbed: (_, card) => revealedCards.contains(card),
                            isCardFlipped: (_, card) => hiddenCards.contains(card),
                            onCardPressed: (card) {
                              if (hiddenCards.contains(card)) {
                                return;
                              }

                              final cardIndex = revealedCards.indexOf(card);

                              state.value = state.value.withAutoTap(
                                i,
                                revealedCards.sublist(cardIndex),
                                onSuccess: () => ref.read(audioServiceProvider).playPlace(),
                              );
                            },
                            canMoveCardHere: (move) => state.value.canMove(move.cardValues, i),
                            onCardMovedHere: (move) {
                              ref.read(audioServiceProvider).playPlace();
                              state.value = state.value.withMove(move.cardValues, move.fromGroupValue, i);
                            },
                          );
                        }).toList()),
                  ),
                  SizedBox(width: spacing),
                  if (axis == Axis.vertical)
                    Column(
                      spacing: spacing,
                      children: [
                        hiddenDeck,
                        exposedDeck,
                        Spacer(),
                        Column(
                          key: foundationKey,
                          spacing: spacing,
                          children: completedDecks,
                        ),
                      ],
                    )
                  else
                    Column(
                      key: foundationKey,
                      spacing: spacing,
                      children: completedDecks,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
