import 'dart:io' show Platform;

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

void audioPlayerHandler(AudioPlayerState value) => print('state => $value');

class AudioPlayerController {
  static AudioPlayer _audioPlayer = AudioPlayer();
  static AudioCache _audioCache = AudioCache();

  AudioPlayerController() {
    _audioCache.loadAll([
      "sound/star_1.mp3",
      "sound/star_2.mp3",
      "sound/star_3.mp3",
      "sound/ghost.mp3",
    ]);
  }

  void play(String sound) {
    if (Platform.isIOS) {
      _audioPlayer.monitorNotificationStateChanges(audioPlayerHandler);
    }

    _audioCache.play(sound, mode: PlayerMode.LOW_LATENCY);
  }

  void stopSound() async {
    await _audioPlayer.stop();
  }
}
