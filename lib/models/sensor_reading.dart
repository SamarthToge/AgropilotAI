class SensorReading {
  final String? id;
  final double temperature;
  final double humidity;
  final double co2;
  final double soilMoisture;
  final double light;
  final double ph;
  final DateTime timestamp;
  final String source; // "dummy", "esp32", "manual"

  const SensorReading({
    this.id,
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.soilMoisture,
    required this.light,
    required this.ph,
    required this.timestamp,
    this.source = 'dummy',
  });

  factory SensorReading.fromMap(Map<String, dynamic> map, {String? id}) {
    return SensorReading(
      id: id,
      temperature: (map['temperature'] as num).toDouble(),
      humidity: (map['humidity'] as num).toDouble(),
      co2: (map['co2'] as num).toDouble(),
      soilMoisture: (map['soil_moisture'] as num).toDouble(),
      light: (map['light'] as num?)?.toDouble() ?? 0.0,
      ph: (map['ph'] as num?)?.toDouble() ?? 7.0,
      timestamp: map['timestamp'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.parse(map['timestamp'].toString()),
      source: map['source'] as String? ?? 'dummy',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'co2': co2,
      'soil_moisture': soilMoisture,
      'light': light,
      'ph': ph,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'source': source,
    };
  }

  /// Converts to RTDB-style map (used by ESP32 or simulator)
  Map<String, dynamic> toLiveMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'co2': co2,
      'soil_moisture': soilMoisture,
      'light': light,
      'ph': ph,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  SensorReading copyWith({
    double? temperature,
    double? humidity,
    double? co2,
    double? soilMoisture,
    double? light,
    double? ph,
    DateTime? timestamp,
    String? source,
  }) {
    return SensorReading(
      id: id,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      co2: co2 ?? this.co2,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      light: light ?? this.light,
      ph: ph ?? this.ph,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
    );
  }
}
