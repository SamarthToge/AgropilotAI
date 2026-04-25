import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agropilot_ai/gen_l10n/app_localizations.dart';
import '../constants/app_constants.dart';
import '../providers/app_state.dart';
import '../providers/language_provider.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.settings,
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
            // ── Language Selection ─────────────────────────────────────
            _LanguageCard(),
            const SizedBox(height: 16),

            // ── Crop Type ─────────────────────────────────────────────
            _SettingsCard(
              title: l10n.cropConfiguration,

              children: [
                _SettingLabel(l10n.cropType),
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
                _SettingLabel(l10n.growthStage),
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
                _SettingLabel(l10n.daysPlanted),
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
                _SettingLabel(l10n.targetYield),
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
              title: l10n.pidSetpoints,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _PidRow("🌡 ${l10n.temperature}", "${config.pidTemp}°C"),
                      const Divider(height: 16),
                      _PidRow("💧 ${l10n.humidity}", "${config.pidHumidity}%"),
                      const Divider(height: 16),
                      _PidRow("💨 ${l10n.co2}", "${config.pidCo2} ppm"),
                      const Divider(height: 16),
                      _PidRow("🌱 ${l10n.soilMoisture}", "${config.pidMoisture}%"),
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
              title: l10n.notificationsTitle,
              children: [
                _ToggleRow(
                  label: l10n.criticalAlerts,
                  subtitle: l10n.criticalAlertsSubtitle,
                  value: state.criticalAlertsEnabled,
                  onChanged: (v) =>
                      context.read<AppState>().toggleCriticalAlerts(v),
                ),
                const Divider(height: 8),
                _ToggleRow(
                  label: l10n.dailySummary,
                  subtitle: l10n.dailySummarySubtitle,
                  value: state.dailySummaryEnabled,
                  onChanged: (v) =>
                      context.read<AppState>().toggleDailySummary(v),
                ),
                const Divider(height: 8),
                _ToggleRow(
                  label: l10n.harvestReminder,
                  subtitle: l10n.harvestReminderSubtitle,
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

// ── Language Selection Card ────────────────────────────────────────────────
class _LanguageCard extends StatelessWidget {
  const _LanguageCard();

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final l10n = AppLocalizations.of(context)!;

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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goodBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🌐', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.selectLanguage,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Language tiles
          ...LanguageProvider.supportedLanguages.map((lang) {
            final isSelected =
                langProvider.locale.languageCode == lang['code'];
            return _LanguageTile(
              code: lang['code']!,
              nativeName: lang['native']!,
              englishName: lang['name']!,
              isSelected: isSelected,
              onTap: () async {
                await context
                    .read<LanguageProvider>()
                    .changeLanguage(lang['code']!);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.languageChanged,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: AppColors.good,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String code;
  final String nativeName;
  final String englishName;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.goodBg
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor:
              isSelected ? AppColors.primary : const Color(0xFFEEEEEE),
          child: Text(
            code.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
        title: Text(
          nativeName,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          englishName,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle,
                color: AppColors.primary, size: 20)
            : null,
      ),
    );
  }
}
