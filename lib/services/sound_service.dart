import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static AudioPlayer? _audioPlayer;

  static void playOrderAlertSound() async {
    stopSound();

    try {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.vibrate();
    } catch (_) {}

    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer?.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer?.play(AssetSource('sounds/new_order.wav'));
    } catch (e) {
      debugPrint('AudioPlayer play error: $e');
    }
  }

  static void stopSound() {
    try {
      _audioPlayer?.stop();
      _audioPlayer?.dispose();
    } catch (_) {}
    _audioPlayer = null;
  }
}
