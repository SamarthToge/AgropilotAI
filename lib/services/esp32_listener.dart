import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sensor_reading.dart';
import '../services/firebase_service.dart';

/// Listens to Firebase Realtime Database path: /greenhouse/sensors/live
///
/// ─── ESP32 Integration Guide ──────────────────────────────────────────────
/// When the ESP32 is ready, program it with the Arduino Firebase library
/// (FirebaseESP32) to write the following JSON to RTDB:
///
///   Path: /greenhouse/sensors/live
///   Payload: {
///     "temperature": <float>,
///     "humidity":    <float>,
///     "co2":         <float>,
///     "soil_moisture": <float>,
///     "light":       <float>,
///     "ph":          <float>,
///     "timestamp":   <unix_ms>
///   }
///
/// The app will receive updates within ~1 second automatically.
/// No code changes needed in the app — just set the RTDB path above.
///
/// Sample ESP32 Arduino code snippet:
///   FirebaseJson json;
///   json.set("temperature", dht.readTemperature());
///   json.set("humidity",    dht.readHumidity());
///   json.set("co2",         mq135.getPPM());
///   json.set("soil_moisture", analogRead(SOIL_PIN) / 4095.0 * 100);
///   json.set("light",       analogRead(LDR_PIN));
///   json.set("ph",          analogRead(PH_PIN) / 1023.0 * 14.0);
///   json.set("timestamp",   millis());  // or NTP timestamp
///   Firebase.setJSON(fbdo, "/greenhouse/sensors/live", json);
/// ─────────────────────────────────────────────────────────────────────────
class Esp32Listener extends ChangeNotifier {
  StreamSubscription<SensorReading?>? _sub;
  SensorReading? _currentReading;
  bool _isConnected = false;
  String _dataSource = 'dummy';

  SensorReading? get currentReading => _currentReading;
  bool get isConnected => _isConnected;
  String get dataSource => _dataSource;

  void startListening() {
    _sub?.cancel();
    _sub = FirebaseService.instance.streamLiveSensors().listen(
      (reading) {
        if (reading != null) {
          _currentReading = reading;
          _isConnected = true;
          _dataSource = reading.source;
          notifyListeners();
        }
      },
      onError: (_) {
        _isConnected = false;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
    _isConnected = false;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
