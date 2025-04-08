import 'dart:math';

import 'package:flutter/material.dart';

extension ConstraintsExtensions on BoxConstraints {
  Axis get largestAxis => maxWidth > maxHeight ? Axis.horizontal : Axis.vertical;

  double findCardSizeMultiplier({
    required double maxRows,
    required double maxCols,
    required double spacing,
  }) {
    final availableHorizontalSpace = maxWidth - (maxCols - 1) * spacing;
    final horizontalMultiplier = (availableHorizontalSpace / maxCols) / 64;

    final availableVerticalSpace = maxHeight - (maxRows - 1) * spacing;
    final verticalMultiplier = (availableVerticalSpace / maxRows) / 89;

    return min(horizontalMultiplier, verticalMultiplier);
  }
}
