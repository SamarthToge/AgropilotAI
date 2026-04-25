import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:agropilot_ai/gen_l10n/app_localizations.dart';
import '../../constants/app_constants.dart';
import '../../models/harvest_entry.dart';
import '../../services/harvest_firebase_service.dart';

class HarvestFormScreen extends StatefulWidget {
  const HarvestFormScreen({super.key});

  @override
  State<HarvestFormScreen> createState() => _HarvestFormScreenState();
}

class _HarvestFormScreenState extends State<HarvestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // ── Field controllers & state ─────────────────────────────────────────────
  DateTime _selectedDate = DateTime.now();
  String _cropType = 'Capsicum';
  String _harvestType = 'Green (Early)';
  String _grade = 'A Grade';
  String _whereSold = 'Local Market';

  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  // ── Computed total ────────────────────────────────────────────────────────
  double get _totalEarned {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    return qty * price;
  }

  String get _totalEarnedDisplay {
    final total = _totalEarned;
    if (total == 0) return '₹ 0.00';
    final formatter = NumberFormat('#,##,###.##', 'en_IN');
    return '₹ ${formatter.format(total)}';
  }

  // ── Options ───────────────────────────────────────────────────────────────
  final _cropOptions = ['Capsicum', 'Spinach'];
  final _harvestTypeOptions = [
    'Green (Early)',
    'Yellow (Mid)',
    'Red/Ripe (Full)',
  ];
  final _gradeOptions = ['A+ Grade', 'A Grade', 'B Grade', 'C Grade'];
  final _whereSoldOptions = [
    'Local Market',
    'Supermarket',
    'Direct to Customer',
    'Mandi',
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ── Date picker ───────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final qty = double.parse(_quantityController.text.trim());
    final price = double.parse(_priceController.text.trim());

    setState(() => _saving = true);
    try {
      final entry = HarvestEntry(
        id: '',
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        cropType: _cropType,
        harvestType: _harvestType,
        grade: _grade,
        quantityKg: qty,
        pricePerKg: price,
        totalEarned: qty * price,
        whereSold: _whereSold,
        notes: _notesController.text.trim(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await HarvestFirebaseService.instance.addEntry(entry);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${AppLocalizations.of(context)!.saveRecord}!',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.good,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Pop back to entries list — HarvestEntriesScreen will call _refresh()
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to save: $e',
              style: GoogleFonts.poppins()),
          backgroundColor: AppColors.critical,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.newHarvestEntry,
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
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Header Banner ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('📦', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.recordYourHarvest,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.fillDetails,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Field 1: Date ───────────────────────────────────────────
            _FieldCard(
              label: l10n.dateOfHarvest,
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),

            // ── Field 2: Crop Type ──────────────────────────────────────
            _FieldCard(
              label: '🌱 ${l10n.cropType}',
              child: _buildDropdown(
                value: _cropType,
                items: _cropOptions,
                onChanged: (v) => setState(() => _cropType = v!),
              ),
            ),

            // ── Field 3: Harvest Type ───────────────────────────────────
            _FieldCard(
              label: '🔖 ${l10n.harvestType}',
              child: _buildDropdown(
                value: _harvestType,
                items: _harvestTypeOptions,
                onChanged: (v) => setState(() => _harvestType = v!),
              ),
            ),

            // ── Field 4: Quality Grade ──────────────────────────────────
            _FieldCard(
              label: '⭐ ${l10n.grade}',
              child: _buildDropdown(
                value: _grade,
                items: _gradeOptions,
                onChanged: (v) => setState(() => _grade = v!),
              ),
            ),

            // ── Field 5: Quantity ───────────────────────────────────────
            _FieldCard(
              label: '⚖️ ${l10n.quantityHarvested}',
              child: TextFormField(
                controller: _quantityController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: _inputDecoration('Enter total kg harvested', 'kg'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Quantity is required';
                  }
                  final n = double.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Enter a valid quantity > 0';
                  return null;
                },
              ),
            ),

            // ── Field 6: Price ──────────────────────────────────────────
            _FieldCard(
              label: l10n.sellingPricePerKg,
              child: TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.poppins(fontSize: 14),
                decoration:
                    _inputDecoration('Enter market price', '₹/kg'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Price is required';
                  }
                  final n = double.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Enter a valid price > 0';
                  return null;
                },
              ),
            ),

            // ── Field 7: Total Earned (READ-ONLY) ───────────────────────
            _FieldCard(
              label: l10n.totalAmountReceived,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.good.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Text('💵', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Text(
                      _totalEarnedDisplay,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.autoCalculated,
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),

            // ── Field 8: Where Sold ─────────────────────────────────────
            _FieldCard(
              label: '🏦 ${l10n.whereSold}',
              child: _buildDropdown(
                value: _whereSold,
                items: _whereSoldOptions,
                onChanged: (v) => setState(() => _whereSold = v!),
              ),
            ),

            // ── Field 9: Notes ──────────────────────────────────────────
            _FieldCard(
              label: l10n.notesOptional,
              child: TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Any additional observations',
                  hintStyle: GoogleFonts.poppins(
                      color: AppColors.textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Submit Button ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _saving ? l10n.saving : l10n.saveRecord,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  DropdownButtonFormField<String> _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: GoogleFonts.poppins(
          fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: GoogleFonts.poppins(fontSize: 14)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration(String hint, String suffix) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
          color: AppColors.textSecondary, fontSize: 13),
      suffixText: suffix,
      suffixStyle: GoogleFonts.poppins(
          color: AppColors.primary, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.critical),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: AppColors.critical, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

// ── Field Card wrapper ─────────────────────────────────────────────────────
class _FieldCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
