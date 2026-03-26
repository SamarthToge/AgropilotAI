import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sensor_reading.dart';
import '../models/crop_session.dart';
import '../models/alert_log.dart';
import 'firebase_service.dart';

/// Seeds realistic 30-day dummy data into Firebase on first app launch.
/// A SharedPreferences flag prevents re-seeding on subsequent launches.
class DummyDataSeeder {
  DummyDataSeeder._();
  static final DummyDataSeeder instance = DummyDataSeeder._();

  static const _seededKey = 'agropilot_data_seeded_v2';
  final _rng = Random(42);

  Future<bool> hasBeenSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seededKey) ?? false;
  }

  Future<void> seedAll() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seededKey) == true) return;

    await _seedFarmerProfile();
    await _seedCropSession();

    final readings = _generateReadings();
    await FirebaseService.instance.batchSaveSensorReadings(readings);
    await FirebaseService.instance.writeLiveSensorToRTDB(readings.last);

    await _seedAlertLogs();

    await prefs.setBool(_seededKey, true);
  }

  Future<void> _seedFarmerProfile() async {
    final now = DateTime.now();
    await FirebaseFirestore.instance.collection('farmers').doc('satyam@agropilot.com').set({
      'email': 'satyam@agropilot.com',
      'name': 'Satyam',
      'phone': '+91 98765 43210',
      'location': 'Central', // Use a valid region class from encoder
      'total_days_monitored': 50,
      'alerts_resolved': 7,
      'total_crop_sessions': 3,
      'last_login': now.millisecondsSinceEpoch,
      'password': 'agro123',
    }, SetOptions(merge: true));
  }

  Future<void> _seedCropSession() async {
    final session = CropSession(
      farmerEmail: 'satyam@agropilot.com',
      cropType: 'Capsicum',
      growthStage: 'Flowering',
      soilType: 'Loamy', // Use a valid soil type class
      daysPlanted: 50,
      startDate: DateTime.now().subtract(const Duration(days: 50)),
      targetYield: 3.0,
      isActive: true,
    );
    await FirebaseService.instance.saveCropSession(session);
  }

  /// Generates 30 days × 24 hourly readings = 720 realistic sensor documents
  List<SensorReading> _generateReadings() {
    final now = DateTime.now();
    final readings = <SensorReading>[];

    for (int day = 29; day >= 0; day--) {
      for (int hour = 0; hour < 24; hour++) {
        final ts = DateTime(now.year, now.month, now.day - day, hour);
        final dayFactor = day / 30.0;
        final nightDip = sin(hour / 24.0 * 2 * pi);

        final temp = (24.5 + nightDip * 2.0 + _j(0.6) - dayFactor * 0.5).clamp(18.0, 32.0);
        final humidity = (65.0 - nightDip * 3.0 + _j(1.5) + dayFactor * 2.0).clamp(45.0, 80.0);
        final co2 = (940.0 + nightDip * 20.0 + _j(15) + dayFactor * 10).clamp(700.0, 1200.0);
        final ph = (6.5 + _j(0.2)).clamp(5.5, 7.5);
        final irrigationBump = (hour == 6 || hour == 18) ? 5.0 : 0.0;
        final soilMoisture =
            (55.0 - dayFactor * 12.0 + irrigationBump + _j(1.5)).clamp(30.0, 80.0);
        final light = (hour >= 6 && hour <= 18)
            ? (200.0 + sin((hour - 6) / 12.0 * pi) * 200 + _j(20)).clamp(0.0, 500.0)
            : 0.0;

        readings.add(SensorReading(
          temperature: temp,
          humidity: humidity,
          co2: co2,
          soilMoisture: soilMoisture,
          light: light,
          ph: ph,
          timestamp: ts,
          source: 'dummy',
        ));
      }
    }
    return readings;
  }

  double _j(double range) => (_rng.nextDouble() - 0.5) * 2 * range;

  Future<void> _seedAlertLogs() async {
    final now = DateTime.now();
    final alerts = [
      AlertLog(
        sensorKey: 'co2',
        severity: 'Warning',
        title: 'CO₂ Borderline High',
        message: 'CO₂ approaching upper limit. Open vents slightly.',
        currentValue: '950 ppm',
        idealValue: '800–1000 ppm',
        timestamp: now.subtract(const Duration(hours: 2)),
        resolved: false,
      ),
      AlertLog(
        sensorKey: 'soil',
        severity: 'Warning',
        title: 'Soil Moisture Low',
        message: 'Activate water pump — increase irrigation cycle by 10 min.',
        currentValue: '43%',
        idealValue: '60–75%',
        timestamp: now.subtract(const Duration(hours: 3)),
        resolved: false,
      ),
      AlertLog(
        sensorKey: 'soil',
        severity: 'Warning',
        title: 'Soil Moisture Low',
        message: 'Soil moisture below optimal. Check drip nozzle blockage.',
        currentValue: '45%',
        idealValue: '60–75%',
        timestamp: now.subtract(const Duration(days: 1, hours: 4)),
        resolved: true,
      ),
      AlertLog(
        sensorKey: 'temperature',
        severity: 'Critical',
        title: 'Temperature Spike',
        message: 'Temperature exceeded safe range. Activate cooling vents.',
        currentValue: '30.2°C',
        idealValue: '20–27°C',
        timestamp: now.subtract(const Duration(days: 3, hours: 10)),
        resolved: true,
      ),
      AlertLog(
        sensorKey: 'humidity',
        severity: 'Warning',
        title: 'Humidity Dropping',
        message: 'Humidity below optimal for flowering stage. Run mist system.',
        currentValue: '47%',
        idealValue: '50–70%',
        timestamp: now.subtract(const Duration(days: 5, hours: 6)),
        resolved: true,
      ),
      AlertLog(
        sensorKey: 'co2',
        severity: 'Warning',
        title: 'CO₂ Rising',
        message: 'CO₂ trending upward. Monitor ventilation.',
        currentValue: '980 ppm',
        idealValue: '800–1000 ppm',
        timestamp: now.subtract(const Duration(days: 7, hours: 2)),
        resolved: true,
      ),
    ];
    await FirebaseService.instance.batchSaveAlertLogs(alerts);
  }
}
