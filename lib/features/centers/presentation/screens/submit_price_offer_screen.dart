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

  final _totalCostController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<SubmitPriceOfferCubit>();
  }

  @override
  void dispose() {
    _totalCostController.dispose();
    _notesController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    _cubit.submitPriceOffer(
      orderId: widget.orderId,
      totalCost: double.tryParse(_totalCostController.text) ?? 0.0,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Total Cost ──────────────────────────
                      _buildSectionTitle('التكلفة الإجمالية', Icons.monetization_on_outlined),
                      const SizedBox(height: 12),
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المبلغ الإجمالي (بالدينار)',
                              style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _totalCostController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'هذا الحقل مطلوب';
                                final numVal = double.tryParse(val);
                                if (numVal == null) return 'يرجى إدخال رقم صحيح';
                                if (numVal <= 0) return 'القيمة يجب أن تكون أكبر من صفر';
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'أدخل التكلفة الإجمالية للصيانة',
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
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ─── Notes ────────────────────────────────
                      _buildSectionTitle('الملاحظات', Icons.notes_outlined),
                      const SizedBox(height: 12),
                      _buildCard(
                        child: Column(
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
                      ),
                      const SizedBox(height: 24),

                      // ─── Cost Summary ───────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: Row(
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
}
