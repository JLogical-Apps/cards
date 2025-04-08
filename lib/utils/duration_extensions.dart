import 'package:intl/intl.dart';

extension DurationExtensions on Duration {
  String format() => [
        if (inHours >= 1) inHours,
        inMinutes % 60,
        inSeconds % 60,
      ].map((value) => NumberFormat('00').format(value)).join(':');
}
