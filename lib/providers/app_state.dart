import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/farmer_profile.dart';
import '../models/crop_session.dart';
import '../models/sensor_reading.dart';
import '../services/firebase_service.dart';
import '../services/yield_prediction_service.dart';

class AppState extends ChangeNotifier {
  // ─── Farmer ──────────────────────────────────────────────────────────────
  FarmerProfile? _profile;
  FarmerProfile? get profile => _profile;
  String get farmerName => _profile?.name ?? 'Farmer';
  String get farmerEmail => _profile?.email ?? '';
  int get totalDaysMonitored => _profile?.totalDaysMonitored ?? 0;
  int get alertsResolved => _profile?.alertsResolved ?? 0;

  void setProfile(FarmerProfile p) {
    _profile = p;
    notifyListeners();
  }

  // ─── Crop Session ─────────────────────────────────────────────────────────
  CropSession? _session;
  CropSession? get session => _session;

  String get cropType => _session?.cropType ?? 'Capsicum';
  String get growthStage => _session?.growthStage ?? 'Flowering';
  int get daysPlanted => _session?.daysPlanted ?? 50;
  double get targetYield => _session?.targetYield ?? 3.0;

  int get totalDays => cropType == 'Spinach' ? 45 : 80;
  double get progressPercent => (daysPlanted / totalDays).clamp(0.0, 1.0);
  int get remainingDays => (totalDays - daysPlanted).clamp(0, totalDays);
  DateTime get harvestDate => DateTime.now().add(Duration(days: remainingDays));

  CropConfig get cropConfig =>
      cropType == 'Spinach' ? spinachConfig : capsicumConfig;

  String get statusMessage => cropConfig.statusMessages[growthStage] ?? '';

  GrowthStage? get currentStageObj {
    for (var s in cropConfig.stages) {
      if (growthStage == s.name) return s;
    }
    return null;
  }

  void setSession(CropSession s) {
    _session = s;
    notifyListeners();
  }

  Future<void> setCropType(String crop) async {
    if (_session == null) return;
    final config = crop == 'Spinach' ? spinachConfig : capsicumConfig;
    _session = _session!.copyWith(
      cropType: crop,
      growthStage: config.stages.first.name,
      daysPlanted: 1,
    );
    await FirebaseService.instance.saveCropSession(_session!);
    notifyListeners();
  }

  Future<void> setGrowthStage(String stage) async {
    if (_session == null) return;
    _session = _session!.copyWith(growthStage: stage);
    await FirebaseService.instance.saveCropSession(_session!);
    notifyListeners();
  }

  Future<void> setDaysPlanted(int days) async {
    if (_session == null) return;
    _session = _session!.copyWith(daysPlanted: days);
    await FirebaseService.instance.saveCropSession(_session!);
    notifyListeners();
  }

  Future<void> setTargetYield(double val) async {
    if (_session == null) return;
    _session = _session!.copyWith(targetYield: val);
    await FirebaseService.instance.saveCropSession(_session!);
    notifyListeners();
  }

  // ─── Yield Prediction ────────────────────────────────────────────────────
  double predictedYield = 2.1;
  bool isPredicting = false;
  
  Future<void> updateYieldPrediction(SensorReading sensor) async {
    if (_profile == null || _session == null) return;
    
    isPredicting = true;
    notifyListeners();

    final result = await YieldPredictionService.getPrediction(
      sensor: sensor,
      session: _session!,
      profile: _profile!,
    );

    if (result != null && result.containsKey('prediction')) {
      predictedYield = result['prediction'];
    }
    
    isPredicting = false;
    notifyListeners();
  }

  double get yieldGap => targetYield - predictedYield;
  String get alertLevel => AppData.alertLevel;

  // ─── Notification Toggles ─────────────────────────────────────────────────
  bool criticalAlertsEnabled = true;
  bool dailySummaryEnabled = true;
  bool harvestReminderEnabled = true;

  void toggleCriticalAlerts(bool val) {
    criticalAlertsEnabled = val;
    notifyListeners();
  }

  void toggleDailySummary(bool val) {
    dailySummaryEnabled = val;
    notifyListeners();
  }

  void toggleHarvestReminder(bool val) {
    harvestReminderEnabled = val;
    notifyListeners();
  }

  // ─── Load from Firebase ──────────────────────────────────────────────────
  Future<void> loadFromFirebase(String email) async {
    final profile = await FirebaseService.instance.getFarmerProfile(email);
    if (profile != null) {
      _profile = profile;
    }
    final session = await FirebaseService.instance.getActiveCropSession(email);
    if (session != null) {
      _session = session;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseService.instance.signOut();
    _profile = null;
    _session = null;
    notifyListeners();
  }
}
