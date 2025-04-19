import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solitaire/model/background.dart';
import 'package:solitaire/model/card_back.dart';
import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/game.dart';
import 'package:solitaire/model/save_state.dart';
import 'package:utils/utils.dart';

part 'save_state_notifier.g.dart';

const _saveStateKey = 'save';

@Riverpod(keepAlive: true)
class SaveStateNotifier extends _$SaveStateNotifier {
  @override
  FutureOr<SaveState> build() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final saveStateRaw = sharedPreferences.getString(_saveStateKey);
    final saveState = guard(() => saveStateRaw?.mapIfNonNull((raw) => SaveState.fromJson(jsonDecode(raw))));
    return saveState ?? SaveState.empty();
  }

  Future<void> saveGameCompleted({
    required Game game,
    required Difficulty difficulty,
    required Duration duration,
  }) async {
    final saveState = await future;
    await _saveState(saveState.withGameCompleted(game: game, difficulty: difficulty, duration: duration));
  }

  Future<void> saveGameStarted({
    required Game game,
    required Difficulty difficulty,
  }) async {
    final saveState = await future;
    await _saveState(saveState.withGameStarted(game: game, difficulty: difficulty));
  }

  Future<void> saveBackground({required Background background}) async {
    final saveState = await future;
    await _saveState(saveState.withBackground(background: background));
  }

  Future<void> saveCardBack({required CardBack cardBack}) async {
    final saveState = await future;
    await _saveState(saveState.withCardBack(cardBack: cardBack));
  }

  Future<void> saveVolume({required double volume}) async {
    final saveState = await future;
    await _saveState(saveState.withVolume(volume: volume));
  }

  Future<void> saveEnableAutoMove({required bool enableAutoMove}) async {
    final saveState = await future;
    await _saveState(saveState.withAutoMoveEnabled(enableAutoMove: enableAutoMove));
  }

  Future<void> saveCheatCode() async {
    final saveState = await future;
    await _saveState(saveState.withCheatCode());
  }

  Future<void> deleteAllData() async {
    await _saveState(SaveState.empty());
  }

  Future<void> _saveState(SaveState state) async {
    this.state = AsyncValue.data(state);
    final raw = jsonEncode(state.toJson());
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_saveStateKey, raw);
  }
}
