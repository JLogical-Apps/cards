import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solitaire/context/card_game_context.dart';

class CardScaffold extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints) builder;

  final Function() onNewGame;
  final Function() onRestart;
  final Function()? onUndo;

  const CardScaffold({
    super.key,
    required this.builder,
    required this.onNewGame,
    required this.onRestart,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final cardGameContext = context.watch<CardGameContext?>();
    final isPreview = cardGameContext?.isPreview ?? false;

    return Column(
      children: [
        Expanded(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: LayoutBuilder(builder: builder),
            ),
          ),
        ),
        if (!isPreview)
          Container(
            height: MediaQuery.paddingOf(context).bottom + 32,
            color: Colors.white.withValues(alpha: 0.2),
            alignment: Alignment.topCenter,
            child: SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  onNewGame();
                                  Navigator.of(context).pop();
                                },
                              ),
                              BottomSheetAction(
                                title: Text('Restart Game'),
                                leading: Icon(Icons.restart_alt),
                                onPressed: (_) {
                                  onRestart();
                                  Navigator.of(context).pop();
                                },
                              ),
                              BottomSheetAction(
                                title: Text('Close'),
                                leading: Icon(Icons.close),
                                onPressed: (_) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                        child: Icon(Icons.menu),
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
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
