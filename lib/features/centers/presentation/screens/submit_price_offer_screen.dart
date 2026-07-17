import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../cubit/submit_price_offer_cubit.dart';
import '../cubit/submit_price_offer_state.dart';

class SubmitPriceOfferScreen extends StatefulWidget {
  final String orderId;

  const SubmitPriceOfferScreen({super.key, required this.orderId});

  @override
  State<SubmitPriceOfferScreen> createState() => _SubmitPriceOfferScreenState();
}

class _SubmitPriceOfferScreenState extends State<SubmitPriceOfferScreen> {
  late SubmitPriceOfferCubit _cubit;
  final _formKey = GlobalKey<FormState>();

  final _laborCostController = TextEditingController(text: '0');
  final _inspectionFeeController = TextEditingController(text: '0');
  final _deliveryFeeController = TextEditingController(text: '0');
  final _estimatedDaysController = TextEditingController(text: '3');
  final _notesController = TextEditingController();

  final List<Map<String, dynamic>> _spareParts = [];

  double _totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<SubmitPriceOfferCubit>();
    _addSparePart();
    _calculateTotal();

    _laborCostController.addListener(_calculateTotal);
    _inspectionFeeController.addListener(_calculateTotal);
    _deliveryFeeController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _laborCostController.dispose();
    _inspectionFeeController.dispose();
    _deliveryFeeController.dispose();
    _estimatedDaysController.dispose();
    _notesController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _addSparePart() {
    setState(() {
      _spareParts.add({'name': '', 'cost': 0.0});
    });
  }

  void _removeSparePart(int index) {
    setState(() {
      _spareParts.removeAt(index);
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    double sparePartsSum = 0.0;
    for (final part in _spareParts) {
      final cost = part['cost'] as double? ?? 0.0;
      sparePartsSum += cost;
    }

    final labor = double.tryParse(_laborCostController.text) ?? 0.0;
    final inspection = double.tryParse(_inspectionFeeController.text) ?? 0.0;
    final delivery = double.tryParse(_deliveryFeeController.text) ?? 0.0;

    setState(() {
      _totalCost = sparePartsSum + labor + inspection + delivery;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final validParts = _spareParts
        .where((p) => (p['name'] as String).trim().isNotEmpty)
        .map((p) => {
              'name': (p['name'] as String).trim(),
              'cost': p['cost'] as double? ?? 0.0,
            })
        .toList();

    _cubit.submitPriceOffer(
      orderId: widget.orderId,
      spareParts: validParts,
      laborCost: double.tryParse(_laborCostController.text) ?? 0.0,
      inspectionFee: double.tryParse(_inspectionFeeController.text) ?? 0.0,
      deliveryFee: double.tryParse(_deliveryFeeController.text) ?? 0.0,
      estimatedDays: int.tryParse(_estimatedDaysController.text) ?? 3,
      notes: _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text('تقديم عرض سعر صيانة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFFFFC107)),
        ),
        body: BlocConsumer<SubmitPriceOfferCubit, SubmitPriceOfferState>(
          listener: (context, state) {
            if (state is SubmitPriceOfferSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إرسال عرض السعر بنجاح ✅', style: GoogleFonts.cairo()),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            }
            if (state is SubmitPriceOfferError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: GoogleFonts.cairo()),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is SubmitPriceOfferLoading;
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Spare Parts Title & Add Button ─────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle('قطع الغيار المطلوبة', Icons.settings_input_component_outlined),
                              TextButton.icon(
                                onPressed: _addSparePart,
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFFC107), size: 20),
                                label: Text(
                                  'إضافة قطعة',
                                  style: GoogleFonts.cairo(color: const Color(0xFFFFC107), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_spareParts.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                'لم يتم تحديد قطع غيار بعد (اختياري)',
                                style: GoogleFonts.cairo(color: Colors.white30, fontSize: 13),
                              ),
                            )
                          else
                            ..._spareParts.asMap().entries.map((entry) {
                              final index = entry.key;
                              return _buildSparePartCard(index);
                            }),
                          const SizedBox(height: 24),

                          // ─── Financial Fees ──────────────────────
                          _buildSectionTitle('أجور ورسوم الصيانة', Icons.monetization_on_outlined),
                          const SizedBox(height: 12),
                          _buildCard(
                            child: Column(
                              children: [
                                _buildNumericField(
                                  controller: _laborCostController,
                                  label: 'أجور اليد (تكلفة العمل)',
                                  hint: 'أدخل تكلفة صيانة الفني بالدينار',
                                ),
                                const SizedBox(height: 16),
                                _buildNumericField(
                                  controller: _inspectionFeeController,
                                  label: 'رسوم الفحص والتشخيص',
                                  hint: 'أدخل رسوم فحص الجهاز بالدينار',
                                ),
                                const SizedBox(height: 16),
                                _buildNumericField(
                                  controller: _deliveryFeeController,
                                  label: 'رسوم التوصيل والاسترجاع',
                                  hint: 'أدخل رسوم نقل ومندوب الجهاز بالدينار',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ─── Duration & Notes ────────────────────
                          _buildSectionTitle('المدة والملاحظات', Icons.av_timer_outlined),
                          const SizedBox(height: 12),
                          _buildCard(
                            child: Column(
                              children: [
                                _buildNumericField(
                                  controller: _estimatedDaysController,
                                  label: 'المدة المقدرة (بالأيام)',
                                  hint: 'أدخل عدد الأيام المقدرة للإصلاح',
                                  isIntegerOnly: true,
                                ),
                                const SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'تفاصيل وملاحظات إضافية',
                                      style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _notesController,
                                      maxLines: 3,
                                      style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: 'مثال: قطع غيار أصلية بضمان 6 أشهر',
                                        hintStyle: GoogleFonts.cairo(color: Colors.white30, fontSize: 13),
                                        filled: true,
                                        fillColor: const Color(0xFF1E1E1E),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ─── Live Cost Summary ───────────────────
                          _buildSectionTitle('ملخص التكاليف الإجمالية', Icons.summarize_outlined),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3), width: 1.5),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'المبلغ الإجمالي التقريبي للعميل:',
                                      style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
                                    ),
                                    Text(
                                      '${_totalCost.toInt()} د.ع',
                                      style: GoogleFonts.cairo(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFFFC107),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.white12, height: 20),
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline, color: Colors.white54, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'هذا العرض يتم إرساله للعميل للموافقة أو الرفض عبر التطبيق.',
                                        style: GoogleFonts.cairo(fontSize: 11, color: Colors.white54),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ─── Submit Button ───────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFC107),
                                foregroundColor: Colors.black87,
                                disabledBackgroundColor: const Color(0xFFFFC107).withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
                                    )
                                  : const Icon(Icons.send_rounded),
                              label: Text(
                                isLoading ? 'جاري الإرسال...' : 'إرسال عرض السعر للعميل',
                                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Helper Widgets ──────────────────────────────────────

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }

  Widget _buildNumericField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isIntegerOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
          validator: (val) {
            if (val == null || val.trim().isEmpty) return 'هذا الحقل مطلوب';
            final numVal = double.tryParse(val);
            if (numVal == null) return 'يرجى إدخال رقم صحيح';
            if (numVal < 0) return 'القيمة لا يمكن أن تكون سالبة';
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(color: Colors.white30, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSparePartCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'القطعة ${index + 1}',
                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white54),
              ),
              GestureDetector(
                onTap: () => _removeSparePart(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _spareParts[index]['name'],
            onChanged: (val) {
              _spareParts[index]['name'] = val;
            },
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'اسم قطعة الغيار (مثال: شاشة أصلية)',
              hintStyle: GoogleFonts.cairo(color: Colors.white30, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _spareParts[index]['cost'] == 0.0 ? '' : _spareParts[index]['cost'].toString(),
            keyboardType: TextInputType.number,
            onChanged: (val) {
              final costVal = double.tryParse(val) ?? 0.0;
              _spareParts[index]['cost'] = costVal;
              _calculateTotal();
            },
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'تكلفة قطعة الغيار بالدينار',
              hintStyle: GoogleFonts.cairo(color: Colors.white30, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
