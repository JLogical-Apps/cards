import 'package:flutter/material.dart';

extension AxisExtensions on Axis {
  Axis get inverted => switch (this) {
        Axis.horizontal => Axis.vertical,
        Axis.vertical => Axis.horizontal,
      };

  Offset get offset => switch (this) {
        Axis.horizontal => Offset(1, 0),
        Axis.vertical => Offset(0, 1),
      };
}
