import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/difficulty_game_state.dart';
import 'package:solitaire/utils/duration_extensions.dart';

class GameState {
  final Map<Difficulty, DifficultyGameState> states;

  const GameState({required this.states});

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
