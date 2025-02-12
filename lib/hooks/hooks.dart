import 'package:flutter_hooks/flutter_hooks.dart';

void useDelayedAutoMove<T>({
  required bool isUserInteracting,
  required T Function() stateGetter,
  required T? Function(T) nextStateGetter,
  required Function(T) onNewState,
  Duration initialDelay = const Duration(milliseconds: 500),
  Duration repeatingDelay = const Duration(milliseconds: 300),
}) {
  final isProcessing = useState(false);
  useEffect(() {
    if (isUserInteracting || isProcessing.value) {
      return null;
    }

    final timer = Future.delayed(initialDelay, () async {
      isProcessing.value = true;

      while (true) {
        final state = stateGetter();
        final nextState = nextStateGetter(state);
        if (nextState == null) {
          isProcessing.value = false;
          break;
        }

        onNewState(nextState);
        await Future.delayed(repeatingDelay);
      }
    });

    return () => timer.ignore();
  }, [stateGetter(), isUserInteracting]);
}
