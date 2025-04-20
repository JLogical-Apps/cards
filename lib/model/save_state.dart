import 'package:json_annotation/json_annotation.dart';
import 'package:solitaire/model/achievement.dart';
import 'package:solitaire/model/background.dart';
import 'package:solitaire/model/card_back.dart';
import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/difficulty_game_state.dart';
import 'package:solitaire/model/game.dart';
import 'package:solitaire/model/game_state.dart';
import 'package:utils/utils.dart';

part 'save_state.g.dart';

@JsonSerializable()
class SaveState {
  final Map<Game, GameState> gameStates;

  @JsonKey(defaultValue: <Achievement>{})
  final Set<Achievement> achievements;

  final Game? lastGamePlayed;

  @JsonKey(defaultValue: {})
  final Map<Game, Difficulty> lastPlayedGameDifficulties;

  @JsonKey(defaultValue: 0)
  final int winStreak;

  @JsonKey(defaultValue: Background.green)
  final Background background;

  @JsonKey(defaultValue: CardBack.redStripes)
  final CardBack cardBack;

  @JsonKey(defaultValue: 1.0)
  final double volume;

  @JsonKey(defaultValue: true)
  final bool enableAutoMove;

  const SaveState({
    required this.gameStates,
    required this.achievements,
    required this.lastGamePlayed,
    required this.lastPlayedGameDifficulties,
    required this.winStreak,
    required this.background,
    required this.cardBack,
    required this.volume,
    required this.enableAutoMove,
  });

  const SaveState.empty()
      : gameStates = const {},
        achievements = const {},
        lastGamePlayed = null,
        lastPlayedGameDifficulties = const {},
        winStreak = 0,
        background = Background.green,
        cardBack = CardBack.redStripes,
        volume = 1,
        enableAutoMove = true;

  factory SaveState.fromJson(Map<String, dynamic> json) => _$SaveStateFromJson(json);
  Map<String, dynamic> toJson() => _$SaveStateToJson(this);

  GameState getOrDefault(Game game) => gameStates[game] ?? GameState(states: {});

  SaveState withGameCompleted({
    required Game game,
    required Difficulty difficulty,
    required Duration duration,
  }) =>
      copyWith(
        gameStates: {
          ...gameStates,
          game: getOrDefault(game).withCompleted(difficulty: difficulty, duration: duration),
        },
        winStreak: winStreak + 1,
      );

  SaveState withGameStarted({required Game game, required Difficulty difficulty}) => copyWith(
        lastGamePlayed: game,
        lastPlayedGameDifficulties: {
          ...lastPlayedGameDifficulties,
          game: difficulty,
        },
      );

  SaveState withCloseOrRestart() => copyWith(winStreak: 0);

  SaveState withBackground({required Background background}) => copyWith(background: background);
  SaveState withCardBack({required CardBack cardBack}) => copyWith(cardBack: cardBack);
  SaveState withVolume({required double volume}) => copyWith(volume: volume);
  SaveState withAutoMoveEnabled({required bool enableAutoMove}) => copyWith(enableAutoMove: enableAutoMove);
  SaveState withAchievement({required Achievement achievement}) =>
      copyWith(achievements: {...achievements, achievement});

  SaveState withCheatCode() => copyWith(
        gameStates: Game.values.mapToMap((value) => MapEntry(
              value,
              GameState(
                states: Difficulty.values.mapToMap(
                  (difficulty) => MapEntry(
                    difficulty,
                    DifficultyGameState(fastestGame: Duration(minutes: 5), gamesWon: 1),
                  ),
                ),
              ),
            )),
        // achievements: Achievement.values.toSet(),
      );

  SaveState copyWith({
    Map<Game, GameState>? gameStates,
    Set<Achievement>? achievements,
    Game? lastGamePlayed,
    Map<Game, Difficulty>? lastPlayedGameDifficulties,
    int? winStreak,
    Background? background,
    CardBack? cardBack,
    double? volume,
    bool? enableAutoMove,
  }) {
    return SaveState(
      gameStates: gameStates ?? this.gameStates,
      achievements: achievements ?? this.achievements,
      lastGamePlayed: lastGamePlayed ?? this.lastGamePlayed,
      lastPlayedGameDifficulties: lastPlayedGameDifficulties ?? this.lastPlayedGameDifficulties,
      winStreak: winStreak ?? this.winStreak,
      background: background ?? this.background,
      cardBack: cardBack ?? this.cardBack,
      volume: volume ?? this.volume,
      enableAutoMove: enableAutoMove ?? this.enableAutoMove,
    );
  }
}
