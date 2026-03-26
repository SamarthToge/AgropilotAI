import 'package:flutter/material.dart';

// ─── Colors ─────────────────────────────────────────────────────────────────
class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const primaryLight = Color(0xFF4CAF50);
  static const primaryDark = Color(0xFF1B5E20);
  static const secondary = Color(0xFF1565C0);
  static const secondaryLight = Color(0xFF1976D2);
  static const background = Color(0xFFF5F5F5);
  static const cardBg = Colors.white;
  static const good = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const critical = Color(0xFFF44336);
  static const goodBg = Color(0xFFE8F5E9);
  static const warningBg = Color(0xFFFFF8E1);
  static const criticalBg = Color(0xFFFFEBEE);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const divider = Color(0xFFEEEEEE);
}

// ─── Card Decoration ────────────────────────────────────────────────────────
BoxDecoration get cardDecoration => BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

// ─── Hardcoded Dummy Data ────────────────────────────────────────────────────
class AppData {
  // Farmer
  static String farmerName = "Satyam";

  // Crop
  static String cropType = "Capsicum";
  static String growthStage = "Flowering";
  static int daysPlanted = 50;
  static int totalDays = 80;

  // Sensors
  static double temperature = 24.5;
  static double humidity = 65.0;
  static double co2 = 950.0; // borderline high
  static double soilMoisture = 43.0; // low — warning
  static double light = 320.0;

  // Yield
  static double predictedYield = 2.1;
  static double targetYield = 3.0;
  static String alertLevel = "Warning";

  // Derived
  static double get yieldGap => targetYield - predictedYield;
  static int get remainingDays => totalDays - daysPlanted;

  // Estimated harvest date (today + remaining days)
  static DateTime get harvestDate =>
      DateTime(2026, 3, 8).add(Duration(days: remainingDays));
}

// ─── Crop Configs ─────────────────────────────────────────────────────────────
class CropConfig {
  final String name;
  final String emoji;
  final int totalDays;
  final double tempMin, tempMax;
  final double humidityMin, humidityMax;
  final double co2Min, co2Max;
  final double soilMin, soilMax;
  final double pidTemp, pidHumidity, pidCo2, pidMoisture;
  final List<GrowthStage> stages;
  final Map<String, String> statusMessages;

  const CropConfig({
    required this.name,
    required this.emoji,
    required this.totalDays,
    required this.tempMin,
    required this.tempMax,
    required this.humidityMin,
    required this.humidityMax,
    required this.co2Min,
    required this.co2Max,
    required this.soilMin,
    required this.soilMax,
    required this.pidTemp,
    required this.pidHumidity,
    required this.pidCo2,
    required this.pidMoisture,
    required this.stages,
    required this.statusMessages,
  });
}

class GrowthStage {
  final String name;
  final String emoji;
  final int startDay;
  final int endDay;

  const GrowthStage({
    required this.name,
    required this.emoji,
    required this.startDay,
    required this.endDay,
  });
}

final CropConfig spinachConfig = CropConfig(
  name: "Spinach",
  emoji: "🌿",
  totalDays: 45,
  tempMin: 10,
  tempMax: 20,
  humidityMin: 50,
  humidityMax: 70,
  co2Min: 700,
  co2Max: 900,
  soilMin: 50,
  soilMax: 70,
  pidTemp: 15,
  pidHumidity: 60,
  pidCo2: 800,
  pidMoisture: 60,
  stages: [
    GrowthStage(name: "Seedling", emoji: "🌱", startDay: 1, endDay: 7),
    GrowthStage(name: "Vegetative", emoji: "🌿", startDay: 8, endDay: 25),
    GrowthStage(name: "Maturation", emoji: "🍃", startDay: 26, endDay: 40),
    GrowthStage(name: "Harvest", emoji: "✂️", startDay: 41, endDay: 50),
  ],
  statusMessages: {
    "Seedling":
        "Germination phase — keep temperature between 10–15°C and avoid overwatering",
    "Vegetative":
        "Rapid leaf growth — this stage determines final yield, maintain moisture at 60%",
    "Maturation":
        "Leaves maturing — reduce nitrogen, monitor for bolting if temperature rises above 20°C",
    "Harvest":
        "Spinach ready to harvest — cut outer leaves first, check for yellowing daily",
  },
);

final CropConfig capsicumConfig = CropConfig(
  name: "Capsicum",
  emoji: "🫑",
  totalDays: 80,
  tempMin: 20,
  tempMax: 27,
  humidityMin: 50,
  humidityMax: 70,
  co2Min: 800,
  co2Max: 1000,
  soilMin: 60,
  soilMax: 75,
  pidTemp: 24,
  pidHumidity: 60,
  pidCo2: 900,
  pidMoisture: 67,
  stages: [
    GrowthStage(name: "Seedling", emoji: "🌱", startDay: 1, endDay: 15),
    GrowthStage(name: "Vegetative", emoji: "🌿", startDay: 16, endDay: 40),
    GrowthStage(name: "Flowering", emoji: "🌸", startDay: 41, endDay: 65),
    GrowthStage(name: "Fruiting & Harvest", emoji: "🫑", startDay: 66, endDay: 85),
  ],
  statusMessages: {
    "Seedling":
        "Seedling phase — capsicum germinates slowly, keep temperature above 20°C at all times",
    "Vegetative":
        "Plant establishing — ensure CO₂ above 800 ppm and maintain consistent watering",
    "Flowering":
        "Critical flowering stage — humidity above 70% causes fruit drop, monitor strictly",
    "Fruiting & Harvest":
        "Fruit developing — reduce watering slightly, harvest when capsicum turns full color",
  },
);

CropConfig get activeCropConfig =>
    AppData.cropType == "Spinach" ? spinachConfig : capsicumConfig;

// ─── Sensor Dummy Historical Data (24h, last-to-first) ───────────────────────
class SensorHistory {
  static final List<double> temperature = [
    23.1, 23.5, 24.0, 24.2, 24.5, 24.8, 25.1, 25.0, 24.9, 24.5,
    24.2, 23.8, 23.5, 23.2, 23.0, 23.3, 23.7, 24.0, 24.4, 24.5,
    24.6, 24.3, 24.1, 24.5,
  ];

  static final List<double> humidity = [
    60.0, 61.5, 63.0, 64.0, 65.0, 66.0, 67.0, 66.5, 65.8, 65.0,
    64.5, 63.8, 63.0, 62.5, 62.0, 62.3, 63.0, 64.0, 64.8, 65.0,
    65.2, 64.9, 64.5, 65.0,
  ];

  static final List<double> co2 = [
    910.0, 920.0, 930.0, 935.0, 940.0, 950.0, 960.0, 958.0, 955.0, 950.0,
    945.0, 940.0, 935.0, 930.0, 925.0, 928.0, 932.0, 938.0, 942.0, 950.0,
    952.0, 948.0, 945.0, 950.0,
  ];

  static final List<double> soilMoisture = [
    48.0, 47.5, 46.8, 46.0, 45.2, 44.5, 44.0, 43.5, 43.2, 43.0,
    42.8, 42.5, 42.2, 42.0, 42.3, 42.8, 43.0, 43.2, 43.5, 43.0,
    43.2, 43.1, 42.9, 43.0,
  ];
}

// ─── Sensor Status Helper ──────────────────────────────────────────────────
enum SensorStatus { good, warning, critical }

SensorStatus getSensorStatus(String sensor, double value) {
  final config = activeCropConfig;
  switch (sensor) {
    case 'temperature':
      if (value >= config.tempMin && value <= config.tempMax) return SensorStatus.good;
      if ((value >= config.tempMin - 3 && value < config.tempMin) ||
          (value > config.tempMax && value <= config.tempMax + 3)) {
        return SensorStatus.warning;
      }
      return SensorStatus.critical;
    case 'humidity':
      if (value >= config.humidityMin && value <= config.humidityMax) return SensorStatus.good;
      if ((value >= config.humidityMin - 5 && value < config.humidityMin) ||
          (value > config.humidityMax && value <= config.humidityMax + 5)) {
        return SensorStatus.warning;
      }
      return SensorStatus.critical;
    case 'co2':
      if (value >= config.co2Min && value <= config.co2Max) return SensorStatus.good;
      if ((value >= config.co2Min - 50 && value < config.co2Min) ||
          (value > config.co2Max && value <= config.co2Max + 100)) {
        return SensorStatus.warning;
      }
      return SensorStatus.critical;
    case 'soil':
      if (value >= config.soilMin && value <= config.soilMax) return SensorStatus.good;
      if ((value >= config.soilMin - 10 && value < config.soilMin) ||
          (value > config.soilMax && value <= config.soilMax + 5)) {
        return SensorStatus.warning;
      }
      return SensorStatus.critical;
    default:
      return SensorStatus.good;
  }
}

Color statusColor(SensorStatus s) {
  switch (s) {
    case SensorStatus.good: return AppColors.good;
    case SensorStatus.warning: return AppColors.warning;
    case SensorStatus.critical: return AppColors.critical;
  }
}

Color statusBgColor(SensorStatus s) {
  switch (s) {
    case SensorStatus.good: return AppColors.goodBg;
    case SensorStatus.warning: return AppColors.warningBg;
    case SensorStatus.critical: return AppColors.criticalBg;
  }
}

String statusLabel(SensorStatus s) {
  switch (s) {
    case SensorStatus.good: return "🟢 Good";
    case SensorStatus.warning: return "🟡 Warning";
    case SensorStatus.critical: return "🔴 Critical";
  }
}
