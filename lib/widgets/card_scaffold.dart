import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';

class CardScaffold extends StatelessWidget {
  final Widget body;

  final Function() onNewGame;
  final Function() onRestart;
  final Function()? onUndo;

  const CardScaffold({
    super.key,
    required this.body,
    required this.onNewGame,
    required this.onRestart,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SafeArea(
            bottom: false,
            child: body,
          ),
        ),
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
