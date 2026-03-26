import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _daysCtrl;
  late TextEditingController _targetCtrl;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _daysCtrl = TextEditingController(text: state.daysPlanted.toString());
    _targetCtrl =
        TextEditingController(text: state.targetYield.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _daysCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final config = state.cropConfig;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Settings",
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
            // ── Crop Type ─────────────────────────────────────────────
            _SettingsCard(
              title: "🌿 Crop Configuration",
              children: [
                _SettingLabel("Crop Type"),
                const SizedBox(height: 8),
                Row(
                  children: ["Spinach", "Capsicum"].map((crop) {
                    final selected = state.cropType == crop;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.read<AppState>().setCropType(crop);
                          _daysCtrl.text = "1";
                          _targetCtrl.text = "3.0";
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                              right: crop == "Spinach" ? 8 : 0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.divider,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                crop == "Spinach" ? "🌿" : "🫑",
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                crop,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Growth Stage selector
                _SettingLabel("Growth Stage"),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: state.growthStage,
                  decoration: _inputDecoration(),
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textPrimary),
                  items: config.stages
                      .map((s) => DropdownMenuItem(
                            value: s.name,
                            child: Text("${s.emoji}  ${s.name}"),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) context.read<AppState>().setGrowthStage(val);
                  },
                ),
                const SizedBox(height: 16),

                // Days planted
                _SettingLabel("Days Planted"),
                const SizedBox(height: 8),
                TextField(
                  controller: _daysCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration()
                      .copyWith(suffixText: "days"),
                  style: GoogleFonts.poppins(fontSize: 13),
                  onSubmitted: (val) {
                    final d = int.tryParse(val);
                    if (d != null) context.read<AppState>().setDaysPlanted(d);
                  },
                ),
                const SizedBox(height: 16),

                // Target yield
                _SettingLabel("Target Yield"),
                const SizedBox(height: 8),
                TextField(
                  controller: _targetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration()
                      .copyWith(suffixText: "kg/m²"),
                  style: GoogleFonts.poppins(fontSize: 13),
                  onSubmitted: (val) {
                    final d = double.tryParse(val);
                    if (d != null) context.read<AppState>().setTargetYield(d);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── PID Setpoints (read-only) ─────────────────────────────
            _SettingsCard(
              title: "⚙️ PID Setpoints (Read-Only)",
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _PidRow("🌡 Temperature", "${config.pidTemp}°C"),
                      const Divider(height: 16),
                      _PidRow("💧 Humidity", "${config.pidHumidity}%"),
                      const Divider(height: 16),
                      _PidRow("💨 CO₂", "${config.pidCo2} ppm"),
                      const Divider(height: 16),
                      _PidRow("🌱 Soil Moisture", "${config.pidMoisture}%"),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "These values are auto-set by the ESP32 PID controller based on crop type.",
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Notifications ────────────────────────────────────────
            _SettingsCard(
              title: "🔔 Notifications",
              children: [
                _ToggleRow(
                  label: "Critical Alerts",
                  subtitle: "Immediately notify on critical sensor values",
                  value: state.criticalAlertsEnabled,
                  onChanged: (v) =>
                      context.read<AppState>().toggleCriticalAlerts(v),
                ),
                const Divider(height: 8),
                _ToggleRow(
                  label: "Daily Summary",
                  subtitle: "Get daily crop health report at 8 AM",
                  value: state.dailySummaryEnabled,
                  onChanged: (v) =>
                      context.read<AppState>().toggleDailySummary(v),
                ),
                const Divider(height: 8),
                _ToggleRow(
                  label: "Harvest Reminder",
                  subtitle: "Notify 3 days before estimated harvest date",
                  value: state.harvestReminderEnabled,
                  onChanged: (v) =>
                      context.read<AppState>().toggleHarvestReminder(v),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _SettingLabel extends StatelessWidget {
  final String text;
  const _SettingLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _PidRow extends StatelessWidget {
  final String label;
  final String value;
  const _PidRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textPrimary)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary)),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text(subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          thumbColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(WidgetState.selected)) return AppColors.primary;
              return Colors.grey;
            },
          ),
        ),
      ],
    );
  }
}
