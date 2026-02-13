import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  
  late AudioPlayer _player;

  AudioService._internal() {
    _player = AudioPlayer();
    // Preload if using assets, but we might use URLs for now
  }

  Future<void> playCorrect() async {
    try {
      // Short happy ding
      await _player.play(UrlSource('https://codeskulptor-demos.commondatastorage.googleapis.com/GalaxyInvaders/pause.wav')); 
      // Alternative: AssetSource('sounds/correct.mp3') if you add the file
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  Future<void> playIncorrect() async {
    try {
      // Short buzz
      await _player.play(UrlSource('https://codeskulptor-demos.commondatastorage.googleapis.com/GalaxyInvaders/bonus.wav'));
      // Note: These URLs are just placeholders. "pause.wav" leads to a simple ping.
    } catch (e) {
       debugPrint("Audio Error: $e");
    }
  }

  Future<void> playCelebration() async {
    try {
      // Fanfare
      await _player.play(UrlSource('https://codeskulptor-demos.commondatastorage.googleapis.com/GalaxyInvaders/theme_01.mp3'));
    } catch (e) {
       debugPrint("Audio Error: $e");
    }
  }
}
