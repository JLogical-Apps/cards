import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:solitaire/providers/save_state_notifier.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SolitaireAboutDialog {
  static Future<void> show(BuildContext context) async {
    final packageVersion = await PackageInfo.fromPlatform();

    if (!context.mounted) {
      return;
    }

    showAboutDialog(
      context: context,
      applicationIcon: Consumer(
        builder: (context, ref, child) {
          return HookBuilder(
            builder: (context) {
              final clicksState = useState(0);
              return GestureDetector(
                onTap: () {
                  final clicks = clicksState.value++;
                  if (kDebugMode && clicks == 10) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cheated State Activated')));
                    ref.read(saveStateNotifierProvider.notifier).saveCheatCode();
                  }
                },
                child: Image.asset('assets/cards.png', width: 80, height: 80),
              );
            },
          );
        },
      ),
      applicationName: 'Cards',
      applicationVersion: '${packageVersion.version}+${packageVersion.buildNumber}',
      children: [
        MarkdownBody(
          data:
              'Built with ❤️ by [JLogical](https://www.jlogical.com).\n\nPowered by the custom-built [card_game](https://pub.dev/packages/card_game) package.\n\nFind the [source code on GitHub](https://github.com/JLogical-Apps/cards).\n\nFollow development updates on [X](https://x.com/JakeBoychenko).',
          onTapLink: (text, href, title) => launchUrlString(href!, mode: LaunchMode.externalApplication),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Tooltip(
              message: 'JLogical',
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => launchUrlString('https://www.jlogical.com', mode: LaunchMode.externalApplication),
                child: Image.asset('assets/logos/jlogical.png', width: 48, height: 48),
              ),
            ),
            Tooltip(
              message: 'X',
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => launchUrlString('https://x.com/JakeBoychenko', mode: LaunchMode.externalApplication),
                child: SizedBox.square(
                  dimension: 48,
                  child: Center(
                    child: FaIcon(FontAwesomeIcons.xTwitter, size: 40),
                  ),
                ),
              ),
            ),
            Tooltip(
              message: 'GitHub',
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () =>
                    launchUrlString('https://github.com/JLogical-Apps/cards', mode: LaunchMode.externalApplication),
                child: SizedBox.square(
                  dimension: 48,
                  child: Center(
                    child: FaIcon(FontAwesomeIcons.github, size: 40),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
