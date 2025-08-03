import 'yoga_pose.dart';

class YogaSession {
  final String sessionName;
  final String description;
  final String difficulty;
  final List<YogaPose> poses;
  final String? backgroundMusic;
  final SessionSettings settings;
  final int totalDuration;

  YogaSession({
    required this.sessionName,
    required this.description,
    required this.difficulty,
    required this.poses,
    this.backgroundMusic,
    required this.settings,
  }) : totalDuration = poses.fold(0, (sum, pose) => sum + pose.duration);

  factory YogaSession.fromJson(Map<String, dynamic> json) {
    var posesList = json['poses'] as List;
    List<YogaPose> poses = posesList.map((poseJson) => YogaPose.fromJson(poseJson)).toList();

    return YogaSession(
      sessionName: json['sessionName'] ?? 'Yoga Session',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? 'beginner',
      poses: poses,
      backgroundMusic: json['backgroundMusic'],
      settings: SessionSettings.fromJson(json['settings'] ?? {}),
    );
  }
}

class SessionSettings {
  final bool autoAdvance;
  final bool showInstructions;
  final double playbackSpeed;

  SessionSettings({
    this.autoAdvance = true,
    this.showInstructions = true,
    this.playbackSpeed = 1.0,
  });

  factory SessionSettings.fromJson(Map<String, dynamic> json) {
    return SessionSettings(
      autoAdvance: json['autoAdvance'] ?? true,
      showInstructions: json['showInstructions'] ?? true,
      playbackSpeed: (json['playbackSpeed'] ?? 1.0).toDouble(),
    );
  }
}