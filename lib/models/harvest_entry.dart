import 'package:firebase_database/firebase_database.dart';

class HarvestEntry {
  final String id;
  final String date;
  final String cropType;
  final String harvestType;
  final String grade;
  final double quantityKg;
  final double pricePerKg;
  final double totalEarned;
  final String whereSold;
  final String notes;
  final int timestamp;

  HarvestEntry({
    required this.id,
    required this.date,
    required this.cropType,
    required this.harvestType,
    required this.grade,
    required this.quantityKg,
    required this.pricePerKg,
    required this.totalEarned,
    required this.whereSold,
    required this.notes,
    required this.timestamp,
  });

  /// Create a HarvestEntry from a Firebase RTDB DataSnapshot.
  factory HarvestEntry.fromSnapshot(DataSnapshot snapshot) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return HarvestEntry(
      id: snapshot.key!,
      date: data['date'] as String? ?? '',
      cropType: data['crop_type'] as String? ?? '',
      harvestType: data['harvest_type'] as String? ?? '',
      grade: data['grade'] as String? ?? '',
      quantityKg: (data['quantity_kg'] as num?)?.toDouble() ?? 0.0,
      pricePerKg: (data['price_per_kg'] as num?)?.toDouble() ?? 0.0,
      totalEarned: (data['total_earned'] as num?)?.toDouble() ?? 0.0,
      whereSold: data['where_sold'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      timestamp: (data['timestamp'] as num?)?.toInt() ?? 0,
    );
  }

  /// Convert to a Map for saving to Firebase RTDB.
  Map<String, dynamic> toMap() => {
        'date': date,
        'crop_type': cropType,
        'harvest_type': harvestType,
        'grade': grade,
        'quantity_kg': quantityKg,
        'price_per_kg': pricePerKg,
        'total_earned': totalEarned,
        'where_sold': whereSold,
        'notes': notes,
        'timestamp': timestamp,
      };

  /// Parsed DateTime from timestamp.
  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp);
}
