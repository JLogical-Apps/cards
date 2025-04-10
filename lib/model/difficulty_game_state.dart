import 'package:json_annotation/json_annotation.dart';

part 'difficulty_game_state.g.dart';

@JsonSerializable()
class DifficultyGameState {
  final int gamesWon;
  final Duration fastestGame;

  const DifficultyGameState({required this.gamesWon, required this.fastestGame});

  factory DifficultyGameState.fromJson(Map<String, dynamic> json) => _$DifficultyGameStateFromJson(json);
  Map<String, dynamic> toJson() => _$DifficultyGameStateToJson(this);
}
