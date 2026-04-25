import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:agropilot_ai/gen_l10n/app_localizations.dart';
import '../../constants/app_constants.dart';
import '../../models/harvest_entry.dart';
import '../../services/harvest_firebase_service.dart';
import '../../services/firebase_service.dart';

class HarvestChartsScreen extends StatefulWidget {
  const HarvestChartsScreen({super.key});

  @override
  State<HarvestChartsScreen> createState() => _HarvestChartsScreenState();
}

class _HarvestChartsScreenState extends State<HarvestChartsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<HarvestEntry>> _future;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _future = HarvestFirebaseService.instance.getAllEntries();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.earningsChart,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<HarvestEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: GoogleFonts.poppins(color: AppColors.critical)));
          }

          final entries = snapshot.data ?? [];

          if (entries.isEmpty) {
            return _EmptyCharts();
          }

          // Sort chronologically for charts
          final sorted = [...entries]
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

          // Summary stats
          final totalEarned =
              entries.fold<double>(0, (s, e) => s + e.totalEarned);
          final totalKg =
              entries.fold<double>(0, (s, e) => s + e.quantityKg);
          final avgPrice = totalKg > 0 ? totalEarned / totalKg : 0.0;

          // Grade distribution
          final gradeMap = <String, int>{};
          for (final e in entries) {
            gradeMap[e.grade] = (gradeMap[e.grade] ?? 0) + 1;
          }

          final formatted = NumberFormat('#,##,###.##', 'en_IN');

          return FadeTransition(
            opacity: _fadeAnim,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Summary Cards ─────────────────────────────────────
                _SummaryRow(
                  totalEarned: totalEarned,
                  totalKg: totalKg,
                  avgPrice: avgPrice,
                  formatter: formatted,
                  l10n: l10n,
                ),
                const SizedBox(height: 20),

                // ── Predicted vs Actual ───────────────────────────────
                _PredictedVsActualCard(totalKg: totalKg),
                const SizedBox(height: 20),

                // ── Bar Chart: Earnings per harvest ───────────────────
                _ChartCard(
                  title: '📊 ${l10n.earningsChart}',
                  subtitle: l10n.earningsChartSubtitle,
                  child: _EarningsBarChart(entries: sorted),
                ),
                const SizedBox(height: 16),

                // ── Line Chart: Quantity over time ────────────────────
                _ChartCard(
                  title: '📈 ${l10n.quantityChart}',
                  subtitle: l10n.quantityChartSubtitle,
                  child: _QuantityLineChart(entries: sorted),
                ),
                const SizedBox(height: 16),

                // ── Pie Chart: Grade distribution ─────────────────────
                _ChartCard(
                  title: '🍩 ${l10n.gradeChart}',
                  subtitle: l10n.gradeChartSubtitle,
                  child: _GradePieChart(gradeMap: gradeMap),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Empty Charts State ─────────────────────────────────────────────────────
class _EmptyCharts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📊', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              l10n.noRecords,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addEntriesToSeeCharts,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final double totalEarned, totalKg, avgPrice;
  final NumberFormat formatter;
  final AppLocalizations l10n;

  const _SummaryRow({
    required this.totalEarned,
    required this.totalKg,
    required this.avgPrice,
    required this.formatter,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: '💰',
            title: l10n.totalEarned,
            value: '₹${formatter.format(totalEarned)}',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: '⚖️',
            title: l10n.totalHarvested,
            value: '${formatter.format(totalKg)} kg',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: '🏷️',
            title: l10n.avgPrice,
            value: '₹${formatter.format(avgPrice)}/kg',
            color: const Color(0xFFE65100),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String icon, title, value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Predicted vs Actual Card ───────────────────────────────────────────────
class _PredictedVsActualCard extends StatefulWidget {
  final double totalKg;
  const _PredictedVsActualCard({required this.totalKg});

  @override
  State<_PredictedVsActualCard> createState() =>
      _PredictedVsActualCardState();
}

class _PredictedVsActualCardState extends State<_PredictedVsActualCard> {
  double? _predicted;
  bool _loading = true;
  // Farm area in m² — could be made configurable
  static const double _farmSizeM2 = 100;

  @override
  void initState() {
    super.initState();
    _fetchPredicted();
  }

  Future<void> _fetchPredicted() async {
    try {
      final snap = await FirebaseService.instance
          .rdbRef('greenhouse/prediction/predicted_yield')
          .get();
      if (snap.exists && snap.value != null) {
        setState(() {
          _predicted = (snap.value as num).toDouble();
          _loading = false;
        });
        return;
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_predicted == null) return const SizedBox.shrink();

    final actualPerM2 = widget.totalKg / _farmSizeM2;
    final accuracyPct = _predicted! > 0
        ? ((1 - ((_predicted! - actualPerM2).abs() / _predicted!)) * 100)
            .clamp(0, 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.secondary.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🤖 ${l10n.aiAccuracy}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AccuracyItem(l10n.predicted,
                      '${_predicted!.toStringAsFixed(2)} kg/m²', AppColors.secondary),
                  _AccuracyItem(l10n.actual,
                      '${actualPerM2.toStringAsFixed(2)} kg/m²', AppColors.primary),
                  _AccuracyItem(
                      l10n.accuracy, '${accuracyPct.toStringAsFixed(1)}%', AppColors.good),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccuracyItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _AccuracyItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Chart Card Wrapper ─────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Bar Chart: Earnings ────────────────────────────────────────────────────
class _EarningsBarChart extends StatelessWidget {
  final List<HarvestEntry> entries;
  const _EarningsBarChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final maxY = entries.map((e) => e.totalEarned).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final e = entries[groupIndex];
                return BarTooltipItem(
                  '₹${e.totalEarned.toStringAsFixed(0)}\n${_shortDate(e.date)}',
                  GoogleFonts.poppins(
                      color: Colors.white, fontSize: 11),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _shortDate(entries[idx].date),
                      style: GoogleFonts.poppins(fontSize: 9),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (val, meta) => Text(
                  '₹${(val / 1000).toStringAsFixed(1)}k',
                  style: GoogleFonts.poppins(
                      fontSize: 9, color: AppColors.textSecondary),
                ),
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.divider,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.totalEarned,
                  color: AppColors.primary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY * 1.2,
                    color: AppColors.goodBg,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _shortDate(String raw) {
    try {
      final dt = DateFormat('yyyy-MM-dd').parse(raw);
      return DateFormat('d/M').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

// ── Line Chart: Quantity ───────────────────────────────────────────────────
class _QuantityLineChart extends StatelessWidget {
  final List<HarvestEntry> entries;
  const _QuantityLineChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.quantityKg);
    }).toList();

    final maxY =
        entries.map((e) => e.quantityKg).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY * 1.3,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '${entries[s.x.toInt()].quantityKg} kg\n${_shortDate(entries[s.x.toInt()].date)}',
                        GoogleFonts.poppins(
                            color: Colors.white, fontSize: 11),
                      ))
                  .toList(),
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _shortDate(entries[idx].date),
                      style: GoogleFonts.poppins(fontSize: 9),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (val, meta) => Text(
                  '${val.toInt()} kg',
                  style: GoogleFonts.poppins(
                      fontSize: 9, color: AppColors.textSecondary),
                ),
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.divider,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.secondary,
              barWidth: 2.5,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.secondary.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortDate(String raw) {
    try {
      final dt = DateFormat('yyyy-MM-dd').parse(raw);
      return DateFormat('d/M').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

// ── Pie Chart: Grade Distribution ─────────────────────────────────────────
class _GradePieChart extends StatefulWidget {
  final Map<String, int> gradeMap;
  const _GradePieChart({required this.gradeMap});

  @override
  State<_GradePieChart> createState() => _GradePieChartState();
}

class _GradePieChartState extends State<_GradePieChart> {
  int _touchedIndex = -1;

  static const _gradeColors = {
    'A+ Grade': AppColors.good,
    'A Grade': AppColors.primaryLight,
    'B Grade': AppColors.warning,
    'C Grade': AppColors.critical,
  };

  @override
  Widget build(BuildContext context) {
    if (widget.gradeMap.isEmpty) return const SizedBox.shrink();

    final total = widget.gradeMap.values
        .fold<int>(0, (sum, v) => sum + v)
        .toDouble();

    final sections = widget.gradeMap.entries.toList().asMap().entries.map((e) {
      final idx = e.key;
      final entry = e.value;
      final isTouched = idx == _touchedIndex;
      final pct = (entry.value / total) * 100;
      final color = _gradeColors[entry.key] ?? AppColors.textSecondary;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${pct.toStringAsFixed(1)}%',
        color: color,
        radius: isTouched ? 70 : 60,
        titleStyle: GoogleFonts.poppins(
          fontSize: isTouched ? 13 : 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 3,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: widget.gradeMap.entries.map((e) {
            final color = _gradeColors[e.key] ?? AppColors.textSecondary;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${e.key} (${e.value})',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
