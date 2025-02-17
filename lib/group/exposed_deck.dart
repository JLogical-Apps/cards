import 'dart:math';
import 'dart:ui';

import 'package:card_game/card_game.dart';

class ExposedCardDeck<T extends Object, G> extends CardLinearGroup<T, G> {
  final int amountExposed;
  final Offset overlayOffset;

  const ExposedCardDeck({
    super.key,
    required this.amountExposed,
    required this.overlayOffset,
    required super.value,
    required super.values,
    super.onCardPressed,
    super.canMoveCardHere,
    super.onCardMovedHere,
    super.isCardFlipped,
    bool canGrab = false,
  }) : super(cardOffset: Offset.zero, maxGrabStackSize: canGrab ? 1 : 0);

  @override
  Offset getCardOffset(int index, T value, Size cardSize, Size groupSize) {
    final offsetMultiplier = max(0, index - values.length + amountExposed) + min(0, values.length - amountExposed);
    return overlayOffset * offsetMultiplier.toDouble();
  }
}
