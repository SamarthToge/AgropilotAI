import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  final SensorStatus status;
  final String? customLabel;
  final bool small;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = customLabel ?? statusLabel(status);
    final color = statusColor(status);
    final bgColor = statusBgColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AlertLevelBadge extends StatelessWidget {
  final String level;

  const AlertLevelBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    String emoji;

    switch (level) {
      case "Critical":
        color = AppColors.critical;
        bg = AppColors.criticalBg;
        emoji = "🔴";
        break;
      case "Warning":
        color = AppColors.warning;
        bg = AppColors.warningBg;
        emoji = "🟡";
        break;
      default:
        color = AppColors.good;
        bg = AppColors.goodBg;
        emoji = "🟢";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        "$emoji $level",
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
