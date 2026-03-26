import 'package:flutter/foundation.dart';
import '../models/sensor_reading.dart';
import '../models/alert_log.dart';
import '../services/firebase_service.dart';
import '../constants/app_constants.dart';

/// Manages historical sensor data and alert logs loaded from Firestore.
class HistoryProvider extends ChangeNotifier {
  List<SensorReading> _readings24h = [];
  List<SensorReading> _readings30d = [];
  List<AlertLog> _alertLogs = [];
  bool isLoading = false;

  List<SensorReading> get readings24h => _readings24h;
  List<SensorReading> get readings30d => _readings30d;
  List<AlertLog> get alertLogs => _alertLogs;

  // ─── 24h readings for sensor charts ─────────────────────────────────────

  Future<void> load24hReadings() async {
    isLoading = true;
    notifyListeners();
    try {
      _readings24h = await FirebaseService.instance.getReadingsForPastHours(24);
    } catch (_) {
      _readings24h = _fallback24h();
    }
    isLoading = false;
    notifyListeners();
  }

  /// Returns hourly values for a given sensor key from 24h data
  List<double> getSensorHistory(String key) {
    if (_readings24h.isEmpty) return _fallback24h().map((r) => _val(r, key)).toList();
    // Bucket into 24 hourly averages
    final now = DateTime.now();
    final result = <double>[];
    for (int h = 23; h >= 0; h--) {
      final hourStart = DateTime(now.year, now.month, now.day, now.hour - h);
      final hourEnd = hourStart.add(const Duration(hours: 1));
      final bucket = _readings24h
          .where((r) => r.timestamp.isAfter(hourStart) && r.timestamp.isBefore(hourEnd))
          .toList();
      if (bucket.isEmpty) {
        result.add(_val(_readings24h.last, key));
      } else {
        final avg = bucket.map((r) => _val(r, key)).reduce((a, b) => a + b) / bucket.length;
        result.add(avg);
      }
    }
    return result;
  }

  double _val(SensorReading r, String key) {
    switch (key) {
      case 'temperature': return r.temperature;
      case 'humidity': return r.humidity;
      case 'co2': return r.co2;
      default: return r.soilMoisture;
    }
  }

  // ─── 30-day data for yield trend ─────────────────────────────────────────

  Future<void> load30dReadings() async {
    try {
      _readings30d = await FirebaseService.instance.getReadingsForPastDays(30);
    } catch (_) {
      _readings30d = [];
    }
    notifyListeners();
  }

  /// Weekly yield (derived from soil + temp averages as proxy)
  List<double> get weeklyYieldTrend {
    if (_readings30d.isEmpty) return [2.8, 2.6, 2.4, 2.1];
    final weeks = <double>[];
    for (int w = 4; w >= 1; w--) {
      final weekStart = DateTime.now().subtract(Duration(days: w * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final bucket = _readings30d
          .where((r) => r.timestamp.isAfter(weekStart) && r.timestamp.isBefore(weekEnd))
          .toList();
      if (bucket.isEmpty) {
        weeks.add(2.0 + w * 0.2);
      } else {
        final avgSoil = bucket.map((r) => r.soilMoisture).reduce((a, b) => a + b) / bucket.length;
        final avgTemp = bucket.map((r) => r.temperature).reduce((a, b) => a + b) / bucket.length;
        // Simple proxy: good soil (65%) + good temp (24°C) → max yield 3.0
        final soilScore = (avgSoil / 65.0).clamp(0.5, 1.0);
        final tempScore = (1.0 - (avgTemp - 24.0).abs() / 10.0).clamp(0.5, 1.0);
        weeks.add((3.0 * soilScore * tempScore * 0.95).clamp(1.5, 3.2));
      }
    }
    return weeks;
  }

  /// Weekly sensor averages
  Map<String, double> get weeklySensorAverages {
    if (_readings30d.isEmpty) {
      return {'temperature': 24.2, 'humidity': 64.3, 'co2': 941, 'soil': 44.2};
    }
    final last7 = _readings30d
        .where((r) => r.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();
    if (last7.isEmpty) return {'temperature': 24.2, 'humidity': 64.3, 'co2': 941, 'soil': 44.2};
    double avgTemp = 0, avgHum = 0, avgCo2 = 0, avgSoil = 0;
    for (final r in last7) {
      avgTemp += r.temperature;
      avgHum += r.humidity;
      avgCo2 += r.co2;
      avgSoil += r.soilMoisture;
    }
    final n = last7.length.toDouble();
    return {
      'temperature': avgTemp / n,
      'humidity': avgHum / n,
      'co2': avgCo2 / n,
      'soil': avgSoil / n,
    };
  }

  // ─── Alert Logs ──────────────────────────────────────────────────────────

  Future<void> loadAlertLogs() async {
    try {
      _alertLogs = await FirebaseService.instance.getAlertLogs(days: 30);
    } catch (_) {
      _alertLogs = [];
    }
    notifyListeners();
  }

  /// Alerts grouped by day label (Today, Yesterday, etc.)
  Map<String, List<AlertLog>> get alertsByDay {
    final grouped = <String, List<AlertLog>>{};
    for (final a in _alertLogs) {
      grouped.putIfAbsent(a.dayLabel, () => []).add(a);
    }
    return grouped;
  }

  /// Only unresolved alerts (for dashboard)
  List<AlertLog> get activeAlerts => _alertLogs.where((a) => !a.resolved).toList();

  // ─── Fallback 24h data (when Firestore unavailable) ────────────────────

  List<SensorReading> _fallback24h() {
    final now = DateTime.now();
    return List.generate(24, (i) => SensorReading(
      temperature: SensorHistory.temperature[i],
      humidity: SensorHistory.humidity[i],
      co2: SensorHistory.co2[i],
      soilMoisture: SensorHistory.soilMoisture[i],
      light: 200,
      ph: 7.0,
      timestamp: DateTime(now.year, now.month, now.day, i),
    ));
  }

  Future<void> loadAll() async {
    isLoading = true;
    notifyListeners();
    await Future.wait([
      load24hReadings(),
      load30dReadings(),
      loadAlertLogs(),
    ]);
    isLoading = false;
    notifyListeners();
  }
}
