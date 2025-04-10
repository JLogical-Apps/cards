import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/game.dart';
import 'package:solitaire/model/save_state.dart';

part 'save_state_notifier.g.dart';

@Riverpod(keepAlive: true)
class SaveStateNotifier extends _$SaveStateNotifier {
  @override
  FutureOr<SaveState> build() async {
    return SaveState(gameStates: {});
  }

  Future<void> saveGameCompleted({
    required Game game,
    required Difficulty difficulty,
    required Duration duration,
  }) async {
    final saveState = await future;

    final newSaveState = saveState.withGameCompleted(game: game, difficulty: difficulty, duration: duration);
    state = AsyncValue.data(newSaveState);
  }
}
