import 'dart:math';

import 'package:flutter/material.dart';

extension ConstraintsExtensions on BoxConstraints {
  Axis get largestAxis => maxWidth > maxHeight ? Axis.horizontal : Axis.vertical;

  double findCardSizeMultiplier({
    required int maxRows,
    required int maxCols,
    required double spacing,
  }) {
    final availableHorizontalSpace = maxWidth - (maxRows - 1) * spacing;
    final horizontalMultiplier = (availableHorizontalSpace / maxRows) / 64;

    final availableVerticalSpace = maxHeight - (maxCols - 1) * spacing;
    final verticalMultiplier = (availableVerticalSpace / maxCols) / 89;

    return min(horizontalMultiplier, verticalMultiplier);
  }
}
