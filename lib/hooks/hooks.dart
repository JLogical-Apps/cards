import 'package:flutter_hooks/flutter_hooks.dart';

void useDelayedAutoMove<T>({
  bool enabled = true,
  required bool isUserInteracting,
  required T Function() stateGetter,
  required T? Function(T) nextStateGetter,
  required Function(T) onNewState,
  Duration initialDelay = const Duration(milliseconds: 500),
  Duration repeatingDelay = const Duration(milliseconds: 300),
}) {
  final isProcessing = useState(false);
  final shouldStopState = useState(false);

  useEffect(() {
    if (isUserInteracting) {
      shouldStopState.value = true;
    }
    return null;
  }, [isUserInteracting]);

  useEffect(() {
    if (isProcessing.value || !enabled) {
      return null;
    }

    if (shouldStopState.value) {
      shouldStopState.value = false;
      return null;
    }

    isProcessing.value = true;

    () async {
      await Future.delayed(initialDelay);
      while (true) {
        if (shouldStopState.value) {
          shouldStopState.value = false;
          isProcessing.value = false;
          return;
        }

        final state = stateGetter();
        final nextState = nextStateGetter(state);
        if (nextState == null) {
          isProcessing.value = false;
          return;
        }

        onNewState(nextState);
        await Future.delayed(repeatingDelay);
      }
    }();

    return null;
  }, [stateGetter(), shouldStopState.value]);
}
