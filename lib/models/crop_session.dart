class CropSession {
  final String? id;
  final String farmerEmail;
  final String cropType;
  final String growthStage;
  final String soilType;
  final int daysPlanted;
  final DateTime startDate;
  final double targetYield;
  final bool isActive;

  const CropSession({
    this.id,
    required this.farmerEmail,
    required this.cropType,
    required this.growthStage,
    this.soilType = 'Loamy',
    required this.daysPlanted,
    required this.startDate,
    required this.targetYield,
    this.isActive = true,
  });

  factory CropSession.fromMap(Map<String, dynamic> map, {String? id}) {
    return CropSession(
      id: id,
      farmerEmail: map['farmer_email'] as String? ?? '',
      cropType: map['crop_type'] as String? ?? 'Capsicum',
      growthStage: map['growth_stage'] as String? ?? 'Seedling',
      soilType: map['soil_type'] as String? ?? 'Loamy',
      daysPlanted: (map['days_planted'] as num?)?.toInt() ?? 1,
      startDate: map['start_date'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int)
          : DateTime.now(),
      targetYield: (map['target_yield'] as num?)?.toDouble() ?? 3.0,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmer_email': farmerEmail,
      'crop_type': cropType,
      'growth_stage': growthStage,
      'soil_type': soilType,
      'days_planted': daysPlanted,
      'start_date': startDate.millisecondsSinceEpoch,
      'target_yield': targetYield,
      'is_active': isActive,
    };
  }

  CropSession copyWith({
    String? cropType,
    String? growthStage,
    String? soilType,
    int? daysPlanted,
    double? targetYield,
    bool? isActive,
  }) {
    return CropSession(
      id: id,
      farmerEmail: farmerEmail,
      cropType: cropType ?? this.cropType,
      growthStage: growthStage ?? this.growthStage,
      soilType: soilType ?? this.soilType,
      daysPlanted: daysPlanted ?? this.daysPlanted,
      startDate: startDate,
      targetYield: targetYield ?? this.targetYield,
      isActive: isActive ?? this.isActive,
    );
  }
}
