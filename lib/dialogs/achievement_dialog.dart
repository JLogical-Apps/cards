import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solitaire/model/achievement.dart';
import 'package:solitaire/model/card_back.dart';
import 'package:solitaire/providers/save_state_notifier.dart';
import 'package:solitaire/services/achievement_service.dart';

class AchievementDialog {
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
            title: Text('Achievements (${saveState.achievements.length}/${Achievement.values.length})'),
            contentPadding: EdgeInsets.zero,
            children: [
              ...Achievement.values.map((achievement) => HookBuilder(
                    builder: (context) {
                      final tapsState = useState(0);
                      final progress = (
                        achievement.getCurrentProgress(saveState: saveState),
                        achievement.getProgressMax(),
                      );
                      return GestureDetector(
                        onTap: () {
                          tapsState.value += 1;
                          if (tapsState.value == 10 && saveState.achievements.contains(achievement)) {
                            ref.read(achievementServiceProvider).deleteAchievement(achievement);
                          }
                        },
                        child: ListTile(
                          title: Text(achievement.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(achievement.description),
                              if (!saveState.achievements.contains(achievement))
                                if (progress case (final currentProgress?, final maxProgress?))
                                  Text(
                                    'Progress: $currentProgress / $maxProgress',
                                    style: TextTheme.of(context).bodySmall,
                                  ),
                            ],
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox.square(
                              dimension: 48,
                              child: saveState.achievements.contains(achievement)
                                  ? CardBack.values.firstWhere((back) => back.achievementLock == achievement).build()
                                  : LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ColoredBox(
                                              color: Colors.grey,
                                              child: Icon(Icons.question_mark),
                                            ),
                                            if (progress case (final currentProgress?, final maxProgress?))
                                              Positioned.fill(
                                                right: constraints.maxWidth * (1 - (currentProgress / maxProgress)),
                                                child: ColoredBox(
                                                  color: Colors.black.withValues(alpha: 0.2),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: TextButton(
                    child: Text('Close'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
