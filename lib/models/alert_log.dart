class AlertLog {
  final String? id;
  final String sensorKey;   // 'temperature', 'humidity', 'co2', 'soil'
  final String severity;    // 'Warning', 'Critical'
  final String title;
  final String message;
  final String currentValue;
  final String idealValue;
  final DateTime timestamp;
  final bool resolved;

  const AlertLog({
    this.id,
    required this.sensorKey,
    required this.severity,
    required this.title,
    required this.message,
    required this.currentValue,
    required this.idealValue,
    required this.timestamp,
    this.resolved = false,
  });

  factory AlertLog.fromMap(Map<String, dynamic> map, {String? id}) {
    return AlertLog(
      id: id,
      sensorKey: map['sensor_key'] as String? ?? '',
      severity: map['severity'] as String? ?? 'Warning',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      currentValue: map['current_value'] as String? ?? '',
      idealValue: map['ideal_value'] as String? ?? '',
      timestamp: map['timestamp'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
      resolved: map['resolved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sensor_key': sensorKey,
      'severity': severity,
      'title': title,
      'message': message,
      'current_value': currentValue,
      'ideal_value': idealValue,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'resolved': resolved,
    };
  }

  /// Returns the day label relative to today
  String get dayLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final alertDay = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final diff = today.difference(alertDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff Days Ago';
  }
}
