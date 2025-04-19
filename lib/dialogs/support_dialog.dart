import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportDialog {
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MarkdownBody(
              data:
                  'All I ask for your support is to star the [Solitaire Github Repo](https://github.com/JLogical-Apps/Solitaire) and like the [card_game pub package](https://pub.dev/packages/card_game).',
              onTapLink: (text, href, title) => launchUrlString(href!, mode: LaunchMode.externalApplication),
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
  }
}
