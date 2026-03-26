class FarmerProfile {
  final String email;
  final String name;
  final String phone;
  final String location;
  final int totalDaysMonitored;
  final int alertsResolved;
  final int totalCropSessions;
  final DateTime? lastLogin;

  const FarmerProfile({
    required this.email,
    required this.name,
    this.phone = '',
    this.location = '',
    this.totalDaysMonitored = 0,
    this.alertsResolved = 0,
    this.totalCropSessions = 0,
    this.lastLogin,
  });

  factory FarmerProfile.fromMap(Map<String, dynamic> map) {
    return FarmerProfile(
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? 'Farmer',
      phone: map['phone'] as String? ?? '',
      location: map['location'] as String? ?? '',
      totalDaysMonitored: (map['total_days_monitored'] as num?)?.toInt() ?? 0,
      alertsResolved: (map['alerts_resolved'] as num?)?.toInt() ?? 0,
      totalCropSessions: (map['total_crop_sessions'] as num?)?.toInt() ?? 0,
      lastLogin: map['last_login'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['last_login'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'location': location,
      'total_days_monitored': totalDaysMonitored,
      'alerts_resolved': alertsResolved,
      'total_crop_sessions': totalCropSessions,
      'last_login': lastLogin?.millisecondsSinceEpoch,
    };
  }

  FarmerProfile copyWith({
    String? name,
    String? phone,
    String? location,
    int? totalDaysMonitored,
    int? alertsResolved,
    int? totalCropSessions,
  }) {
    return FarmerProfile(
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      totalDaysMonitored: totalDaysMonitored ?? this.totalDaysMonitored,
      alertsResolved: alertsResolved ?? this.alertsResolved,
      totalCropSessions: totalCropSessions ?? this.totalCropSessions,
      lastLogin: lastLogin,
    );
  }
}
