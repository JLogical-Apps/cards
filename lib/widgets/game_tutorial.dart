import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void showGameTutorial(BuildContext context, {required List<TutorialScreen> screens}) {
  TutorialCoachMark(
    hideSkip: true,
    targets: screens
        .map((screen) => TargetFocus(
              keyTarget: switch (screen.focus) {
                _KeyTutorialScreenFocus(:final key) => key,
                _EverythingTutorialScreenFocus() => null,
              },
              targetPosition:
                  screen.focus is _EverythingTutorialScreenFocus ? TargetPosition(Size.zero, Offset.zero) : null,
              shape: ShapeLightFocus.RRect,
              focusAnimationDuration: screen.focus is _EverythingTutorialScreenFocus ? Duration.zero : null,
              radius: 16,
              enableOverlayTab: true,
              contents: [
                TargetContent(
                  child: Center(
                    child: IgnorePointer(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: IntrinsicWidth(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              screen.message,
                              style: TextTheme.of(context).headlineSmall!.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  align: ContentAlign.custom,
                  customPosition: CustomTargetContentPosition(
                    top: MediaQuery.paddingOf(context).top + 8,
                    right: 8,
                    left: 8,
                  ),
                ),
              ],
            ))
        .toList(),
  ).show(context: context);
}

class TutorialScreen {
  final TutorialScreenFocus focus;
  final String message;

  TutorialScreen.everything({required this.message}) : focus = _EverythingTutorialScreenFocus();
  TutorialScreen.key({required GlobalKey key, required this.message}) : focus = _KeyTutorialScreenFocus(key: key);
}

sealed class TutorialScreenFocus {
  const TutorialScreenFocus();
}

class _EverythingTutorialScreenFocus extends TutorialScreenFocus {
  const _EverythingTutorialScreenFocus();
}

class _KeyTutorialScreenFocus extends TutorialScreenFocus {
  final GlobalKey key;
  const _KeyTutorialScreenFocus({required this.key});
}
