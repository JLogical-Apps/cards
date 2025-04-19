import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solitaire/home_page.dart';
import 'package:solitaire/providers/save_state_notifier.dart';
import 'package:solitaire/services/audio_service.dart';
import 'package:solitaire/utils/build_context_extensions.dart';

class SettingsDialog {
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final saveState = ref.watch(saveStateNotifierProvider).valueOrNull;
          if (saveState == null) {
            return SizedBox.shrink();
          }

          return HookBuilder(
            builder: (context) {
              final volumeState = useState(saveState.volume);
              return AlertDialog(
                title: Text('Settings'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text('Volume'),
                      leading: Checkbox(
                        value: volumeState.value > 0,
                        onChanged: (newValue) async {
                          if (newValue == true) {
                            volumeState.value = 0.5;
                            await ref.read(saveStateNotifierProvider.notifier).saveVolume(volume: 0.5);
                          } else {
                            volumeState.value = 0;
                            await ref.read(saveStateNotifierProvider.notifier).saveVolume(volume: 0);
                          }
                          ref.read(audioServiceProvider).playPlace();
                        },
                      ),
                      subtitle: Slider(
                        value: volumeState.value,
                        onChanged: (value) => volumeState.value = value,
                        onChangeEnd: (value) async {
                          await ref.read(saveStateNotifierProvider.notifier).saveVolume(volume: value);
                          ref.read(audioServiceProvider).playPlace();
                        },
                      ),
                    ),
                    CheckboxListTile(
                      title: Text('Enable Auto Move?'),
                      value: saveState.enableAutoMove,
                      onChanged: (newValue) => ref
                          .read(saveStateNotifierProvider.notifier)
                          .saveEnableAutoMove(enableAutoMove: newValue ?? false),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final shouldDelete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirm Delete'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    'Are you sure you want to delete your data? This will delete all progress on your achievements, unlockables, and difficulties. You cannot undo this action.'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: Text('Delete'),
                                      onPressed: () => Navigator.of(context).pop(true),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                        if (shouldDelete == true) {
                          await ref.read(saveStateNotifierProvider.notifier).deleteAllData();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            context.pushReplacement(() => HomePage());
                          }
                        }
                      },
                      child: Text('Delete Data'),
                    ),
                    TextButton(
                      child: Text('Close'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
