class TimerModel {
  final String id;
  final String name;
  final int duration; // saniye cinsinden
  int remaining; // saniye cinsinden
  bool isRunning;

  TimerModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.remaining,
    this.isRunning = false,
  });

  factory TimerModel.fromJson(Map<String, dynamic> json) {
    return TimerModel(
      id: json['id'],
      name: json['name'],
      duration: json['duration'],
      remaining: json['remaining'],
      isRunning: json['isRunning'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'remaining': remaining,
      'isRunning': isRunning,
    };
  }

  TimerModel copyWith({
    String? id,
    String? name,
    int? duration,
    int? remaining,
    bool? isRunning,
  }) {
    return TimerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      remaining: remaining ?? this.remaining,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}