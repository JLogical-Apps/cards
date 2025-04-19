import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solitaire/model/background.dart';
import 'package:solitaire/model/card_back.dart';
import 'package:solitaire/providers/save_state_notifier.dart';
import 'package:solitaire/utils/iterable_extensions.dart';

class CustomizationDialog {
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final saveState = ref.watch(saveStateNotifierProvider).valueOrNull;
          if (saveState == null) {
            return SizedBox.shrink();
          }

          return SimpleDialog(
            title: Text('Customization'),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              Text('Background', style: TextTheme.of(context).titleMedium),
              Row(
                spacing: 8,
                children: Background.values
                    .map((background) => Expanded(
                          child: _customizationSquare(
                            context,
                            child: background.build(),
                            onPressed: () =>
                                ref.read(saveStateNotifierProvider.notifier).saveBackground(background: background),
                            selected: background == saveState.background,
                          ),
                        ))
                    .toList(),
              ),
              Divider(),
              Text('Card Back', style: TextTheme.of(context).titleMedium),
              Column(
                spacing: 8,
                children: CardBack.values
                    .batch(4)
                    .map((row) => Row(
                          spacing: 8,
                          children: row.map((cardBack) {
                            final locked = cardBack.achievementLock != null &&
                                !saveState.achievements.contains(cardBack.achievementLock!);
                            return Expanded(
                              child: HookBuilder(builder: (context) {
                                final tooltipKey = useMemoized(() => GlobalKey<TooltipState>());
                                return _customizationSquare(
                                  context,
                                  onPressed: locked
                                      ? () => tooltipKey.currentState?.ensureTooltipVisible()
                                      : () =>
                                          ref.read(saveStateNotifierProvider.notifier).saveCardBack(cardBack: cardBack),
                                  selected: cardBack == saveState.cardBack,
                                  child: locked
                                      ? Tooltip(
                                          key: tooltipKey,
                                          message: 'Unlocked with the "${cardBack.achievementLock!.name}" Achievement.',
                                          child: Material(
                                            color: Colors.grey,
                                            child: InkWell(
                                              child: Icon(Icons.lock),
                                              onTap: () => tooltipKey.currentState?.ensureTooltipVisible(),
                                            ),
                                          ),
                                        )
                                      : cardBack.build(),
                                );
                              }),
                            );
                          }).toList(),
                        ))
                    .toList(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _customizationSquare(
  BuildContext context, {
  required Widget child,
  required Function() onPressed,
  required bool selected,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: AspectRatio(
      aspectRatio: 1,
      child: Container(
        foregroundDecoration: selected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              )
            : null,
        child: Stack(
          children: [
            Positioned.fill(child: child),
            Material(
              color: Colors.transparent,
              child: InkWell(onTap: onPressed),
            ),
          ],
        ),
      ),
    ),
  );
}
