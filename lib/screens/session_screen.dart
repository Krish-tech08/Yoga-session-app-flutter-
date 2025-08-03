import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';

import '../models/asana_session.dart';

class AsanaSessionScreen extends StatefulWidget {
  final AsanaSession session;

  const AsanaSessionScreen({super.key, required this.session});

  @override
  State<AsanaSessionScreen> createState() => _AsanaSessionScreenState();

  Future<void> initialize() async {}
}

class _AsanaSessionScreenState extends State<AsanaSessionScreen>
    with TickerProviderStateMixin {
  late AudioPlayer audioPlayer;
  late AnimationController fadeController;
  late AnimationController pulseController;

  int currentSequenceIndex = 0;
  int currentScriptIndex = 0;
  int currentLoopIteration = 0;
  int elapsedSeconds = 0;
  int sequenceElapsed = 0;
  bool isPlaying = false;
  bool isPaused = false;
  Timer? sessionTimer;
  String currentImageRef = '';
  String currentText = '';

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    initializeSession();
  }

  void initializeSession() {
    if (widget.session.sequence.isNotEmpty) {
      final firstSequence = widget.session.sequence[0];
      if (firstSequence.script.isNotEmpty) {
        currentImageRef = firstSequence.script[0].imageRef;
        currentText = firstSequence.script[0].text;
      }
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    fadeController.dispose();
    pulseController.dispose();
    sessionTimer?.cancel();
    super.dispose();
  }

  void startSession() async {
    setState(() {
      isPlaying = true;
      isPaused = false;
    });

    await playCurrentSequence();
    startSessionTimer();
  }

  void pauseSession() {
    setState(() {
      isPaused = true;
      isPlaying = false;
    });
    sessionTimer?.cancel();
    audioPlayer.pause();
  }

  void resumeSession() {
    setState(() {
      isPaused = false;
      isPlaying = true;
    });
    audioPlayer.resume();
    startSessionTimer();
  }

  Future<void> playCurrentSequence() async {
    final sequence = widget.session.sequence[currentSequenceIndex];
    final audioPath = widget.session.getAudioPath(sequence.audioRef);

    // In a real app, play the actual audio file
    // await audioPlayer.play(AssetSource(audioPath));

    // Reset sequence timing
    sequenceElapsed = 0;
    currentScriptIndex = 0;
    if (sequence.isLoop) {
      currentLoopIteration = 0;
    }

    updateCurrentScript();
  }

  void startSessionTimer() {
    sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
        sequenceElapsed++;
      });

      updateCurrentScript();
      checkSequenceCompletion();
    });
  }

  void updateCurrentScript() {
    final sequence = widget.session.sequence[currentSequenceIndex];
    final effectiveElapsed = sequenceElapsed;

    // Find current script element based on timing
    for (int i = 0; i < sequence.script.length; i++) {
      final script = sequence.script[i];
      final adjustedStart = sequence.isLoop
          ? script.startSec + (currentLoopIteration * sequence.durationSec)
          : script.startSec;
      final adjustedEnd = sequence.isLoop
          ? script.endSec + (currentLoopIteration * sequence.durationSec)
          : script.endSec;

      if (effectiveElapsed >= adjustedStart && effectiveElapsed < adjustedEnd) {
        if (currentScriptIndex != i ||
            currentImageRef != script.imageRef ||
            currentText != script.text) {

          setState(() {
            currentScriptIndex = i;
            currentImageRef = script.imageRef;
            currentText = script.text;
          });

          // Trigger fade animation for smooth transitions
          fadeController.reset();
          fadeController.forward();
        }
        break;
      }
    }
  }

  void checkSequenceCompletion() {
    final sequence = widget.session.sequence[currentSequenceIndex];

    if (sequence.isLoop) {
      // Check if current loop iteration is complete
      final loopDuration = sequence.durationSec;
      if (sequenceElapsed >= loopDuration * (currentLoopIteration + 1)) {
        currentLoopIteration++;

        // Check if all loop iterations are complete
        if (currentLoopIteration >= widget.session.actualLoopCount) {
          nextSequence();
        }
      }
    } else {
      // Check if segment is complete
      if (sequenceElapsed >= sequence.durationSec) {
        nextSequence();
      }
    }
  }

  void nextSequence() {
    if (currentSequenceIndex < widget.session.sequence.length - 1) {
      setState(() {
        currentSequenceIndex++;
        currentLoopIteration = 0;
      });
      playCurrentSequence();
    } else {
      completeSession();
    }
  }

  void completeSession() {
    setState(() {
      isPlaying = false;
    });
    sessionTimer?.cancel();
    audioPlayer.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green[400],
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              'Beautiful work! You completed ${widget.session.metadata.title}.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sequence = widget.session.sequence[currentSequenceIndex];
    final totalProgress = elapsedSeconds / widget.session.totalDuration;
    final sequenceProgress = sequence.isLoop
        ? (sequenceElapsed % sequence.durationSec) / sequence.durationSec
        : sequenceElapsed / sequence.durationSec;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      Column(
                        children: [
                          Text(
                            widget.session.metadata.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sequence.isLoop
                                ? 'Loop ${currentLoopIteration + 1}/${widget.session.actualLoopCount}'
                                : sequence.name.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${elapsedSeconds ~/ 60}:${(elapsedSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Overall Progress Bar
                  LinearProgressIndicator(
                    value: totalProgress,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                  ),
                  const SizedBox(height: 8),

                  // Sequence Progress Bar
                  LinearProgressIndicator(
                    value: sequenceProgress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        sequence.isLoop ? const Color(0xFF4facfe) : const Color(0xFF00f2fe)
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Image Area
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Pose Image with smooth transitions
                            FadeTransition(
                              opacity: fadeController,
                              child: AnimatedBuilder(
                                animation: pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 + (pulseController.value * 0.03),
                                    child: Container(
                                      width: 220,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF667eea).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFF667eea),
                                          width: 2,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _getIconForImage(currentImageRef),
                                            size: 80,
                                            color: const Color(0xFF667eea),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            currentImageRef.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF667eea),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Script Text Area
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Current instruction text
                            Expanded(
                              child: Center(
                                child: FadeTransition(
                                  opacity: fadeController,
                                  child: Text(
                                    currentText,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      height: 1.5,
                                      color: Color(0xFF333333),
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Control Button
                            GestureDetector(
                              onTap: () {
                                if (!isPlaying && !isPaused) {
                                  startSession();
                                } else if (isPlaying) {
                                  pauseSession();
                                } else {
                                  resumeSession();
                                }
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF667eea),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  (!isPlaying && !isPaused)
                                      ? Icons.play_arrow
                                      : isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForImage(String imageRef) {
    switch (imageRef.toLowerCase()) {
      case 'base':
        return Icons.self_improvement;
      case 'cat':
        return Icons.pets;
      case 'cow':
        return Icons.agriculture;
      default:
        return Icons.self_improvement;
    }
  }
}
Map<String, dynamic> getSampleAsanaData() {
  return {
    "metadata": {
      "id": "asana_cat_cow_v1",
      "title": "Cat-Cow Flow",
      "category": "spinal_mobility",
      "defaultLoopCount": 4,
      "tempo": "slow"
    },
    "assets": {
      "images": {
        "base": "Base.png",
        "cat": "Cat.png",
        "cow": "Cow.png"
      },
      "audio": {
        "intro": "cat_cow_intro.mp3",
        "loop": "cat_cow_loop.mp3",
        "outro": "cat_cow_outro.mp3"
      }
    },
    "sequence": [
      {
        "type": "segment",
        "name": "intro",
        "audioRef": "intro",
        "durationSec": 23,
        "script": [
          {
            "text": "Come to all fours. Hands below shoulders, knees under hips. Feel the earth beneath you — steady, quiet, alive.",
            "startSec": 7,
            "endSec": 14,
            "imageRef": "cat"
          },
          {
            "text": "Exhale… round your back, tuck your chin. Feel the breath soften you like morning mist.",
            "startSec": 14,
            "endSec": 23,
            "imageRef": "cow"
          }
        ]
      },
      {
        "type": "loop",
        "name": "breath_cycle",
        "audioRef": "loop",
        "durationSec": 20,
        "iterations": "{{loopCount}}",
        "loopable": true,
        "script": [
          {
            "text": "Inhale… open, expand, shine.",
            "startSec": 0,
            "endSec": 8,
            "imageRef": "cat"
          },
          {
            "text": "Exhale… release, soften, ground.",
            "startSec": 8,
            "endSec": 16,
            "imageRef": "cow"
          },
          {
            "text": "Feel your spine flowing like a wave through the trees.",
            "startSec": 16,
            "endSec": 20,
            "imageRef": "base"
          }
        ]
      },
      {
        "type": "segment",
        "name": "outro",
        "audioRef": "outro",
        "durationSec": 18,
        "script": [
          {
            "text": "Finish your final round…",
            "startSec": 0,
            "endSec": 4,
            "imageRef": "cat"
          },
          {
            "text": "and return to a neutral spine.",
            "startSec": 4,
            "endSec": 7,
            "imageRef": "cow"
          },
          {
            "text": "Notice the warmth in your back, the ease in your breath. You are supported — rooted, yet free.",
            "startSec": 7,
            "endSec": 18,
            "imageRef": "base"
          }
        ]
      }
    ]
  };
}