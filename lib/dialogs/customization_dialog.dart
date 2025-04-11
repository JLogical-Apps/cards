import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solitaire/model/background.dart';
import 'package:solitaire/providers/save_state_notifier.dart';

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
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runSpacing: 8,
                    spacing: 8,
                    children: Background.values
                        .map((background) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 64,
                                height: 64,
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
                                            .saveNewBackground(background: background),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
