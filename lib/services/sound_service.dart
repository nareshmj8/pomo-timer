import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _audioPlayer.setSource(AssetSource('sounds/completion.mp3'));
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  Future<void> playCompletionSound() async {
    try {
      // First try HapticFeedback for tactile feedback
      await HapticFeedback.mediumImpact();

      // Initialize if not already done
      await initialize();

      // Play completion sound
      await _audioPlayer.play(AssetSource('sounds/completion.mp3'));

      // Fallback to system sound if audio player fails
      if (!_isInitialized) {
        await SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
      // Fallback to system sound
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (e) {
        debugPrint('Error playing system sound: $e');
      }
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
