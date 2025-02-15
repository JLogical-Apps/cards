import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:solitaire/context/card_game_context.dart';
import 'package:solitaire/game_view.dart';
import 'package:solitaire/games/golf_solitaire.dart';
import 'package:solitaire/games/solitaire.dart';
import 'package:utils/utils.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageState = useState(0);
    final games = {
      'Golf Solitaire': GolfSolitaire(),
      'Solitaire': Solitaire(),
    };
    return Scaffold(
      body: SafeArea(
        child: Column(
          spacing: 16,
          children: [
            Expanded(
              child: PageView(
                onPageChanged: (page) => pageState.value = page,
                children: games
                    .mapToIterable((name, game) => Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          child: Provider(
                            create: (_) => CardGameContext(isPreview: true),
                            child: Stack(
                              children: [
                                IgnorePointer(
                                  child: game,
                                ),
                                Positioned.fill(
                                  child: ColoredBox(color: Colors.white.withValues(alpha: 0.8)),
                                ),
                                Positioned.fill(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        name,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge!
                                            .copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context)
                                            .push(MaterialPageRoute(builder: (_) => GameView(cardGame: game))),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text('Play'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            AnimatedSmoothIndicator(
              activeIndex: pageState.value,
              count: games.length,
              effect: WormEffect(
                activeDotColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
