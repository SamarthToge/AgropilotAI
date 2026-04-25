import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agropilot_ai/gen_l10n/app_localizations.dart';
import '../constants/app_constants.dart';
import '../providers/app_state.dart';
import '../widgets/status_badge.dart';

class YieldPredictionScreen extends StatelessWidget {
  const YieldPredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.yieldPrediction,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main yield card ───────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.secondary, AppColors.secondaryLight],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Text(
                    "🌾 ${l10n.predictedYield}",
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${state.predictedYield.toStringAsFixed(1)} kg/m²",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AlertLevelBadge(level: state.alertLevel),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _YieldMetric(
                          label: l10n.target,
                          value: "${state.targetYield.toStringAsFixed(1)} kg/m²"),
                      _Divider(),
                      _YieldMetric(
                          label: l10n.gap,
                          value: "-${state.yieldGap.toStringAsFixed(1)} kg/m²"),
                      _Divider(),
                      _YieldMetric(
                          label: l10n.daysLeft,
                          value: "${state.remainingDays} days"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── SHAP Feature Importance ───────────────────────────────
            _sectionTitle(l10n.featureImportance),
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
              padding: const EdgeInsets.all(18),
              child: Column(
                children: const [
                  _ShapBar(
                      label: "Soil Moisture",
                      percent: 34,
                      impact: "positive",
                      icon: "🌱"),
                  SizedBox(height: 12),
                  _ShapBar(
                      label: "Growth Stage",
                      percent: 18,
                      impact: "neutral",
                      icon: "📅"),
                  SizedBox(height: 12),
                  _ShapBar(
                      label: "Temperature",
                      percent: 28,
                      impact: "positive",
                      icon: "🌡"),
                  SizedBox(height: 12),
                  _ShapBar(
                      label: "CO₂",
                      percent: 12,
                      impact: "negative",
                      icon: "💨"),
                  SizedBox(height: 12),
                  _ShapBar(
                      label: "Humidity",
                      percent: 8,
                      impact: "negative",
                      icon: "💧"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Week on week ──────────────────────────────────────────
            _sectionTitle(l10n.weekComparison),
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
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _WeekRow(
                      label: l10n.thisWeek,
                      value: "2.1 kg",
                      badge: "🟡",
                      color: AppColors.warning),
                  const Divider(height: 20),
                  _WeekRow(
                      label: l10n.lastWeek,
                      value: "2.4 kg",
                      badge: "🟢",
                      color: AppColors.good),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.trend,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.criticalBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "📉  −0.3 kg",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.critical,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Model label ───────────────────────────────────────────
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.memory, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text(
                      "Powered by XGBoost ML Model",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

  Widget _sectionTitle(String t) => Text(
        t,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      );
}

class _YieldMetric extends StatelessWidget {
  final String label;
  final String value;
  const _YieldMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(label,
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: Colors.white24);
  }
}

class _ShapBar extends StatelessWidget {
  final String label;
  final int percent;
  final String impact; // "positive", "negative", "neutral"
  final String icon;

  const _ShapBar({
    required this.label,
    required this.percent,
    required this.impact,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String impactLabel;
    switch (impact) {
      case "positive":
        color = AppColors.good;
        impactLabel = "▲ Positive";
        break;
      case "negative":
        color = AppColors.critical;
        impactLabel = "▼ Negative";
        break;
      default:
        color = AppColors.secondary;
        impactLabel = "— Neutral";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
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
              "$percent%",
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                impactLabel,
                style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  final String label;
  final String value;
  final String badge;
  final Color color;
  const _WeekRow({
    required this.label,
    required this.value,
    required this.badge,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
        Row(
          children: [
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(width: 6),
            Text(badge, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
