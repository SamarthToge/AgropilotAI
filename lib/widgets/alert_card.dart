import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class AlertCard extends StatelessWidget {
  final String severity; // "Critical" or "Warning"
  final String title;
  final String currentValue;
  final String idealValue;
  final String action;

  const AlertCard({
    super.key,
    required this.severity,
    required this.title,
    required this.currentValue,
    required this.idealValue,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = severity == "Critical";
    final color = isCritical ? AppColors.critical : AppColors.warning;
    final bgColor = isCritical ? AppColors.criticalBg : AppColors.warningBg;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              isCritical ? "🔴" : "🟡",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        severity,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Current: $currentValue  ·  Ideal: $idealValue",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_right, size: 16, color: color),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        action,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
