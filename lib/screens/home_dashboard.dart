import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agropilot_ai/gen_l10n/app_localizations.dart';
import '../constants/app_constants.dart';
import '../providers/app_state.dart';
import '../providers/sensor_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/crop_info_card.dart';
import '../widgets/yield_summary_card.dart';
import '../widgets/sensor_card.dart';
import '../widgets/alert_card.dart';
import '../widgets/side_drawer.dart';
import 'sensor_details_screen.dart';
import 'yield_prediction_screen.dart';
import 'history_screen.dart';
import 'harvest_log/harvest_entries_screen.dart';
import 'chatbot_screen.dart';


class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _notifCount = 2;

  @override
  void initState() {
    super.initState();
    // Update notif count from active alerts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hist = context.read<HistoryProvider>();
      setState(() => _notifCount = hist.activeAlerts.length);

      // Setup sensor listener for prediction
      final sensors = context.read<SensorProvider>();
      final appState = context.read<AppState>();
      
      sensors.addListener(() {
        if (sensors.lastReading != null) {
          appState.updateYieldPrediction(sensors.lastReading!);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final sensors = context.watch<SensorProvider>();
    final history = context.watch<HistoryProvider>();
    final activeAlerts = history.activeAlerts;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: SideDrawer(
        onLogout: () async {
          await context.read<AppState>().logout();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        ),
        icon: const Text('🤖', style: TextStyle(fontSize: 20)),
        label: Text(
          'Ask AI',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 4,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          l10n.appName,
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          // Live / Simulated badge
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sensors.dataSource == 'esp32'
                      ? AppColors.goodBg
                      : AppColors.warningBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  sensors.dataSource == 'esp32' ? '🔴 Live' : '🟡 Demo',
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600,
                    color: sensors.dataSource == 'esp32' ? AppColors.good : AppColors.warning),
                ),
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.textPrimary),
                onPressed: () {
                  setState(() => _notifCount = 0);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${activeAlerts.length} active alert${activeAlerts.length != 1 ? 's' : ''} — check below")),
                  );
                },
              ),
              if (_notifCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.critical,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "$_notifCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome greeting ──────────────────────────────────────
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeBack,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      state.farmerName,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goodBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.good.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    "🌻 ${state.cropType}",
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Crop Info Card ─────────────────────────────────────────
            const CropInfoCard(),
            const SizedBox(height: 16),

            // ── Yield Forecast ─────────────────────────────────────────
            YieldSummaryCard(
              onViewFull: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const YieldPredictionScreen()),
              ),
            ),
            const SizedBox(height: 16),

            // ── Live Sensors ───────────────────────────────────────────
            _SectionHeader(
              title: l10n.liveSensors,
              action: l10n.viewAll,
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SensorDetailsScreen()),
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                SensorCard(
                  icon: "🌡",
                  label: l10n.temperature,
                  value: sensors.temperature.toStringAsFixed(1),
                  unit: "°C",
                  status: sensors.tempStatus,
                ),
                SensorCard(
                  icon: "💧",
                  label: l10n.humidity,
                  value: sensors.humidity.toStringAsFixed(1),
                  unit: "%",
                  status: sensors.humidityStatus,
                ),
                SensorCard(
                  icon: "💨",
                  label: l10n.co2,
                  value: sensors.co2.toStringAsFixed(0),
                  unit: "ppm",
                  status: sensors.co2Status,
                ),
                SensorCard(
                  icon: "🌱",
                  label: l10n.soilMoisture,
                  value: sensors.soilMoisture.toStringAsFixed(1),
                  unit: "%",
                  status: sensors.soilStatus,
                ),
              ],
            ),
            if (sensors.lastUpdated != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Last updated: ${_formatTime(sensors.lastUpdated!)}',
                  style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                  textAlign: TextAlign.right,
                ),
              ),
            const SizedBox(height: 16),

            // ── Alerts ─────────────────────────────────────────────────
            _AlertsSection(alerts: history.activeAlerts),
            const SizedBox(height: 16),

            // ── History Button ─────────────────────────────────────────
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text("📋", style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(
                      l10n.viewHistoryReports,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppColors.secondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Harvest Log Button ──────────────────────────────────────────
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const HarvestEntriesScreen()),
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text("📦", style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(
                      l10n.harvestLog,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Alerts Section ───────────────────────────────────────────────────────────
class _AlertsSection extends StatelessWidget {
  final List<dynamic> alerts;
  const _AlertsSection({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (alerts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: "✅ ${l10n.alertsAndActions}"),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.goodBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.good.withValues(alpha: 0.3)),
            ),
            child: Text(
              l10n.allSensorsGood,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.good, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: "⚠️ ${l10n.alertsAndActions}"),
        const SizedBox(height: 10),
        ...alerts.map((a) => AlertCard(
              severity: a.severity,
              title: a.title,
              currentValue: a.currentValue,
              idealValue: a.idealValue,
              action: a.message,
            )),
      ],
    );
  }
}
