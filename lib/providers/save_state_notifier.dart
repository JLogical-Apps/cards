import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    return saveState ?? SaveState(gameStates: {});
  }

  Future<void> saveGameCompleted({
    required Game game,
    required Difficulty difficulty,
    required Duration duration,
  }) async {
    final saveState = await future;

    final newSaveState = saveState.withGameCompleted(game: game, difficulty: difficulty, duration: duration);
    state = AsyncValue.data(newSaveState);

    final raw = jsonEncode(newSaveState.toJson());
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_saveStateKey, raw);
  }
}
