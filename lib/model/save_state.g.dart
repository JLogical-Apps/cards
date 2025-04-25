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
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$AchievementEnumMap, e))
              .toSet() ??
          {},
      lastGamePlayed:
          $enumDecodeNullable(_$GameEnumMap, json['lastGamePlayed']),
      lastPlayedGameDifficulties:
          (json['lastPlayedGameDifficulties'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry($enumDecode(_$GameEnumMap, k),
                    $enumDecode(_$DifficultyEnumMap, e)),
              ) ??
              {},
      winStreak: (json['winStreak'] as num?)?.toInt() ?? 0,
      background:
          $enumDecodeNullable(_$BackgroundEnumMap, json['background']) ??
              Background.green,
      cardBack: $enumDecodeNullable(_$CardBackEnumMap, json['cardBack']) ??
          CardBack.redStripes,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      enableAutoMove: json['enableAutoMove'] as bool? ?? true,
    );

Map<String, dynamic> _$SaveStateToJson(SaveState instance) => <String, dynamic>{
      'gameStates':
          instance.gameStates.map((k, e) => MapEntry(_$GameEnumMap[k]!, e)),
      'achievements':
          instance.achievements.map((e) => _$AchievementEnumMap[e]!).toList(),
      'lastGamePlayed': _$GameEnumMap[instance.lastGamePlayed],
      'lastPlayedGameDifficulties': instance.lastPlayedGameDifficulties
          .map((k, e) => MapEntry(_$GameEnumMap[k]!, _$DifficultyEnumMap[e]!)),
      'winStreak': instance.winStreak,
      'background': _$BackgroundEnumMap[instance.background]!,
      'cardBack': _$CardBackEnumMap[instance.cardBack]!,
      'volume': instance.volume,
      'enableAutoMove': instance.enableAutoMove,
    };

const _$GameEnumMap = {
  Game.golf: 'golf',
  Game.klondike: 'klondike',
  Game.freeCell: 'freeCell',
};

const _$AchievementEnumMap = {
  Achievement.fullHouse: 'fullHouse',
  Achievement.royalFlush: 'royalFlush',
  Achievement.speedDealer: 'speedDealer',
  Achievement.grandSlam: 'grandSlam',
  Achievement.suitedUp: 'suitedUp',
  Achievement.stackTheDeck: 'stackTheDeck',
  Achievement.deckWhisperer: 'deckWhisperer',
  Achievement.aceUpYourSleeve: 'aceUpYourSleeve',
  Achievement.birdie: 'birdie',
  Achievement.cleanSweep: 'cleanSweep',
  Achievement.perfectPlanning: 'perfectPlanning',
};

const _$DifficultyEnumMap = {
  Difficulty.classic: 'classic',
  Difficulty.royal: 'royal',
  Difficulty.ace: 'ace',
};

const _$BackgroundEnumMap = {
  Background.green: 'green',
  Background.blue: 'blue',
  Background.slate: 'slate',
  Background.grey: 'grey',
};

const _$CardBackEnumMap = {
  CardBack.redStripes: 'redStripes',
  CardBack.stoneStripes: 'stoneStripes',
  CardBack.skyStripes: 'skyStripes',
  CardBack.violetStripes: 'violetStripes',
  CardBack.redPoly: 'redPoly',
  CardBack.stonePoly: 'stonePoly',
  CardBack.skyPoly: 'skyPoly',
  CardBack.violetPoly: 'violetPoly',
  CardBack.redSteps: 'redSteps',
  CardBack.stoneSteps: 'stoneSteps',
  CardBack.skySteps: 'skySteps',
  CardBack.violetSteps: 'violetSteps',
};
