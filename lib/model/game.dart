import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Game {
  golf,
  klondike,
  freeCell;

  String get title => switch (this) {
        Game.golf => 'Golf Solitaire',
        Game.klondike => 'Solitaire',
        Game.freeCell => 'Free Cell',
      };
}
