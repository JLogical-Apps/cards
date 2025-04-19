import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' hide Provider;
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:solitaire/context/card_game_context.dart';
import 'package:solitaire/dialogs/customization_dialog.dart';
import 'package:solitaire/dialogs/settings_dialog.dart';
import 'package:solitaire/game_view.dart';
import 'package:solitaire/games/free_cell.dart';
import 'package:solitaire/games/golf_solitaire.dart';
import 'package:solitaire/games/solitaire.dart';
import 'package:solitaire/model/background.dart';
import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/game.dart';
import 'package:solitaire/model/game_state.dart';
import 'package:solitaire/providers/save_state_notifier.dart';
import 'package:solitaire/utils/build_context_extensions.dart';
import 'package:solitaire/utils/constraints_extensions.dart';
import 'package:solitaire/utils/duration_extensions.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:utils/utils.dart';

typedef GameDetails = ({
  Widget Function(Difficulty) builder,
  Difficulty difficulty,
  Function(Difficulty) onChangeDifficulty,
  GameState? gameState,
  Function(Game) onStartGame,
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Map<Game, Widget Function(Difficulty)> get gameBuilders => {
        Game.golf: (Difficulty difficulty) => GolfSolitaire(difficulty: difficulty),
        Game.klondike: (Difficulty difficulty) => Solitaire(difficulty: difficulty),
        Game.freeCell: (Difficulty difficulty) => FreeCell(difficulty: difficulty),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveState = ref.watch(saveStateNotifierProvider).valueOrNull;
    if (saveState == null) {
      return SizedBox.shrink();
    }

    return HookBuilder(
      builder: (context) {
        final difficultyByGameState = useState(gameBuilders.map((game, _) => MapEntry(
              game,
              saveState.lastPlayedGameDifficulties[game] ?? Difficulty.classic,
            )));

        final gameDetails = gameBuilders.map((game, builder) => MapEntry(game, (
              difficulty: difficultyByGameState.value[game]!,
              onChangeDifficulty: (Difficulty difficulty) =>
                  difficultyByGameState.value = {...difficultyByGameState.value, game: difficulty},
              builder: builder,
              gameState: saveState.gameStates[game],
              onStartGame: (game) {
                final difficulty = difficultyByGameState.value[game]!;
                context.pushReplacement(() => GameView(cardGame: builder(difficulty)));
                ref.read(saveStateNotifierProvider.notifier).saveGameStarted(game: game, difficulty: difficulty);
              },
            )));

        return Scaffold(
          appBar: AppBar(
            forceMaterialTransparency: true,
            actions: [
              Tooltip(
                message: 'Customization',
                child: IconButton(
                  icon: Icon(Symbols.palette, fill: 1),
                  onPressed: () => CustomizationDialog.show(context),
                ),
              ),
              Tooltip(
                message: 'More',
                child: MenuAnchor(
                  alignmentOffset: Offset(-75, 0),
                  builder: (context, controller, child) {
                    return IconButton(
                      onPressed: () => controller.open(),
                      icon: Icon(Icons.more_vert),
                    );
                  },
                  menuChildren: [
                    MenuItemButton(
                      leadingIcon: Icon(Icons.settings),
                      onPressed: () => SettingsDialog.show(context),
                      child: Text('Settings'),
                    ),
                    MenuItemButton(
                      leadingIcon: Icon(Icons.info),
                      onPressed: () async {
                        final packageVersion = await PackageInfo.fromPlatform();

                        if (!context.mounted) {
                          return;
                        }

                        showAboutDialog(
                          context: context,
                          applicationIcon: Image.asset('assets/cards.png', width: 80, height: 80),
                          applicationName: 'Cards',
                          applicationVersion: '${packageVersion.version}+${packageVersion.buildNumber}',
                          children: [
                            MarkdownBody(
                              data:
                                  'Built by [JLogical](https://www.jlogical.com).\n\nUses the custom-built [card_game](https://pub.dev/packages/card_game) package.\n\nFind the [source code on GitHub](https://github.com/JLogical-Apps/Solitaire).',
                              onTapLink: (text, href, title) => launchUrlString(
                                href!,
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          ],
                        );
                      },
                      child: Text('About'),
                    ),
                    MenuItemButton(
                      leadingIcon: Icon(Icons.favorite),
                      onPressed: () async {
                        if (!context.mounted) {
                          return;
                        }

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Support'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MarkdownBody(
                                  data:
                                      'All I ask for your support is to star the [Solitaire Github Repo](https://github.com/JLogical-Apps/Solitaire) and like the [card_game pub package](https://pub.dev/packages/card_game).',
                                  onTapLink: (text, href, title) => launchUrlString(
                                    href!,
                                    mode: LaunchMode.externalApplication,
                                  ),
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
                      },
                      child: Text('Support'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Provider.value(
            value: CardGameContext(isPreview: true),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.largestAxis == Axis.horizontal) {
                  return buildHorizontalLayout(
                    context,
                    lastGamePlayed: saveState.lastGamePlayed,
                    gameDetails: gameDetails,
                    background: saveState.background,
                  );
                } else {
                  return buildVerticalLayout(
                    context,
                    lastGamePlayed: saveState.lastGamePlayed,
                    gameDetails: gameDetails,
                    background: saveState.background,
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildHorizontalLayout(
    BuildContext context, {
    required Game? lastGamePlayed,
    required Map<Game, GameDetails> gameDetails,
    required Background background,
  }) {
    return HookBuilder(
      key: ValueKey('horizontal'),
      builder: (context) {
        final selectedGameState = useState(lastGamePlayed ?? Game.golf);
        final (:difficulty, :onChangeDifficulty, :builder, :gameState, :onStartGame) =
            gameDetails[selectedGameState.value]!;

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
                        bottom: max(MediaQuery.paddingOf(context).bottom + 16, 32),
                      ),
                  itemCount: gameDetails.length,
                  itemBuilder: (_, i) {
                    final (game, (:difficulty, :onChangeDifficulty, :builder, :gameState, :onStartGame)) =
                        gameDetails.entryRecords.toList()[i];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Material(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: selectedGameState.value == game ? BorderSide(width: 4) : BorderSide.none,
                        ),
                        child: AspectRatio(
                          aspectRatio: 3 / 2,
                          child: Stack(
                            children: [
                              Positioned.fill(child: background.build()),
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
                      onPressed: () => onStartGame(selectedGameState.value),
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

  Widget buildVerticalLayout(
    BuildContext context, {
    required Game? lastGamePlayed,
    required Map<Game, GameDetails> gameDetails,
    required Background background,
  }) {
    return HookBuilder(
      key: ValueKey('vertical'),
      builder: (context) {
        final pageState = useState(lastGamePlayed == null ? 0 : gameDetails.keys.toList().indexOf(lastGamePlayed));
        final pageController = usePageController(initialPage: pageState.value);

        return Column(
          children: [
            Expanded(
              child: MediaQuery.removePadding(
                removeTop: true,
                removeBottom: true,
                context: context,
                child: PageView(
                  controller: pageController,
                  onPageChanged: (page) => pageState.value = page,
                  children: gameDetails.mapToIterable((game, details) {
                    final (:difficulty, :onChangeDifficulty, :builder, :gameState, :onStartGame) = details;

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Positioned.fill(child: background.build()),
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
                                      onPressed: () => onStartGame(game),
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
                    onSelected: difficulty == Difficulty.classic ||
                            gameState?[Difficulty.values[difficulty.index - 1]]?.gamesWon != null
                        ? (_) => onChangeDifficulty(difficulty)
                        : null,
                  ))
              .toList(),
        ),
        Text(
          selectedDifficulty.getDescription(game),
          style: TextTheme.of(context).bodyLarge,
        ),
        if (gameState?.states[selectedDifficulty] case final difficultyState?)
          MarkdownBody(
            data: '**Fastest Time**: ${difficultyState.fastestGame.format()}',
          ),
      ],
    );
  }
}
