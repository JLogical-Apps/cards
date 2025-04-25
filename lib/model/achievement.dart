import 'package:solitaire/model/difficulty.dart';
import 'package:solitaire/model/game.dart';
import 'package:solitaire/model/save_state.dart';
import 'package:utils/utils.dart';

enum Achievement {
  fullHouse('Full House', 'Complete all games in Classic mode.'),
  royalFlush('Royal Flush', 'Complete all games in Royal mode.'),
  speedDealer('Speed Dealer', 'Win any game in under 1 minute.'),
  grandSlam('Grand Slam', 'In Golf Solitaire, make a chain of 20 consecutive cards.'),
  suitedUp(
    'Suited Up',
    'In Free Cell, complete one entire suit foundation before starting others. (Hint: Disable Auto Move in Settings)',
  ),
  stackTheDeck('Stack the Deck', 'Win 3 games in a row without restarting a game.'),
  deckWhisperer('Deck Whisperer', 'Win a Solitaire game without restarting the deck.'),
  aceUpYourSleeve('Ace Up Your Sleeve', 'Complete all games in Ace mode.'),
  birdie('Birdie', 'Win an Ace Golf Solitaire game with at least 1 card remaining in the draw pile.'),
  cleanSweep('Clean Sweep', 'Win an Ace Solitaire game without undoing any moves.'),
  perfectPlanning('Perfect Planning', 'Win an Ace Free Cell game without undoing any moves.');

  final String name;
  final String description;

  const Achievement(this.name, this.description);

  int? getCurrentProgress({required SaveState saveState}) => switch (this) {
        Achievement.fullHouse =>
          saveState.gameStates.where((game, state) => state.states.containsKey(Difficulty.classic)).length,
        Achievement.royalFlush =>
          saveState.gameStates.where((game, state) => state.states.containsKey(Difficulty.royal)).length,
        Achievement.aceUpYourSleeve =>
          saveState.gameStates.where((game, state) => state.states.containsKey(Difficulty.ace)).length,
        Achievement.stackTheDeck => saveState.winStreak,
        _ => null,
      };

  int? getProgressMax() => switch (this) {
        Achievement.fullHouse || Achievement.royalFlush || Achievement.aceUpYourSleeve => Game.values.length,
        Achievement.stackTheDeck => 3,
        _ => null,
      };
}
