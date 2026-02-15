class StreamModel {
  final String id;
  final String callId;
  final String hostId;
  final String title;
  final String status;
  final bool isRecordingEnabled;
  final DateTime createdAt;
  final DateTime? endedAt;
  final Recording? recording;

  StreamModel({
    required this.id,
    required this.callId,
    required this.hostId,
    required this.title,
    required this.status,
    required this.isRecordingEnabled,
    required this.createdAt,
    this.endedAt,
    this.recording,
  });

  factory StreamModel.fromJson(Map<String, dynamic> json) {
    return StreamModel(
      id: json['_id'] as String,
      callId: json['callId'] as String,
      hostId: json['hostId'] as String,
      title: json['title'] as String,
      status: json['status'] as String? ?? 'active',
      isRecordingEnabled: json['isRecordingEnabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String)
          : null,
      recording: json['recording'] != null
          ? Recording.fromJson(json['recording'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'callId': callId,
      'hostId': hostId,
      'title': title,
      'status': status,
      'isRecordingEnabled': isRecordingEnabled,
      'createdAt': createdAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'recording': recording?.toJson(),
    };
  }

  bool get isActive => status == 'active';
  bool get isEnded => status == 'ended';
  bool get hasRecording => recording != null;
}

class Recording {
  final String fileName;
  final String filePath;
  final int duration;
  final int fileSize;
  final DateTime recordedAt;

  Recording({
    required this.fileName,
    required this.filePath,
    required this.duration,
    required this.fileSize,
    required this.recordedAt,
  });

  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      duration: json['duration'] as int,
      fileSize: json['fileSize'] as int,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'filePath': filePath,
      'duration': duration,
      'fileSize': fileSize,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedFileSize {
    final mb = fileSize / (1024 * 1024);
    return '${mb.toStringAsFixed(2)} MB';
  }
}
