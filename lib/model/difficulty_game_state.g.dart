// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'difficulty_game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DifficultyGameState _$DifficultyGameStateFromJson(Map<String, dynamic> json) =>
    DifficultyGameState(
      gamesWon: (json['gamesWon'] as num).toInt(),
      fastestGame: Duration(microseconds: (json['fastestGame'] as num).toInt()),
    );

Map<String, dynamic> _$DifficultyGameStateToJson(
        DifficultyGameState instance) =>
    <String, dynamic>{
      'gamesWon': instance.gamesWon,
      'fastestGame': instance.fastestGame.inMicroseconds,
    };
