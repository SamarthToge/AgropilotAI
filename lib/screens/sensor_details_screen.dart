import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:agropilot_ai/gen_l10n/app_localizations.dart';
import '../constants/app_constants.dart';
import '../providers/sensor_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/status_badge.dart';

class SensorDetailsScreen extends StatefulWidget {
  const SensorDetailsScreen({super.key});

  @override
  State<SensorDetailsScreen> createState() => _SensorDetailsScreenState();
}

class _SensorDetailsScreenState extends State<SensorDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.sensorDetails,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle:
              GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: "🌡 ${l10n.temperature.split(' ').first}"),
            Tab(text: "💧 ${l10n.humidity.split(' ').first}"),
            Tab(text: "💨 CO₂"),
            Tab(text: "🌱 ${l10n.soilMoisture.split(' ').first}"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _SensorTab(
            sensorKey: 'temperature',
            title: l10n.temperature,
            icon: "🌡",
            unit: "°C",
            idealText: "Ideal: 20°C – 27°C",
            idealMin: 20,
            idealMax: 27,
          ),
          _SensorTab(
            sensorKey: 'humidity',
            title: l10n.humidity,
            icon: "💧",
            unit: "%",
            idealText: "Ideal: 50% – 70%",
            idealMin: 50,
            idealMax: 70,
          ),
          _SensorTab(
            sensorKey: 'co2',
            title: l10n.co2,
            icon: "💨",
            unit: "ppm",
            idealText: "Ideal: 800–1000 ppm",
            idealMin: 800,
            idealMax: 1000,
          ),
          _SensorTab(
            sensorKey: 'soil',
            title: l10n.soilMoisture,
            icon: "🌱",
            unit: "%",
            idealText: "Ideal: 60% – 75%",
            idealMin: 60,
            idealMax: 75,
          ),
        ],
      ),
    );
  }
}

class _SensorTab extends StatelessWidget {
  final String sensorKey;
  final String title;
  final String icon;
  final String unit;
  final String idealText;
  final double idealMin;
  final double idealMax;

  const _SensorTab({
    required this.sensorKey,
    required this.title,
    required this.icon,
    required this.unit,
    required this.idealText,
    required this.idealMin,
    required this.idealMax,
  });

  List<double> _getData(BuildContext context) {
    final history = context.read<HistoryProvider>();
    return history.getSensorHistory(sensorKey);
  }

  double _getCurrentValue(BuildContext context) {
    final sensors = context.read<SensorProvider>();
    switch (sensorKey) {
      case 'temperature': return sensors.temperature;
      case 'humidity': return sensors.humidity;
      case 'co2': return sensors.co2;
      default: return sensors.soilMoisture;
    }
  }

  SensorStatus _getStatus(BuildContext context) {
    final sensors = context.read<SensorProvider>();
    switch (sensorKey) {
      case 'temperature': return sensors.tempStatus;
      case 'humidity': return sensors.humidityStatus;
      case 'co2': return sensors.co2Status;
      default: return sensors.soilStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _getData(context);
    final current = _getCurrentValue(context);
    final status = _getStatus(context);

    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final avg = data.reduce((a, b) => a + b) / data.length;

    // chart y-axis bounds
    final chartMin = (idealMin - (idealMax - idealMin) * 0.3).floorToDouble();
    final chartMax = (idealMax + (idealMax - idealMin) * 0.3).ceilToDouble();

    final spots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final midIdeal = (idealMin + idealMax) / 2;
    final idealSpots = [
      FlSpot(0, midIdeal),
      FlSpot(23, midIdeal),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current value card
          Container(
            width: double.infinity,
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(icon, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                Text(
                  "${current.toStringAsFixed(sensorKey == 'co2' ? 0 : 1)} $unit",
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                StatusBadge(status: status),
                const SizedBox(height: 6),
                Text(
                  idealText,
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Chart card
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    AppLocalizations.of(context)!.last24Hours,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: [
                      Container(
                          width: 16,
                          height: 2,
                          color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(AppLocalizations.of(context)!.actual,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(width: 12),
                      Container(
                          width: 16,
                          height: 2,
                          decoration: const BoxDecoration(
                              color: AppColors.warning)),
                      const SizedBox(width: 4),
                      Text(AppLocalizations.of(context)!.idealRangeMid,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minY: chartMin,
                      maxY: chartMax,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: AppColors.divider,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (val, meta) => Text(
                              val.toStringAsFixed(0),
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
                            interval: 6,
                            getTitlesWidget: (val, meta) {
                              final hour = val.toInt();
                              return Text(
                                "${hour}h",
                                style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    color: AppColors.textSecondary),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        // Actual data line
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppColors.secondary,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.secondary.withValues(alpha: 0.08),
                          ),
                        ),
                        // Ideal reference line (dotted)
                        LineChartBarData(
                          spots: idealSpots,
                          isCurved: false,
                          color: AppColors.warning,
                          barWidth: 1.5,
                          dashArray: [6, 4],
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Expanded(
                  child: _StatCard(label: AppLocalizations.of(context)!.minimum,
                      value: "${min.toStringAsFixed(1)} $unit",
                      color: AppColors.secondary)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(label: AppLocalizations.of(context)!.maximum,
                      value: "${max.toStringAsFixed(1)} $unit",
                      color: AppColors.critical)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(label: AppLocalizations.of(context)!.average,
                      value: "${avg.toStringAsFixed(1)} $unit",
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 10, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
