import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/sensor_reading.dart';
import '../models/crop_session.dart';
import '../models/farmer_profile.dart';

class YieldPredictionService {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    return 'http://10.0.2.2:8000'; // Android emulator localhost
  }

  static Future<Map<String, dynamic>?> getPrediction({
    required SensorReading sensor,
    required CropSession session,
    required FarmerProfile profile,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'temperature': sensor.temperature,
          'humidity': sensor.humidity,
          'co2': sensor.co2,
          'light': sensor.light,
          'soil_moisture': sensor.soilMoisture,
          'ph': sensor.ph,
          'crop_type': session.cropType,
          'days_planted': session.daysPlanted,
          'soil_type': session.soilType,
          'region': profile.location.isEmpty ? 'Central' : profile.location,
          'growth_stage': session.growthStage,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to get prediction: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling prediction API: $e');
      return null;
    }
  }
}
