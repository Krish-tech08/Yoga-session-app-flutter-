import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _isPaused = false;
  String? _currentAudioPath;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;

  Future<void> playAudio(String audioPath) async {
    try {
      if (_currentAudioPath != audioPath) {
        await _player.stop();
        await _player.play(AssetSource(audioPath));
        _currentAudioPath = audioPath;
      }
      _isPlaying = true;
      _isPaused = false;
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> pauseAudio() async {
    try {
      await _player.pause();
      _isPlaying = false;
      _isPaused = true;
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  Future<void> resumeAudio() async {
    try {
      await _player.resume();
      _isPlaying = true;
      _isPaused = false;
    } catch (e) {
      print('Error resuming audio: $e');
    }
  }

  Future<void> stopAudio() async {
    try {
      await _player.stop();
      _isPlaying = false;
      _isPaused = false;
      _currentAudioPath = null;
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  Future<void> playBackgroundMusic(String musicPath, {double volume = 0.3}) async {
    try {
      await _backgroundPlayer.setVolume(volume);
      await _backgroundPlayer.play(AssetSource(musicPath));
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  void dispose() {
    _player.dispose();
    _backgroundPlayer.dispose();
  }
}