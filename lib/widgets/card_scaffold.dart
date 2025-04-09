import 'dart:math';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:solitaire/context/card_game_context.dart';
import 'package:solitaire/home_page.dart';
import 'package:solitaire/utils/constraints_extensions.dart';
import 'package:solitaire/utils/duration_extensions.dart';

class CardScaffold extends HookWidget {
  final Widget Function(BuildContext, BoxConstraints) builder;

  final Function() onNewGame;
  final Function() onRestart;
  final Function()? onUndo;

  final bool isVictory;

  const CardScaffold({
    super.key,
    required this.builder,
    required this.onNewGame,
    required this.onRestart,
    required this.onUndo,
    this.isVictory = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardGameContext = context.watch<CardGameContext?>();
    final isPreview = cardGameContext?.isPreview ?? false;

    final startTimeState = useState(DateTime.now());
    final currentTimeState = useState(DateTime.now());
    useStream(useMemoized(
      () => Stream.periodic(
        Duration(milliseconds: 480),
        (_) {
          if (!isVictory) {
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
                                style: MenuStyle(
                                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                                ),
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
                                    onPressed: () => Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(builder: (_) => HomePage())),
                                    child: Text('Close'),
                                  ),
                                ],
                              ),
                            ),
                            Tooltip(
                              message: 'Undo',
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.5)),
                                onPressed: onUndo,
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
                      child: LayoutBuilder(builder: builder),
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
                                        onPressed: (_) => Navigator.of(context)
                                            .pushReplacement(MaterialPageRoute(builder: (_) => HomePage())),
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
                                onPressed: onUndo,
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
