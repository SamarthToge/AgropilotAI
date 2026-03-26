import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/history_provider.dart';
import '../providers/sensor_provider.dart';
import '../providers/app_state.dart';

class AiAnalysisScreen extends StatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  bool _showingJson = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadAll();
    });
  }

  String _buildExportJson(
      AppState state, SensorProvider sensors, HistoryProvider history) {
    final avgs = history.weeklySensorAverages;
    final trend = history.weeklyYieldTrend;
    final alerts = history.alertLogs;
    final payload = {
      'export_date': DateTime.now().toIso8601String(),
      'crop_session': {
        'crop_type': state.cropType,
        'growth_stage': state.growthStage,
        'days_planted': state.daysPlanted,
        'target_yield_kg': state.targetYield,
        'predicted_yield_kg': state.predictedYield,
      },
      'current_sensors': {
        'temperature_c': sensors.temperature,
        'humidity_pct': sensors.humidity,
        'co2_ppm': sensors.co2,
        'soil_moisture_pct': sensors.soilMoisture,
        'data_source': sensors.dataSource,
      },
      'weekly_averages': {
        'temperature_c': (avgs['temperature'] ?? 0).toStringAsFixed(1),
        'humidity_pct': (avgs['humidity'] ?? 0).toStringAsFixed(1),
        'co2_ppm': (avgs['co2'] ?? 0).toStringAsFixed(0),
        'soil_moisture_pct': (avgs['soil'] ?? 0).toStringAsFixed(1),
      },
      'yield_trend_weekly_kg': trend.map((v) => v.toStringAsFixed(2)).toList(),
      'total_alerts_30d': alerts.length,
      'alert_breakdown': {
        'critical': alerts.where((a) => a.severity == 'Critical').length,
        'warning': alerts.where((a) => a.severity == 'Warning').length,
        'resolved': alerts.where((a) => a.resolved).length,
      },
      'sensor_readings_count': history.readings30d.length,
      'llm_training_note':
          'This JSON can be used to fine-tune or prompt an LLM for greenhouse yield prediction.',
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final sensors = context.watch<SensorProvider>();
    final history = context.watch<HistoryProvider>();
    final avgs = history.weeklySensorAverages;
    final trend = history.weeklyYieldTrend;
    final alerts = history.alertLogs;

    final trendChange = trend.length >= 2
        ? ((trend.last - trend.first) / trend.first * 100).toStringAsFixed(1)
        : '0.0';
    final trendUp = trend.length >= 2 && trend.last >= trend.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "🤖 AI Analysis",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: history.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Summary Banner ───────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Smart Insights",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${state.cropType} · ${state.growthStage} · Day ${state.daysPlanted}",
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _BannerStat(
                                label: "Data Points",
                                value: "${history.readings30d.length}"),
                            const SizedBox(width: 16),
                            _BannerStat(
                                label: "Total Alerts",
                                value: "${alerts.length}"),
                            const SizedBox(width: 16),
                            _BannerStat(
                                label: "Yield Trend",
                                value: "${trendUp ? '+' : ''}$trendChange%"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Key Insights ─────────────────────────────────────────
                  _sectionTitle("💡 Key Insights"),
                  const SizedBox(height: 10),
                  _InsightCard(
                    icon: "🌡",
                    color: AppColors.secondary,
                    title: "Temperature Stability",
                    body:
                        "Avg ${(avgs['temperature'] ?? 0).toStringAsFixed(1)}°C over 7 days — "
                        "${(avgs['temperature'] ?? 0) >= 20 && (avgs['temperature'] ?? 0) <= 27 ? 'within ideal range. Stable growing conditions.' : 'outside ideal 20–27°C. Adjust ventilation.'}",
                  ),
                  const SizedBox(height: 10),
                  _InsightCard(
                    icon: "🌱",
                    color: AppColors.critical,
                    title: "Soil Moisture Concern",
                    body:
                        "Avg ${(avgs['soil'] ?? 0).toStringAsFixed(1)}% — "
                        "${(avgs['soil'] ?? 0) < 60 ? 'Below ideal 60–75%. Consistent under-irrigation detected. Increase drip frequency.' : 'Soil moisture is within optimal range.'}",
                  ),
                  const SizedBox(height: 10),
                  _InsightCard(
                    icon: "💨",
                    color: AppColors.warning,
                    title: "CO₂ Trend",
                    body:
                        "Avg ${(avgs['co2'] ?? 0).toStringAsFixed(0)} ppm — "
                        "${(avgs['co2'] ?? 0) > 1000 ? 'Consistently high CO₂. Risk of crop stress — improve air exchange.' : 'CO₂ within acceptable range for current growth stage.'}",
                  ),
                  const SizedBox(height: 10),
                  _InsightCard(
                    icon: "📉",
                    color: trendUp ? AppColors.good : AppColors.critical,
                    title: "Yield Forecast",
                    body: trendUp
                        ? "Yield trend is improving (+$trendChange% over 4 weeks). Current conditions support target yield of ${state.targetYield} kg."
                        : "Yield trend is declining ($trendChange% over 4 weeks). Address soil moisture and CO₂ levels to recover yield.",
                  ),
                  const SizedBox(height: 20),

                  // ── LLM Training Export ──────────────────────────────────
                  _sectionTitle("🧠 LLM Training Data Export"),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3)),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.data_object,
                                color: AppColors.secondary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Export ${history.readings30d.length} readings as structured JSON for LLM training or analysis",
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final json = _buildExportJson(
                                      state, sensors, history);
                                  setState(() => _showingJson = !_showingJson);
                                  if (!_showingJson) return;
                                  Clipboard.setData(ClipboardData(text: json));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("JSON copied to clipboard!")),
                                  );
                                },
                                icon: Icon(
                                    _showingJson
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 16),
                                label: Text(
                                  _showingJson ? "Hide" : "Show & Copy JSON",
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.secondary,
                                  side: const BorderSide(
                                      color: AppColors.secondary, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_showingJson) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E2E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _buildExportJson(state, sensors, history),
                              style: GoogleFonts.sourceCodePro(
                                color: const Color(0xFF89DCEB),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Alert Stats ──────────────────────────────────────────
                  _sectionTitle("📊 Alert Statistics (30 Days)"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _StatBox(
                        label: "Total Alerts",
                        value: "${alerts.length}",
                        color: AppColors.secondary,
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _StatBox(
                        label: "Critical",
                        value:
                            "${alerts.where((a) => a.severity == 'Critical').length}",
                        color: AppColors.critical,
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _StatBox(
                        label: "Resolved",
                        value: "${alerts.where((a) => a.resolved).length}",
                        color: AppColors.good,
                      )),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      );
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  const _BannerStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.white60)),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String icon;
  final Color color;
  final String title;
  final String body;
  const _InsightCard(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
