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
    );

Map<String, dynamic> _$SaveStateToJson(SaveState instance) => <String, dynamic>{
      'gameStates':
          instance.gameStates.map((k, e) => MapEntry(_$GameEnumMap[k]!, e)),
    };

const _$GameEnumMap = {
  Game.golf: 'golf',
  Game.klondike: 'klondike',
  Game.freeCell: 'freeCell',
};
