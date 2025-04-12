import 'package:audioplayers/audioplayers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solitaire/providers/save_state_notifier.dart';

part 'audio_service.g.dart';

class AudioService {
  final Ref ref;

  final AudioPlayer audioPlayer = AudioPlayer();

  AudioService(this.ref);

  void playPlace() => _playAudio('sounds/place.wav');
  void playUndo() => _playAudio('sounds/undo.wav');
  void playRedraw() => _playAudio('sounds/deck_redraw.wav');
  void playDraw() => _playAudio('sounds/draw.wav');
  void playWin() => _playAudio('sounds/win.wav');

  Future<void> _playAudio(String path) async {
    final saveState = await ref.read(saveStateNotifierProvider.future);
    if (saveState.volume == 0) {
      return;
    }

    await audioPlayer.play(
      AssetSource(path),
      mode: PlayerMode.lowLatency,
      volume: saveState.volume,
    );
  }
}

@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) => AudioService(ref);
