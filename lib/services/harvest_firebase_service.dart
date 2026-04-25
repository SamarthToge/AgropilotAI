import 'package:firebase_database/firebase_database.dart';
import '../models/harvest_entry.dart';

/// Firebase RTDB service for Harvest Log CRUD operations.
/// Data path: greenhouse/harvest_log/{auto_id}
class HarvestFirebaseService {
  HarvestFirebaseService._();
  static final HarvestFirebaseService instance = HarvestFirebaseService._();

  final DatabaseReference _ref =
      FirebaseDatabase.instance.ref('greenhouse/harvest_log');

  // ── Create ────────────────────────────────────────────────────────────────

  /// Push a new harvest entry and return the generated ID.
  Future<String> addEntry(HarvestEntry entry) async {
    final newRef = _ref.push();
    await newRef.set(entry.toMap());
    return newRef.key!;
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Fetch all harvest entries sorted by timestamp (most-recent first).
  /// Sorting is done client-side to avoid needing a Firebase index rule.
  Future<List<HarvestEntry>> getAllEntries() async {
    // 15-second timeout — shows error instead of spinning forever
    final snapshot = await _ref
        .get()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception(
            'Connection timed out. Check your internet and Firebase Database Rules.',
          ),
        );

    if (!snapshot.exists || snapshot.value == null) return [];

    final entries = <HarvestEntry>[];
    final map = Map<String, dynamic>.from(snapshot.value as Map);

    for (final key in map.keys) {
      try {
        final childSnap = snapshot.child(key);
        entries.add(HarvestEntry.fromSnapshot(childSnap));
      } catch (_) {
        // Skip malformed entries
      }
    }

    // Sort most-recent first (client-side — no Firebase index needed)
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  /// Stream of harvest_log node — use for real-time updates if needed.
  Stream<List<HarvestEntry>> streamEntries() {
    return _ref.onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final entries = <HarvestEntry>[];
      final map =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      for (final key in map.keys) {
        try {
          entries.add(HarvestEntry.fromSnapshot(event.snapshot.child(key)));
        } catch (_) {}
      }
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    });
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  /// Permanently delete a harvest entry by its ID.
  Future<void> deleteEntry(String entryId) async {
    await _ref.child(entryId).remove();
  }
}
