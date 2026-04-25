import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_reading.dart';
import '../models/crop_session.dart';
import '../models/alert_log.dart';
import '../models/farmer_profile.dart';

/// Central Firebase service — handles Firestore, Realtime Database, and Authentication.
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final _db = FirebaseFirestore.instance;
  final _rtdb = FirebaseDatabase.instance;
  final _auth = FirebaseAuth.instance;

  // ─── Firebase Authentication ─────────────────────────────────────────────

  /// Stream of user auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user.
  User? get currentUser => _auth.currentUser;

  /// Sign up a new farmer.
  Future<UserCredential?> signUpFarmer({
    required String email,
    required String password,
    required String name,
    String phone = '',
    String location = '',
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (cred.user != null) {
      // Create initial profile in Firestore
      final profile = FarmerProfile(
        email: email,
        name: name,
        phone: phone,
        location: location,
        totalCropSessions: 1, // First session starts now
      );
      await saveFarmerProfile(profile);

      // Create a default active crop session
      final session = CropSession(
        farmerEmail: email,
        cropType: 'Capsicum',
        growthStage: 'Seedling',
        daysPlanted: 1,
        startDate: DateTime.now(),
        targetYield: 3.5,
        isActive: true,
      );
      await saveCropSession(session);
    }
    return cred;
  }

  /// Sign in an existing farmer.
  Future<UserCredential> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Update last login in Firestore (use set+merge so it works even if doc is missing)
    await _db.collection('farmers').doc(email).set({
      'last_login': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
    return cred;
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─── Generic RTDB access ─────────────────────────────────────────────────

  /// Returns a [DatabaseReference] for any RTDB path.
  /// Use this when you need direct read access to an arbitrary node.
  DatabaseReference rdbRef(String path) => _rtdb.ref(path);

  // ─── Realtime Database (ESP32 Live Data) ─────────────────────────────────

  /// Stream of live sensor readings from RTDB.
  /// ESP32 writes to: /greenhouse/sensors/live
  Stream<SensorReading?> streamLiveSensors() {
    final ref = _rtdb.ref('greenhouse/sensors/live');
    return ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return null;
      try {
        final map = Map<String, dynamic>.from(data as Map);
        return SensorReading.fromMap(map);
      } catch (_) {
        return null;
      }
    });
  }

  /// Write a live sensor reading to RTDB (used by DummyDataSeeder / testing).
  /// In production this is written by the ESP32.
  Future<void> writeLiveSensorToRTDB(SensorReading reading) async {
    final ref = _rtdb.ref('greenhouse/sensors/live');
    await ref.set(reading.toLiveMap());
  }

  // ─── Firestore: Sensor Readings ───────────────────────────────────────────

  /// Save a sensor reading to Firestore (called after every RTDB update).
  Future<void> saveSensorReading(SensorReading reading) async {
    await _db.collection('sensor_readings').add(reading.toMap());
  }

  /// Batch-save many sensor readings (used by seeder).
  Future<void> batchSaveSensorReadings(List<SensorReading> readings) async {
    const batchSize = 400;
    for (int i = 0; i < readings.length; i += batchSize) {
      final batch = _db.batch();
      final chunk = readings.sublist(
          i, i + batchSize > readings.length ? readings.length : i + batchSize);
      for (final r in chunk) {
        batch.set(_db.collection('sensor_readings').doc(), r.toMap());
      }
      await batch.commit();
    }
  }

  /// Fetch last [limit] sensor readings, ordered by timestamp descending.
  Future<List<SensorReading>> getRecentReadings({int limit = 50}) async {
    final snap = await _db
        .collection('sensor_readings')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => SensorReading.fromMap(d.data(), id: d.id))
        .toList();
  }

  /// Fetch readings from the last [hours] hours for charting.
  Future<List<SensorReading>> getReadingsForPastHours(int hours) async {
    final since = DateTime.now().subtract(Duration(hours: hours));
    final snap = await _db
        .collection('sensor_readings')
        .where('timestamp',
            isGreaterThanOrEqualTo: since.millisecondsSinceEpoch)
        .orderBy('timestamp', descending: false)
        .get();
    return snap.docs
        .map((d) => SensorReading.fromMap(d.data(), id: d.id))
        .toList();
  }

  /// Fetch readings for the past [days] days grouped for weekly analysis.
  Future<List<SensorReading>> getReadingsForPastDays(int days) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final snap = await _db
        .collection('sensor_readings')
        .where('timestamp',
            isGreaterThanOrEqualTo: since.millisecondsSinceEpoch)
        .orderBy('timestamp', descending: false)
        .get();
    return snap.docs
        .map((d) => SensorReading.fromMap(d.data(), id: d.id))
        .toList();
  }

  // ─── Firestore: Alert Logs ────────────────────────────────────────────────

  /// Save a new alert log.
  Future<void> saveAlertLog(AlertLog alert) async {
    await _db.collection('alert_logs').add(alert.toMap());
  }

  /// Batch-save alert logs (used by seeder).
  Future<void> batchSaveAlertLogs(List<AlertLog> alerts) async {
    final batch = _db.batch();
    for (final a in alerts) {
      batch.set(_db.collection('alert_logs').doc(), a.toMap());
    }
    await batch.commit();
  }

  /// Fetch alert logs for the past [days] days, most recent first.
  Future<List<AlertLog>> getAlertLogs({int days = 7}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final snap = await _db
        .collection('alert_logs')
        .where('timestamp',
            isGreaterThanOrEqualTo: since.millisecondsSinceEpoch)
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs
        .map((d) => AlertLog.fromMap(d.data(), id: d.id))
        .toList();
  }

  // ─── Firestore: Crop Session ──────────────────────────────────────────────

  /// Fetch the active crop session for a farmer.
  Future<CropSession?> getActiveCropSession(String farmerEmail) async {
    final snap = await _db
        .collection('crop_sessions')
        .where('farmer_email', isEqualTo: farmerEmail)
        .where('is_active', isEqualTo: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return CropSession.fromMap(snap.docs.first.data(), id: snap.docs.first.id);
  }

  /// Save or update a crop session.
  Future<void> saveCropSession(CropSession session) async {
    if (session.id != null) {
      await _db
          .collection('crop_sessions')
          .doc(session.id)
          .set(session.toMap(), SetOptions(merge: true));
    } else {
      await _db.collection('crop_sessions').add(session.toMap());
    }
  }

  // ─── Firestore: Farmer Profile ────────────────────────────────────────────

  /// Fetch farmer profile by email.
  Future<FarmerProfile?> getFarmerProfile(String email) async {
    final doc = await _db.collection('farmers').doc(email).get();
    if (!doc.exists || doc.data() == null) return null;
    return FarmerProfile.fromMap(doc.data()!);
  }

  /// Save or update farmer profile.
  Future<void> saveFarmerProfile(FarmerProfile profile) async {
    await _db
        .collection('farmers')
        .doc(profile.email)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  /// Increment totalDaysMonitored for a farmer.
  Future<void> incrementDaysMonitored(String email) async {
    await _db.collection('farmers').doc(email).update({
      'total_days_monitored': FieldValue.increment(1),
    });
  }

  /// Increment alertsResolved for a farmer.
  Future<void> incrementAlertsResolved(String email) async {
    await _db.collection('farmers').doc(email).update({
      'alerts_resolved': FieldValue.increment(1),
    });
  }
}
