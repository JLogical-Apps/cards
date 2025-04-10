import 'package:json_annotation/json_annotation.dart';
import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/game.dart';
import 'package:solitaire/model/game_state.dart';

part 'save_state.g.dart';

@JsonSerializable()
class SaveState {
  final Map<Game, GameState> gameStates;

  const SaveState({required this.gameStates});

  factory SaveState.fromJson(Map<String, dynamic> json) => _$SaveStateFromJson(json);
  Map<String, dynamic> toJson() => _$SaveStateToJson(this);

  GameState getOrDefault(Game game) => gameStates[game] ?? GameState(states: {});

  SaveState withGameCompleted({
    required Game game,
    required Difficulty difficulty,
    required Duration duration,
  }) {
    return SaveState(gameStates: {
      ...gameStates,
      game: getOrDefault(game).withCompleted(difficulty: difficulty, duration: duration),
    });
  }
}
