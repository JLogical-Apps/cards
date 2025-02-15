import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:solitaire/context/card_game_context.dart';
import 'package:solitaire/hooks/hooks.dart';

class DelayedAutoMoveListener<T> extends HookWidget {
  final Widget child;
  final bool enabled;
  final T Function() stateGetter;
  final T? Function(T state) nextStateGetter;
  final Function(T) onNewState;

  const DelayedAutoMoveListener({
    super.key,
    required this.child,
    this.enabled = true,
    required this.stateGetter,
    required this.nextStateGetter,
    required this.onNewState,
  });

  @override
  Widget build(BuildContext context) {
    final cardGameContext = context.watch<CardGameContext?>();
    final isPreview = cardGameContext?.isPreview ?? false;

    final isUserInteractingState = useState(false);
    useDelayedAutoMove(
      enabled: !isPreview,
      isUserInteracting: isUserInteractingState.value,
      stateGetter: stateGetter,
      nextStateGetter: nextStateGetter,
      onNewState: onNewState,
    );

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerCancel: (event) => isUserInteractingState.value = false,
      onPointerUp: (event) => isUserInteractingState.value = false,
      onPointerDown: (event) => isUserInteractingState.value = true,
      child: child,
    );
  }
}
