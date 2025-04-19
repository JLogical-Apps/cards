import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solitaire/model/achievement.dart';
import 'package:solitaire/model/card_back.dart';
import 'package:solitaire/providers/save_state_notifier.dart';

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
            title: Text('Achievements'),
            contentPadding: EdgeInsets.zero,
            children: [
              ...Achievement.values.map((achievement) => ListTile(
                title: Text(achievement.name),
                subtitle: Text(achievement.description),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox.square(
                    dimension: 48,
                    child: Random().nextBool()
                        ? ColoredBox(
                      color: Colors.grey,
                      child: Icon(Icons.question_mark),
                    )
                        : CardBack.values.firstWhere((back) => back.achievementLock == achievement).build(),
                  ),
                ),
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
