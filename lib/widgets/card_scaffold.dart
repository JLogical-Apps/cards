import 'dart:math';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:solitaire/context/card_game_context.dart';
import 'package:solitaire/home_page.dart';
import 'package:solitaire/model/card_back.dart';
import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/game.dart';
import 'package:solitaire/providers/save_state_notifier.dart';
import 'package:solitaire/utils/audio.dart';
import 'package:solitaire/utils/build_context_extensions.dart';
import 'package:solitaire/utils/constraints_extensions.dart';
import 'package:solitaire/utils/duration_extensions.dart';
import 'package:utils/utils.dart';

class CardScaffold extends HookConsumerWidget {
  final Game game;
  final Difficulty difficulty;

  final Widget Function(BuildContext, BoxConstraints, CardBack, Object gameKey) builder;

  final Function() onNewGame;
  final Function() onRestart;
  final Function()? onUndo;

  final bool isVictory;

  const CardScaffold({
    super.key,
    required this.game,
    required this.difficulty,
    required this.builder,
    required this.onNewGame,
    required this.onRestart,
    required this.onUndo,
    this.isVictory = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardGameContext = context.watch<CardGameContext?>();
    final isPreview = cardGameContext?.isPreview ?? false;

    final startTimeState = useState(DateTime.now());
    final currentTimeState = useState(DateTime.now());

    final saveState = ref.watch(saveStateNotifierProvider).valueOrNull;

    useEffect(() {
      if (isVictory) {
        Audio.playWin();
        ref.read(saveStateNotifierProvider.notifier).saveGameCompleted(
              game: game,
              difficulty: difficulty,
              duration: currentTimeState.value.difference(startTimeState.value),
            );
      }
      return null;
    }, [isVictory]);

    useEffect(() {
      if (!isPreview) Audio.playRedraw();
      return null;
    }, [startTimeState.value]);

    useListen(useMemoized(
      () => Stream.periodic(
        Duration(milliseconds: 480),
        (_) {
          if (!isVictory && !isPreview) {
            currentTimeState.value = DateTime.now();
          }
        },
      ),
      [isVictory],
    ));

    final confettiController = useMemoized(() => ConfettiController(duration: Duration(milliseconds: 50))..play());
    useEffect(() => () => confettiController.dispose(), []);

    if (isVictory) {
      confettiController.play();
    } else {
      confettiController.stop();
    }

    if (saveState == null) {
      return SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final axis = constraints.largestAxis;

        return Stack(
          children: [
            Column(
              children: [
                if (!isPreview && axis == Axis.horizontal)
                  Container(
                    height: max(MediaQuery.paddingOf(context).top + 32, 48),
                    alignment: Alignment.center,
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Tooltip(
                              message: 'Menu',
                              child: MenuAnchor(
                                builder: (context, controller, child) {
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(alpha: 0.5),
                                    ),
                                    onPressed: () => controller.open(),
                                    child: Icon(Icons.menu),
                                  );
                                },
                                menuChildren: [
                                  MenuItemButton(
                                    leadingIcon: Icon(Icons.star_border),
                                    onPressed: () {
                                      startTimeState.value = DateTime.now();
                                      onNewGame();
                                    },
                                    child: Text('New Game'),
                                  ),
                                  MenuItemButton(
                                    leadingIcon: Icon(Icons.restart_alt),
                                    onPressed: () {
                                      startTimeState.value = DateTime.now();
                                      onRestart();
                                    },
                                    child: Text('Restart Game'),
                                  ),
                                  MenuItemButton(
                                    leadingIcon: Icon(Icons.close),
                                    onPressed: () => context.pushReplacement(() => HomePage()),
                                    child: Text('Close'),
                                  ),
                                ],
                              ),
                            ),
                            Tooltip(
                              message: 'Undo',
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.5)),
                                onPressed: isVictory
                                    ? null
                                    : () {
                                        Audio.playUndo();
                                        onUndo?.call();
                                      },
                                child: Icon(Icons.undo),
                              ),
                            ),
                            Text(
                              currentTimeState.value.difference(startTimeState.value).format(),
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: SafeArea(
                    bottom: axis == Axis.vertical,
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 1080),
                        child: LayoutBuilder(
                          builder: (context, constraints) => builder(
                            context,
                            constraints,
                            saveState.cardBack,
                            startTimeState.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isPreview && axis == Axis.vertical)
                  Container(
                    height: max(MediaQuery.paddingOf(context).bottom + 32, 48),
                    color: Colors.white.withValues(alpha: 0.2),
                    alignment: Alignment.center,
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Tooltip(
                              message: 'Menu',
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.5)),
                                onPressed: () async {
                                  await showAdaptiveActionSheet(
                                    context: context,
                                    actions: [
                                      BottomSheetAction(
                                        title: Text('New Game'),
                                        leading: Icon(Icons.star_border),
                                        onPressed: (context) {
                                          startTimeState.value = DateTime.now();
                                          onNewGame();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      BottomSheetAction(
                                        title: Text('Restart Game'),
                                        leading: Icon(Icons.restart_alt),
                                        onPressed: (_) {
                                          startTimeState.value = DateTime.now();
                                          onRestart();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      BottomSheetAction(
                                        title: Text('Close'),
                                        leading: Icon(Icons.close),
                                        onPressed: (_) {
                                          Navigator.of(context).pop();
                                          context.pushReplacement(() => HomePage());
                                        },
                                      ),
                                    ],
                                  );
                                },
                                child: Icon(Icons.menu),
                              ),
                            ),
                            Text(
                              currentTimeState.value.difference(startTimeState.value).format(),
                              style: TextStyle(fontSize: 16),
                            ),
                            Tooltip(
                              message: 'Undo',
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.5)),
                                onPressed: isVictory
                                    ? null
                                    : () {
                                        Audio.playUndo();
                                        onUndo?.call();
                                      },
                                child: Icon(Icons.undo),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.02,
                numberOfParticles: 50,
                maxBlastForce: 100,
                minBlastForce: 60,
                gravity: 0.3,
                shouldLoop: true,
              ),
            ),
          ],
        );
      },
    );
  }
}
