import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' hide Provider;
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:solitaire/context/card_game_context.dart';
import 'package:solitaire/game_view.dart';
import 'package:solitaire/games/free_cell.dart';
import 'package:solitaire/games/golf_solitaire.dart';
import 'package:solitaire/games/solitaire.dart';
import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/game.dart';
import 'package:solitaire/model/game_state.dart';
import 'package:solitaire/providers/save_state_notifier.dart';
import 'package:solitaire/utils/build_context_extensions.dart';
import 'package:solitaire/utils/constraints_extensions.dart';
import 'package:utils/utils.dart';

typedef GameDetails = ({
  Widget Function(Difficulty) builder,
  Difficulty difficulty,
  Function(Difficulty) onChangeDifficulty,
  GameState? gameState,
});

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  Map<Game, Widget Function(Difficulty)> get gameBuilders => {
        Game.golf: (Difficulty difficulty) => GolfSolitaire(difficulty: difficulty),
        Game.klondike: (Difficulty difficulty) => Solitaire(difficulty: difficulty),
        Game.freeCell: (Difficulty difficulty) => FreeCell(difficulty: difficulty),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveState = ref.watch(saveStateNotifierProvider).valueOrNull;

    final difficultyByGameState = useState(gameBuilders.map((game, _) => MapEntry(game, Difficulty.classic)));
    final gameDetails = gameBuilders.map((game, builder) => MapEntry(game, (
          difficulty: difficultyByGameState.value[game]!,
          onChangeDifficulty: (Difficulty difficulty) =>
              difficultyByGameState.value = {...difficultyByGameState.value, game: difficulty},
          builder: builder,
          gameState: saveState?.gameStates[game],
        )));

    return Scaffold(
      body: Provider.value(
        value: CardGameContext(isPreview: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.largestAxis == Axis.horizontal) {
              return buildHorizontalLayout(context, gameDetails: gameDetails);
            } else {
              return buildVerticalLayout(context, gameDetails: gameDetails);
            }
          },
        ),
      ),
    );
  }

  Widget buildHorizontalLayout(BuildContext context, {required Map<Game, GameDetails> gameDetails}) {
    return HookBuilder(
      key: ValueKey('horizontal'),
      builder: (context) {
        final selectedGameState = useState(Game.golf);
        final (:difficulty, :onChangeDifficulty, :builder, :gameState) = gameDetails[selectedGameState.value]!;

        return Row(
          children: [
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: true,
                removeTop: true,
                removeRight: true,
                removeBottom: true,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16) +
                      EdgeInsets.only(
                        top: max(MediaQuery.paddingOf(context).top + 16, 32),
                        bottom: max(MediaQuery.paddingOf(context).bottom + 16, 32),
                      ),
                  itemCount: gameDetails.length,
                  itemBuilder: (_, i) {
                    final (game, (:difficulty, :onChangeDifficulty, :builder, :gameState)) =
                        gameDetails.entryRecords.toList()[i];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Material(
                        color: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: selectedGameState.value == game ? BorderSide(width: 4) : BorderSide.none,
                        ),
                        child: AspectRatio(
                          aspectRatio: 3 / 2,
                          child: Stack(
                            children: [
                              IgnorePointer(child: builder(Difficulty.classic)),
                              Positioned.fill(
                                child: ColoredBox(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  child: InkWell(
                                    onTap: () => selectedGameState.value = game,
                                    child: Center(
                                      child: Text(
                                        game.title,
                                        style: Theme.of(context).textTheme.headlineLarge,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(height: 16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedGameState.value.title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    difficultyBar(
                      context,
                      selectedDifficulty: difficulty,
                      onChangeDifficulty: onChangeDifficulty,
                      game: selectedGameState.value,
                      gameState: gameState,
                    ),
                    ElevatedButton(
                      onPressed: () => context.pushReplacement(() => GameView(cardGame: builder(difficulty))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Play'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildVerticalLayout(BuildContext context, {required Map<Game, GameDetails> gameDetails}) {
    return HookBuilder(
      key: ValueKey('vertical'),
      builder: (context) {
        final pageState = useState(0);
        final pageController = usePageController();

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
                  children: gameDetails.mapToIterable((game, details) {
                    final (:difficulty, :onChangeDifficulty, :builder, :gameState) = details;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Provider(
                        create: (_) => CardGameContext(isPreview: true),
                        child: Stack(
                          children: [
                            IgnorePointer(child: builder(Difficulty.classic)),
                            Positioned.fill(
                              child: ColoredBox(color: Colors.white.withValues(alpha: 0.8)),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      game.title,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.headlineLarge,
                                    ),
                                    difficultyBar(
                                      context,
                                      selectedDifficulty: difficulty,
                                      onChangeDifficulty: onChangeDifficulty,
                                      game: game,
                                      gameState: gameState,
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          context.pushReplacement(() => GameView(cardGame: builder(difficulty))),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text('Play'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16),
            AnimatedSmoothIndicator(
              activeIndex: pageState.value,
              count: gameBuilders.length,
              effect: WormEffect(
                activeDotColor: Colors.black,
              ),
            ),
            SizedBox(height: max(MediaQuery.paddingOf(context).bottom + 32, 48)),
          ],
        );
      },
    );
  }

  Widget difficultyBar(
    BuildContext context, {
    required Difficulty selectedDifficulty,
    required Function(Difficulty) onChangeDifficulty,
    required Game game,
    required GameState? gameState,
  }) {
    return Column(
      children: [
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: Difficulty.values
              .map((difficulty) => ChoiceChip(
                    label: Text(difficulty.title),
                    avatar: Icon(
                      difficulty.icon,
                      fill: gameState?[difficulty]?.gamesWon != null ? 1 : 0,
                    ),
                    selected: difficulty == selectedDifficulty,
                    onSelected: (_) => onChangeDifficulty(difficulty),
                  ))
              .toList(),
        ),
        Text(
          selectedDifficulty.getDescription(game),
          style: TextTheme.of(context).bodyLarge,
        ),
      ],
    );
  }
}
