// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameState _$GameStateFromJson(Map<String, dynamic> json) => GameState(
      states: (json['states'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$DifficultyEnumMap, k),
            DifficultyGameState.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
      'states':
          instance.states.map((k, e) => MapEntry(_$DifficultyEnumMap[k]!, e)),
    };

const _$DifficultyEnumMap = {
  Difficulty.classic: 'classic',
  Difficulty.royal: 'royal',
  Difficulty.ace: 'ace',
};
