import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final yieldTrend = history.weeklyYieldTrend;
    final averages = history.weeklySensorAverages;
    final alertsByDay = history.alertsByDay;

    final yieldSpots = yieldTrend
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "History & Reports",
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
                  // ── Yield Trend Chart ────────────────────────────────────
                  _sectionTitle("📈 Yield Trend — Last 4 Weeks"),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
                    child: SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          minY: 1.5,
                          maxY: 3.5,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (v) =>
                                FlLine(color: AppColors.divider, strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (v, m) => Text(
                                  v.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: AppColors.textSecondary),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                getTitlesWidget: (v, m) {
                                  final labels = ["Wk 1", "Wk 2", "Wk 3", "Wk 4"];
                                  final i = v.toInt();
                                  if (i < 0 || i >= labels.length) return const SizedBox();
                                  return Text(labels[i],
                                      style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: AppColors.textSecondary));
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: yieldSpots,
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) =>
                                    FlDotCirclePainter(
                                        radius: 4,
                                        color: AppColors.primary,
                                        strokeColor: Colors.white,
                                        strokeWidth: 2),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Weekly Sensor Averages ─────────────────────────────────
                  _sectionTitle("📋 Weekly Sensor Averages"),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        _SensorAvgRow(
                          icon: "🌡",
                          label: "Temperature",
                          value:
                              "${(averages['temperature'] ?? 24.2).toStringAsFixed(1)} °C",
                          status: getSensorStatus(
                              'temperature', averages['temperature'] ?? 24.2),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _SensorAvgRow(
                          icon: "💧",
                          label: "Humidity",
                          value:
                              "${(averages['humidity'] ?? 64.3).toStringAsFixed(1)} %",
                          status: getSensorStatus(
                              'humidity', averages['humidity'] ?? 64.3),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _SensorAvgRow(
                          icon: "💨",
                          label: "CO₂",
                          value:
                              "${(averages['co2'] ?? 941).toStringAsFixed(0)} ppm",
                          status:
                              getSensorStatus('co2', averages['co2'] ?? 941),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _SensorAvgRow(
                          icon: "🌱",
                          label: "Soil Moisture",
                          value:
                              "${(averages['soil'] ?? 44.2).toStringAsFixed(1)} %",
                          status:
                              getSensorStatus('soil', averages['soil'] ?? 44.2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Past Alerts Log ────────────────────────────────────────
                  _sectionTitle("🔔 Past Alerts Log"),
                  const SizedBox(height: 10),
                  if (alertsByDay.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'No alerts in the past 30 days 🎉',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          for (final entry in alertsByDay.entries) ...[
                            _AlertLogRow(
                              day: entry.key,
                              count: entry.value.length,
                              note: entry.value.map((a) => a.title).join(' · '),
                            ),
                            if (entry.key != alertsByDay.keys.last)
                              const Divider(height: 1, indent: 16, endIndent: 16),
                          ]
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // ── Export Button ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Export feature coming soon!")),
                        );
                      },
                      icon: const Icon(Icons.download_outlined),
                      label: Text(
                        "Export Report (PDF)",
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: const BorderSide(
                            color: AppColors.secondary, width: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
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

class _SensorAvgRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final SensorStatus status;

  const _SensorAvgRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusBgColor(status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status == SensorStatus.good ? "🟢" : status == SensorStatus.warning ? "🟡" : "🔴",
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertLogRow extends StatelessWidget {
  final String day;
  final int count;
  final String note;

  const _AlertLogRow({
    required this.day,
    required this.count,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final noAlert = count == 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: noAlert ? AppColors.goodBg : AppColors.warningBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                noAlert ? "✅" : "$count",
                style: TextStyle(
                  fontSize: noAlert ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: noAlert ? null : AppColors.warning,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                Text(
                  note,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            noAlert ? "No Alerts" : "$count Alert${count > 1 ? 's' : ''}",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: noAlert ? AppColors.good : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
