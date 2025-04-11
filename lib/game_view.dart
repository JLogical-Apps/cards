import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solitaire/providers/save_state_notifier.dart';

class GameView extends ConsumerWidget {
  final Widget cardGame;

  const GameView({super.key, required this.cardGame});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveState = ref.watch(saveStateNotifierProvider).valueOrNull;
    if (saveState == null) {
      return SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.green,
      body: Stack(
        children: [
          Positioned.fill(child: saveState.background.build()),
          cardGame,
        ],
      ),
    );
  }
}
