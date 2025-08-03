class YogaPose {
  final int id;
  final String name;
  final String? sanskritName;
  final String imagePath;
  final String audioPath;
  final int duration;
  final String description;
  final List<String> instructions;
  final List<String> benefits;
  final String difficulty;

  YogaPose({
    required this.id,
    required this.name,
    this.sanskritName,
    required this.imagePath,
    required this.audioPath,
    required this.duration,
    required this.description,
    this.instructions = const [],
    this.benefits = const [],
    this.difficulty = 'beginner',
  });

  factory YogaPose.fromJson(Map<String, dynamic> json) {
    return YogaPose(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sanskritName: json['sanskritName'],
      imagePath: json['imagePath'] ?? '',
      audioPath: json['audioPath'] ?? '',
      duration: json['duration'] ?? 30,
      description: json['description'] ?? '',
      instructions: List<String>.from(json['instructions'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      difficulty: json['difficulty'] ?? 'beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sanskritName': sanskritName,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'duration': duration,
      'description': description,
      'instructions': instructions,
      'benefits': benefits,
      'difficulty': difficulty,
    };
  }
}