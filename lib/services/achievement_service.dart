import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solitaire/games/free_cell.dart';
import 'package:solitaire/games/golf_solitaire.dart';
import 'package:solitaire/games/solitaire.dart';
import 'package:solitaire/main.dart';
import 'package:solitaire/model/achievement.dart';
import 'package:solitaire/model/card_back.dart';
import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/game.dart';
import 'package:solitaire/providers/save_state_notifier.dart';
import 'package:utils/utils.dart';

part 'achievement_service.g.dart';

class AchievementService {
  final Ref ref;

  const AchievementService(this.ref);

  Future<void> checkGameCompletionAchievements({
    required Game game,
    required Difficulty difficulty,
    required Duration duration,
  }) async {
    final saveState = await ref.read(saveStateNotifierProvider.future);

    if (duration < Duration(minutes: 1)) {
      await _markAchievement(Achievement.speedDealer);
    }

    if (saveState.winStreak == 3) {
      await _markAchievement(Achievement.stackTheDeck);
    }

    if (saveState.gameStates.length == Game.values.length &&
        saveState.gameStates.values.every((gameState) => gameState.states[Difficulty.classic] != null)) {
      await _markAchievement(Achievement.fullHouse);
    }

    if (saveState.gameStates.length == Game.values.length &&
        saveState.gameStates.values.every((gameState) => gameState.states[Difficulty.royal] != null)) {
      await _markAchievement(Achievement.royalFlush);
    }

    if (saveState.gameStates.length == Game.values.length &&
        saveState.gameStates.values.every((gameState) => gameState.states[Difficulty.ace] != null)) {
      await _markAchievement(Achievement.aceUpYourSleeve);
    }
  }

  Future<void> checkGolfSolitaireMoveAchievements({required GolfSolitaireState state}) async {
    if (state.chain == 20) {
      await _markAchievement(Achievement.grandSlam);
    }
  }

  Future<void> checkGolfSolitaireCompletionAchievements({
    required GolfSolitaireState state,
    required Difficulty difficulty,
  }) async {
    if (difficulty == Difficulty.ace && state.deck.isNotEmpty) {
      await _markAchievement(Achievement.birdie);
    }
  }

  Future<void> checkFreeCellMoveAchievements({required FreeCellState state}) async {
    final completedFoundations = state.foundationCards.values.where((cards) => cards.length == 13).toList();
    final emptyFoundations = state.foundationCards
        .where((suit, cards) => cards.isEmpty && state.history.every((state) => state.foundationCards[suit]!.isEmpty))
        .values
        .toList();

    if (completedFoundations.length == 1 && emptyFoundations.length == 3) {
      await _markAchievement(Achievement.suitedUp);
    }
  }

  Future<void> checkSolitaireCompletionAchievements({
    required Difficulty difficulty,
    required SolitaireState state,
  }) async {
    if (difficulty == Difficulty.ace && !state.usedUndo) {
      await _markAchievement(Achievement.cleanSweep);
    }

    if (!state.restartedDeck) {
      await _markAchievement(Achievement.deckWhisperer);
    }
  }

  Future<void> checkFreeCellCompletionAchievements({
    required Difficulty difficulty,
    required FreeCellState state,
  }) async {
    if (difficulty == Difficulty.ace && !state.usedUndo) {
      await _markAchievement(Achievement.perfectPlanning);
    }
  }

  Future<void> deleteAchievement(Achievement achievement) async {
    final saveState = await ref.read(saveStateNotifierProvider.future);
    if (!saveState.achievements.contains(achievement)) {
      return;
    }

    await ref.read(saveStateNotifierProvider.notifier).deleteAchievement(achievement: achievement);

    final context = scaffoldMessengerKey.currentContext;
    if (context != null) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Achievement "${achievement.name}" Deleted!')),
      );
    }
  }

  Future<void> _markAchievement(Achievement achievement) async {
    final saveState = await ref.read(saveStateNotifierProvider.future);
    if (saveState.achievements.contains(achievement)) {
      return;
    }

    await ref.read(saveStateNotifierProvider.notifier).saveAchievement(achievement: achievement);

    final context = scaffoldMessengerKey.currentContext;
    if (context != null) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Row(
          spacing: 16,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.square(
                dimension: 48,
                child: CardBack.values.firstWhere((back) => back.achievementLock == achievement).build(),
              ),
            ),
            Text('Achievement "${achievement.name}" Unlocked!'),
          ],
        ),
      ));
    }
  }
}

@Riverpod(keepAlive: true)
AchievementService achievementService(Ref ref) => AchievementService(ref);
