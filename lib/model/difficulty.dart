import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'game.dart';

enum Difficulty {
  classic,
  royal,
  ace;

  String get title => switch (this) {
        Difficulty.classic => 'Classic',
        Difficulty.royal => 'Royal',
        Difficulty.ace => 'Ace',
      };

  String getDescription(Game game) => switch (this) {
        Difficulty.classic => 'The original ruleset as traditionally played.',
        Difficulty.royal => switch (game) {
            Game.golf => 'One card is automatically drawn at the start.',
            Game.klondike => 'Cards are drawn three at a time.',
            Game.freeCell => 'Play with one fewer free cell.',
          },
        Difficulty.ace => switch (game) {
            Game.golf => 'One card is automatically drawn at the start, and Kings cannot wrap to Aces.',
            Game.klondike => 'Cards are drawn three at a time and all aces are buried at the bottom of the last four tableaus.',
            Game.freeCell => 'Play with one fewer free cell and all aces are buried at the bottom of the first four tableaus.',
          },
      };

  IconData get icon => switch (this) {
        Difficulty.classic => Symbols.playing_cards,
        Difficulty.royal => Symbols.favorite,
        Difficulty.ace => Symbols.military_tech,
      };
}
