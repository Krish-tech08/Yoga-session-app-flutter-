class AsanaMetadata {
  final String id;
  final String title;
  final String category;
  final int defaultLoopCount;
  final String tempo;

  AsanaMetadata({
    required this.id,
    required this.title,
    required this.category,
    required this.defaultLoopCount,
    required this.tempo,
  });

  factory AsanaMetadata.fromJson(Map<String, dynamic> json) {
    return AsanaMetadata(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      defaultLoopCount: json['defaultLoopCount'] ?? 1,
      tempo: json['tempo'] ?? 'normal',
    );
  }
}

class AsanaAssets {
  final Map<String, String> images;
  final Map<String, String> audio;

  AsanaAssets({
    required this.images,
    required this.audio,
  });

  factory AsanaAssets.fromJson(Map<String, dynamic> json) {
    return AsanaAssets(
      images: Map<String, String>.from(json['images'] ?? {}),
      audio: Map<String, String>.from(json['audio'] ?? {}),
    );
  }
}

class ScriptElement {
  final String text;
  final int startSec;
  final int endSec;
  final String imageRef;

  ScriptElement({
    required this.text,
    required this.startSec,
    required this.endSec,
    required this.imageRef,
  });

  factory ScriptElement.fromJson(Map<String, dynamic> json) {
    return ScriptElement(
      text: json['text'] ?? '',
      startSec: json['startSec'] ?? 0,
      endSec: json['endSec'] ?? 0,
      imageRef: json['imageRef'] ?? '',
    );
  }

  int get duration => endSec - startSec;
}

class AsanaSequence {
  final String type;
  final String name;
  final String audioRef;
  final int durationSec;
  final int? iterations;
  final bool? loopable;
  final List<ScriptElement> script;

  AsanaSequence({
    required this.type,
    required this.name,
    required this.audioRef,
    required this.durationSec,
    this.iterations,
    this.loopable,
    required this.script,
  });

  factory AsanaSequence.fromJson(Map<String, dynamic> json) {
    var scriptList = json['script'] as List;
    List<ScriptElement> script = scriptList.map((scriptJson) => ScriptElement.fromJson(scriptJson)).toList();

    return AsanaSequence(
      type: json['type'] ?? 'segment',
      name: json['name'] ?? '',
      audioRef: json['audioRef'] ?? '',
      durationSec: json['durationSec'] ?? 0,
      iterations: json['iterations'] is String ? null : json['iterations'],
      loopable: json['loopable'],
      script: script,
    );
  }

  bool get isLoop => type == 'loop';
}

class AsanaSession {
  final AsanaMetadata metadata;
  final AsanaAssets assets;
  final List<AsanaSequence> sequence;
  late final int totalDuration;
  late final int actualLoopCount;

  AsanaSession({
    required this.metadata,
    required this.assets,
    required this.sequence,
    int? customLoopCount,
  }) {
    actualLoopCount = customLoopCount ?? metadata.defaultLoopCount;
    _calculateTotalDuration();
  }

  void _calculateTotalDuration() {
    totalDuration = sequence.fold(0, (sum, seq) {
      if (seq.isLoop) {
        return sum + (seq.durationSec * actualLoopCount);
      }
      return sum + seq.durationSec;
    });
  }

  factory AsanaSession.fromJson(Map<String, dynamic> json, {int? customLoopCount}) {
    var sequenceList = json['sequence'] as List;
    List<AsanaSequence> sequence = sequenceList.map((seqJson) => AsanaSequence.fromJson(seqJson)).toList();

    return AsanaSession(
      metadata: AsanaMetadata.fromJson(json['metadata'] ?? {}),
      assets: AsanaAssets.fromJson(json['assets'] ?? {}),
      sequence: sequence,
      customLoopCount: customLoopCount,
    );
  }

  String getImagePath(String imageRef) {
    return 'assets/images/${assets.images[imageRef] ?? 'placeholder.png'}';
  }

  String getAudioPath(String audioRef) {
    return 'assets/audio/${assets.audio[audioRef] ?? 'silence.mp3'}';
  }
}