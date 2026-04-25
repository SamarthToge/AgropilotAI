import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:agropilot_ai/gen_l10n/app_localizations.dart';
import '../../constants/app_constants.dart';
import '../../models/harvest_entry.dart';
import '../../services/harvest_firebase_service.dart';
import 'harvest_form_screen.dart';
import 'harvest_charts_screen.dart';

class HarvestEntriesScreen extends StatefulWidget {
  const HarvestEntriesScreen({super.key});

  @override
  State<HarvestEntriesScreen> createState() => _HarvestEntriesScreenState();
}

class _HarvestEntriesScreenState extends State<HarvestEntriesScreen> {
  late Future<List<HarvestEntry>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = HarvestFirebaseService.instance.getAllEntries();
    });
  }

  Future<void> _delete(String id) async {
    await HarvestFirebaseService.instance.deleteEntry(id);
    _refresh();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗑️ ${l10n.entryDeleted}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.critical,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showDetail(HarvestEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EntryDetailSheet(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.allHarvestEntries,
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
        actions: [
          // Charts button
          IconButton(
            tooltip: l10n.earningsChart,
            icon: const Icon(Icons.bar_chart, color: AppColors.secondary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const HarvestChartsScreen()),
            ),
          ),
          // Refresh
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HarvestFormScreen()),
          );
          _refresh();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.newEntry,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
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
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(color: AppColors.critical),
              ),
            );
          }

          final entries = snapshot.data ?? [];

          if (entries.isEmpty) {
            return _EmptyState(
              onAdd: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HarvestFormScreen()),
                );
                _refresh();
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: entries.length,
            itemBuilder: (ctx, i) {
              final e = entries[i];
              return _EntryCard(
                entry: e,
                onTap: () => _showDetail(e),
                onDelete: () => _delete(e.id),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📦', style: TextStyle(fontSize: 64)),
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
              l10n.startByAdding,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                l10n.addFirstEntry,
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Entry Card (with swipe-to-delete) ─────────────────────────────────────
class _EntryCard extends StatelessWidget {
  final HarvestEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _EntryCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,##,###.##', 'en_IN');
    final displayDate = _formatDate(entry.date);
    final gradeColor = _gradeColor(entry.grade);
    final l10n = AppLocalizations.of(context)!;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(l10n.deleteEntry,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            content: Text(l10n.deleteConfirm,
                style: GoogleFonts.poppins(fontSize: 13)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel,
                    style: GoogleFonts.poppins(
                        color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.critical,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.delete,
                    style:
                        GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.criticalBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline,
            color: AppColors.critical, size: 28),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: date + grade badge
              Row(
                children: [
                  const Text('📅', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    displayDate,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: gradeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: gradeColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      entry.grade,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: gradeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Crop + harvest type
              Row(
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.cropType} — ${entry.harvestType}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Quantity + price
              Row(
                children: [
                  const Text('⚖️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.quantityKg} kg',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 16),
                  const Text('🏷️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '₹${formatted.format(entry.pricePerKg)}/kg',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Total + market
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text('💰', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Text(
                          '₹${formatted.format(entry.totalEarned)} ${l10n.totalEarned.toLowerCase()}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Text('🏪', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        entry.whereSold,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _gradeColor(String grade) {
    if (grade.contains('A+')) return AppColors.good;
    if (grade.contains('A')) return AppColors.primaryLight;
    if (grade.contains('B')) return AppColors.warning;
    return AppColors.critical;
  }

  String _formatDate(String raw) {
    try {
      final dt = DateFormat('yyyy-MM-dd').parse(raw);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

// ── Entry Detail Bottom Sheet ──────────────────────────────────────────────
class _EntryDetailSheet extends StatelessWidget {
  final HarvestEntry entry;
  const _EntryDetailSheet({required this.entry});

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,##,###.##', 'en_IN');
    final l10n = AppLocalizations.of(context)!;
    String displayDate;
    try {
      final dt = DateFormat('yyyy-MM-dd').parse(entry.date);
      displayDate = DateFormat('dd MMMM yyyy').format(dt);
    } catch (_) {
      displayDate = entry.date;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Text(
            l10n.harvestDetails,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayDate,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          _DetailRow('🌱 ${l10n.cropType}', entry.cropType),
          _DetailRow('🔖 ${l10n.harvestType}', entry.harvestType),
          _DetailRow('⭐ ${l10n.grade}', entry.grade),
          _DetailRow('⚖️ ${l10n.quantityHarvested}', '${entry.quantityKg} kg'),
          _DetailRow('🏷️ ${l10n.pricePerKg}', '₹${formatted.format(entry.pricePerKg)}/kg'),
          _DetailRow('💰 ${l10n.totalEarned}',
              '₹${formatted.format(entry.totalEarned)}',
              valueColor: AppColors.primary,
              bold: true),
          _DetailRow('🏪 ${l10n.whereSold}', entry.whereSold),
          if (entry.notes.isNotEmpty) _DetailRow('📝 ${l10n.notes}', entry.notes),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _DetailRow(this.label, this.value,
      {this.valueColor, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight:
                    bold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
