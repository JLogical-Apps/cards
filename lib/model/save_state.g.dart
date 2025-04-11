// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveState _$SaveStateFromJson(Map<String, dynamic> json) => SaveState(
      gameStates: (json['gameStates'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$GameEnumMap, k),
            GameState.fromJson(e as Map<String, dynamic>)),
      ),
      lastGamePlayed:
          $enumDecodeNullable(_$GameEnumMap, json['lastGamePlayed']),
      lastPlayedGameDifficulties:
          (json['lastPlayedGameDifficulties'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry($enumDecode(_$GameEnumMap, k),
                    $enumDecode(_$DifficultyEnumMap, e)),
              ) ??
              {},
      background:
          $enumDecodeNullable(_$BackgroundEnumMap, json['background']) ??
              Background.green,
    );

Map<String, dynamic> _$SaveStateToJson(SaveState instance) => <String, dynamic>{
      'gameStates':
          instance.gameStates.map((k, e) => MapEntry(_$GameEnumMap[k]!, e)),
      'lastGamePlayed': _$GameEnumMap[instance.lastGamePlayed],
      'lastPlayedGameDifficulties': instance.lastPlayedGameDifficulties
          .map((k, e) => MapEntry(_$GameEnumMap[k]!, _$DifficultyEnumMap[e]!)),
      'background': _$BackgroundEnumMap[instance.background]!,
    };

const _$GameEnumMap = {
  Game.golf: 'golf',
  Game.klondike: 'klondike',
  Game.freeCell: 'freeCell',
};

const _$DifficultyEnumMap = {
  Difficulty.classic: 'classic',
  Difficulty.royal: 'royal',
  Difficulty.ace: 'ace',
};

const _$BackgroundEnumMap = {
  Background.green: 'green',
  Background.blue: 'blue',
  Background.blueGrey: 'blueGrey',
  Background.brown: 'brown',
  Background.grey: 'grey',
};
