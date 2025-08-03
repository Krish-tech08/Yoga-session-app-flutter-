import 'dart:async';
import 'package:yoga_session_app/services/yoga_data_loader.dart' hide AsanaSession;


import '../models/asana_session.dart';
import 'audio_service.dart';

class SessionManager {
  final AsanaSession session;
  final AudioService _audioService = AudioService();

  int currentSequenceIndex = 0;
  int currentScriptIndex = 0;
  int currentLoopIteration = 0;
  int elapsedSeconds = 0;
  int sequenceElapsed = 0;

  Timer? _timer;

  // Callbacks
  Function(String imageRef, String text)? onScriptUpdate;
  Function()? onSequenceComplete;
  Function()? onSessionComplete;
  Function(double progress)? onProgressUpdate;

  SessionManager(this.session);

  AsanaSequence get currentSequence => session.sequence[currentSequenceIndex];
  ScriptElement get currentScript => currentSequence.script[currentScriptIndex];

  bool get isLastSequence => currentSequenceIndex >= session.sequence.length - 1;

  double get totalProgress => elapsedSeconds / session.totalDuration;
  double get sequenceProgress {
    final seq = currentSequence;
    if (seq.isLoop) {
      return (sequenceElapsed % seq.durationSec) / seq.durationSec;
    }
    return sequenceElapsed / seq.durationSec;
  }

  void startSession() {
    _playCurrentSequence();
    _startTimer();
  }

  void pauseSession() {
    _timer?.cancel();
    _audioService.pauseAudio();
  }

  void resumeSession() {
    _audioService.resumeAudio();
    _startTimer();
  }

  void stopSession() {
    _timer?.cancel();
    _audioService.stopAudio();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds++;
      sequenceElapsed++;

      _updateCurrentScript();
      _checkSequenceCompletion();

      onProgressUpdate?.call(totalProgress);
    });
  }

  void _playCurrentSequence() async {
    final audioPath = session.getAudioPath(currentSequence.audioRef);
    await _audioService.playAudio(audioPath);

    sequenceElapsed = 0;
    currentScriptIndex = 0;
    if (currentSequence.isLoop) {
      currentLoopIteration = 0;
    }

    _updateCurrentScript();
  }

  void _updateCurrentScript() {
    final sequence = currentSequence;

    for (int i = 0; i < sequence.script.length; i++) {
      final script = sequence.script[i];
      final adjustedStart = sequence.isLoop
          ? script.startSec + (currentLoopIteration * sequence.durationSec)
          : script.startSec;
      final adjustedEnd = sequence.isLoop
          ? script.endSec + (currentLoopIteration * sequence.durationSec)
          : script.endSec;

      if (sequenceElapsed >= adjustedStart && sequenceElapsed < adjustedEnd) {
        if (currentScriptIndex != i) {
          currentScriptIndex = i;
          onScriptUpdate?.call(script.imageRef, script.text);
        }
        break;
      }
    }
  }

  void _checkSequenceCompletion() {
    final sequence = currentSequence;

    if (sequence.isLoop) {
      final loopDuration = sequence.durationSec;
      if (sequenceElapsed >= loopDuration * (currentLoopIteration + 1)) {
        currentLoopIteration++;

        if (currentLoopIteration >= session.actualLoopCount) {
          _nextSequence();
        }
      }
    } else {
      if (sequenceElapsed >= sequence.durationSec) {
        _nextSequence();
      }
    }
  }

  void _nextSequence() {
    onSequenceComplete?.call();

    if (!isLastSequence) {
      currentSequenceIndex++;
      currentLoopIteration = 0;
      _playCurrentSequence();
    } else {
      _completeSession();
    }
  }

  void _completeSession() {
    _timer?.cancel();
    _audioService.stopAudio();
    onSessionComplete?.call();
  }

  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
  }
}