import 'package:audioplayers/audioplayers.dart';

class Audio {
  Audio._();

  static void playPlace() => _playAudio('sounds/place.wav');
  static void playUndo() => _playAudio('sounds/undo.wav');
  static void playRedraw() => _playAudio('sounds/deck_redraw.wav');
  static void playDraw() => _playAudio('sounds/draw.wav');
  static void playWin() => _playAudio('sounds/win.wav');

  static void _playAudio(String path) => AudioPlayer().play(
        AssetSource(path),
        mode: PlayerMode.lowLatency,
      );
}
