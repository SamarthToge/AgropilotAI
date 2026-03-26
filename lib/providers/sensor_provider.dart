import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sensor_reading.dart';
import '../constants/app_constants.dart';
import '../services/firebase_service.dart';

/// Manages live sensor data — subscribes to RTDB stream (ESP32 / dummy).
/// When the ESP32 is connected, this provider auto-updates in real-time.
class SensorProvider extends ChangeNotifier {
  StreamSubscription<SensorReading?>? _sub;

  double temperature = 24.5;
  double humidity = 65.0;
  double co2 = 950.0;
  double soilMoisture = 43.0;
  double light = 320.0;
  double ph = 7.0;
  DateTime? lastUpdated;
  String dataSource = 'dummy'; // 'dummy' | 'esp32'
  bool isLoading = true;

  SensorReading? get lastReading => lastUpdated != null
      ? SensorReading(
          temperature: temperature,
          humidity: humidity,
          co2: co2,
          soilMoisture: soilMoisture,
          light: light,
          ph: ph,
          timestamp: lastUpdated!,
          source: dataSource,
        )
      : null;

  SensorStatus get tempStatus => getSensorStatus('temperature', temperature);
  SensorStatus get humidityStatus => getSensorStatus('humidity', humidity);
  SensorStatus get co2Status => getSensorStatus('co2', co2);
  SensorStatus get soilStatus => getSensorStatus('soil', soilMoisture);
  SensorStatus get phStatus => getSensorStatus('ph', ph);

  String get alertLevel {
    final statuses = [tempStatus, humidityStatus, co2Status, soilStatus, phStatus];
    if (statuses.any((s) => s == SensorStatus.critical)) return 'Critical';
    if (statuses.any((s) => s == SensorStatus.warning)) return 'Warning';
    return 'Good';
  }

  void startListening() {
    _sub?.cancel();
    _sub = FirebaseService.instance.streamLiveSensors().listen(
      (reading) {
        if (reading != null) {
          temperature = reading.temperature;
          humidity = reading.humidity;
          co2 = reading.co2;
          soilMoisture = reading.soilMoisture;
          light = reading.light;
          ph = reading.ph;
          lastUpdated = reading.timestamp;
          dataSource = reading.source;
          isLoading = false;
          notifyListeners();
        }
      },
      onError: (_) {
        isLoading = false;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
