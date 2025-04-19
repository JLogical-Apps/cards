import 'package:flutter/material.dart';
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

          return AlertDialog(
            title: Text('Customization'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Background', style: TextTheme.of(context).titleSmall),
                  Row(
                    spacing: 8,
                    children: Background.values
                        .map((background) => Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                    foregroundDecoration: background == saveState.background
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
                                        Positioned.fill(child: background.build()),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => ref
                                                .read(saveStateNotifierProvider.notifier)
                                                .saveBackground(background: background),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          ),
                        ))
                        .toList(),
                  ),
                  Divider(),
                  Text('Card Back', style: TextTheme.of(context).titleSmall),
                  Column(
                    spacing: 8,
                    children: CardBack.values
                        .batch(4)
                        .map((row) => Row(
                              spacing: 8,
                              children: row
                                  .map((cardBack) => Expanded(
                                    child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: Container(
                                              foregroundDecoration: cardBack == saveState.cardBack
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
                                                  Positioned.fill(child: cardBack.build()),
                                                  Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () => ref
                                                          .read(saveStateNotifierProvider.notifier)
                                                          .saveCardBack(cardBack: cardBack),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                  ))
                                  .toList(),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
