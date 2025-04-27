import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportDialog {
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Support This Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MarkdownBody(
              data:
                  """\
Love playing Cards? Here's how you can help: 

⭐ **Star the [GitHub repository](https://github.com/JLogical-Apps/Solitaire)**  
   Help others discover this project.


👍 **Like the card_game package on [pub.dev](https://pub.dev/packages/card_game)**  
   Support the underlying framework
   
   
 🐛 **Report bugs or suggest features**  
    Open an issue on [GitHub](https://github.com/JLogical-Apps/Solitaire/issues)
    
    
💬 **Share with friends**  
   Spread the word about Cards


🔔 **Follow development**  
   Get updates on [X @JakeBoychenko](https://x.com/JakeBoychenko)
""",
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
