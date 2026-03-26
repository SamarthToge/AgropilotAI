import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_state.dart';
import 'status_badge.dart';

class YieldSummaryCard extends StatelessWidget {
  final VoidCallback onViewFull;

  const YieldSummaryCard({super.key, required this.onViewFull});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("🌾", style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                "Yield Forecast",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              AlertLevelBadge(level: state.alertLevel),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                state.predictedYield.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "kg/m²",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _YieldStat(
                label: "Target",
                value: "${state.targetYield.toStringAsFixed(1)} kg/m²",
                color: AppColors.good,
              ),
              const SizedBox(width: 16),
              _YieldStat(
                label: "Gap",
                value: "-${state.yieldGap.toStringAsFixed(1)} kg/m²",
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onViewFull,
              icon: const Icon(Icons.bar_chart, size: 16),
              label: Text(
                "View Full Prediction →",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YieldStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _YieldStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
