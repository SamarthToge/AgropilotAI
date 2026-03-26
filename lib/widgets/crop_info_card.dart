import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../providers/app_state.dart';

class CropInfoCard extends StatelessWidget {
  const CropInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final config = state.cropConfig;
    final stages = config.stages;
    final progress = state.progressPercent;
    final harvestDate = DateFormat('dd MMM yyyy').format(state.harvestDate);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop name + emoji
          Row(
            children: [
              Text(config.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "${state.growthStage} Stage",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Day ${state.daysPlanted}",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "of ${state.totalDays} days",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stage Timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stages.map((s) {
              final isCurrent = s.name == state.growthStage;
              final isCompleted =
                  state.daysPlanted > s.endDay;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Colors.white
                            : isCompleted
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: isCurrent
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          isCurrent
                              ? "◄"
                              : isCompleted
                                  ? "✅"
                                  : "⏳",
                          style: TextStyle(
                            fontSize: isCurrent ? 12 : 14,
                            color: isCurrent ? AppColors.primary : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.emoji,
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      s.name.length > 8
                          ? '${s.name.substring(0, 8)}…'
                          : s.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Status message
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              state.statusMessage,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Harvest date
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(
                "Est. Harvest: $harvestDate",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${state.remainingDays} days left",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
