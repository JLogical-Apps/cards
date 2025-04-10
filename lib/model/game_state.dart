import 'package:json_annotation/json_annotation.dart';
import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/difficulty_game_state.dart';
import 'package:solitaire/utils/duration_extensions.dart';

part 'game_state.g.dart';

@JsonSerializable()
class GameState {
  final Map<Difficulty, DifficultyGameState> states;

  const GameState({required this.states});

  factory GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);
  Map<String, dynamic> toJson() => _$GameStateToJson(this);

  DifficultyGameState? operator [](Difficulty difficulty) => states[difficulty];

  GameState withCompleted({
    required Difficulty difficulty,
    required Duration duration,
  }) {
    final existingGameState = states[difficulty];

    return GameState(
      states: {
        ...states,
        difficulty: DifficultyGameState(
          gamesWon: (existingGameState?.gamesWon ?? 0) + 1,
          fastestGame: [if (existingGameState != null) existingGameState.fastestGame, duration].shortest,
        ),
      },
    );
  }
}
