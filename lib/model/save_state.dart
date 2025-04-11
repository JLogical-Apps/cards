import 'package:json_annotation/json_annotation.dart';
import 'package:solitaire/model/background.dart';
import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/game.dart';
import 'package:solitaire/model/game_state.dart';

part 'save_state.g.dart';

@JsonSerializable()
class SaveState {
  final Map<Game, GameState> gameStates;

  final Game? lastGamePlayed;

  @JsonKey(defaultValue: {})
  final Map<Game, Difficulty> lastPlayedGameDifficulties;

  @JsonKey(defaultValue: Background.green)
  final Background background;

  const SaveState({
    required this.gameStates,
    required this.lastGamePlayed,
    required this.lastPlayedGameDifficulties,
    required this.background,
  });

  const SaveState.empty()
      : gameStates = const {},
        lastGamePlayed = null,
        lastPlayedGameDifficulties = const {},
        background = Background.green;

  factory SaveState.fromJson(Map<String, dynamic> json) => _$SaveStateFromJson(json);
  Map<String, dynamic> toJson() => _$SaveStateToJson(this);

  GameState getOrDefault(Game game) => gameStates[game] ?? GameState(states: {});

  SaveState withGameCompleted({
    required Game game,
    required Difficulty difficulty,
    required Duration duration,
  }) {
    return copyWith(
      gameStates: {
        ...gameStates,
        game: getOrDefault(game).withCompleted(difficulty: difficulty, duration: duration),
      },
    );
  }

  SaveState withGameStarted({required Game game, required Difficulty difficulty}) {
    return copyWith(
      lastGamePlayed: game,
      lastPlayedGameDifficulties: {
        ...lastPlayedGameDifficulties,
        game: difficulty,
      },
    );
  }

  SaveState withBackground({required Background background}) => copyWith(background: background);

  SaveState copyWith({
    Map<Game, GameState>? gameStates,
    Game? lastGamePlayed,
    Map<Game, Difficulty>? lastPlayedGameDifficulties,
    Background? background,
  }) {
    return SaveState(
      gameStates: gameStates ?? this.gameStates,
      lastGamePlayed: lastGamePlayed ?? this.lastGamePlayed,
      lastPlayedGameDifficulties: lastPlayedGameDifficulties ?? this.lastPlayedGameDifficulties,
      background: background ?? this.background,
    );
  }
}
