import 'package:flutter_hooks/flutter_hooks.dart';

void useDelayedAutoMove<T>({
  bool enabled = true,
  required bool isUserInteracting,
  required Object gameKey,
  required T Function() stateGetter,
  required T? Function(T) nextStateGetter,
  required Function(T) onNewState,
  Duration gameStartDelay = const Duration(milliseconds: 1000),
  Duration initialDelay = const Duration(milliseconds: 800),
  Duration repeatingDelay = const Duration(milliseconds: 300),
}) {
  final gameStartTimeRef = useRef(DateTime.now());
  final interactionStartTimeRef = useRef(DateTime.now());

  bool canAutoMove() =>
      enabled &&
      !DateTime.now().isBefore(gameStartTimeRef.value) &&
      !DateTime.now().isBefore(interactionStartTimeRef.value);

  Future<void> startAutoMoveSequence() async {
    while (canAutoMove()) {
      var nextState = nextStateGetter(stateGetter());
      if (nextState == null) {
        return;
      }
      onNewState(nextState);
      await Future.delayed(repeatingDelay);
    }
  }

  useEffect(() {
    if (isUserInteracting) {
      interactionStartTimeRef.value = DateTime.now().add(initialDelay);
      final preparedTime = interactionStartTimeRef.value;
      () async {
        await Future.delayed(initialDelay);
        if (interactionStartTimeRef.value == preparedTime) {
          startAutoMoveSequence();
        }
      }();
    }
    return null;
  }, [isUserInteracting]);

  useEffect(() {
    gameStartTimeRef.value = DateTime.now().add(gameStartDelay);
    final preparedTime = interactionStartTimeRef.value;
    () async {
      await Future.delayed(gameStartDelay);
      if (interactionStartTimeRef.value == preparedTime) {
        startAutoMoveSequence();
      }
    }();
    return null;
  }, [gameKey]);
}
