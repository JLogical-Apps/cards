import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:solitaire/game_view.dart';
import 'package:solitaire/games/free_cell.dart';
import 'package:solitaire/games/golf_solitaire.dart';
import 'package:solitaire/games/solitaire.dart';
import 'package:solitaire/utils/constraints_extensions.dart';
import 'package:utils/utils.dart';

import 'context/card_game_context.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageState = useState(0);
    final pageController = usePageController();

    final games = {
      'Golf Solitaire': GolfSolitaire(),
      'Solitaire (Easy)': Solitaire(drawAmount: 1),
      'Solitaire (Hard)': Solitaire(drawAmount: 3),
      'Free Cell': FreeCell(),
    };

    return Scaffold(
      body: Provider.value(
        value: CardGameContext(isPreview: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.largestAxis == Axis.horizontal) {
              return ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  SizedBox(height: max(MediaQuery.paddingOf(context).top + 32, 48)),
                  MediaQuery.removePadding(
                    context: context,
                    removeLeft: true,
                    removeTop: true,
                    removeRight: true,
                    removeBottom: true,
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: (MediaQuery.sizeOf(context).width ~/ 600) + 1,
                      childAspectRatio: 600 / 400,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: games
                          .mapToIterable((name, game) => Material(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    IgnorePointer(child: game),
                                    Positioned.fill(
                                      child: ColoredBox(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        child: InkWell(
                                          onTap: () => Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(builder: (_) => GameView(cardGame: game))),
                                          child: Center(
                                            child: Text(
                                              name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge!
                                                  .copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: max(MediaQuery.paddingOf(context).bottom + 32, 48)),
                ],
              );
            } else {
              return Column(
                children: [
                  SizedBox(height: max(MediaQuery.paddingOf(context).bottom + 32, 48)),
                  Expanded(
                    child: MediaQuery.removePadding(
                      removeTop: true,
                      removeBottom: true,
                      context: context,
                      child: PageView(
                        controller: pageController,
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
                                                onPressed: () => Navigator.of(context).pushReplacement(
                                                    MaterialPageRoute(builder: (_) => GameView(cardGame: game))),
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
                  ),
                  SizedBox(height: 16),
                  AnimatedSmoothIndicator(
                    activeIndex: pageState.value,
                    count: games.length,
                    effect: WormEffect(
                      activeDotColor: Colors.black,
                    ),
                  ),
                  SizedBox(height: max(MediaQuery.paddingOf(context).bottom + 32, 48)),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
