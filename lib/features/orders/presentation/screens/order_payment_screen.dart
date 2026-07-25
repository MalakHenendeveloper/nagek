import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/di/di.dart';
import '../cubit/order_payment_cubit.dart';
import '../cubit/order_payment_state.dart';
import '../../domain/entities/order_payment_entity.dart';

class OrderPaymentScreen extends StatefulWidget {
  final String orderId;

  const OrderPaymentScreen({super.key, required this.orderId});

  @override
  State<OrderPaymentScreen> createState() => _OrderPaymentScreenState();
}

class _OrderPaymentScreenState extends State<OrderPaymentScreen> {
  late OrderPaymentCubit _cubit;
  String? _selectedMethod;


  @override
  void initState() {
    super.initState();
    _cubit = getIt<OrderPaymentCubit>()..fetchPaymentDetails(widget.orderId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showPaymentBottomSheet(double total, String currency) {
    final walletController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'إثبات الدفع',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'أدخل بيانات عملية الدفع لتأكيد الطلب',
                    style: GoogleFonts.cairo(fontSize: 13, color: Colors.white54),
                  ),
                  const SizedBox(height: 20),

                  // Payment Method Display
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_outlined, color: Color(0xFFFFC107), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'المبلغ المطلوب: ${total.toInt()} $currency',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFC107),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Wallet Number Input
                  Text(
                    'رقم المحفظة المرسلة منها',
                    style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: walletController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 16),
                    textDirection: TextDirection.ltr,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'يرجى إدخال رقم المحفظة';
                      if (val.trim().length < 10) return 'رقم المحفظة غير صحيح';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: '07XXXXXXXXX',
                      hintStyle: GoogleFonts.cairo(color: Colors.white24, fontSize: 15),
                      prefixIcon: const Icon(Icons.phone_android, color: Color(0xFFFFC107)),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      errorStyle: GoogleFonts.cairo(color: Colors.redAccent, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  BlocProvider.value(
                    value: _cubit,
                    child: BlocConsumer<OrderPaymentCubit, OrderPaymentState>(
                      listener: (ctx, state) {
                        if (state is OrderPaymentLoaded && state.isSubmitted) {
                          Navigator.pop(ctx); // Close bottom sheet
                          _showSuccessDialog(total, currency);
                        }
                      },
                      builder: (ctx, state) {
                        final isSubmitting = state is OrderPaymentLoaded && state.isSubmitting;
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) return;
                                    final success = await _cubit.submitPaymentProof(
                                      orderId: widget.orderId,
                                      senderWalletNumber: walletController.text.trim(),
                                      transferReference: '',
                                      paymentMethod: _selectedMethod ?? 'zain_cash',
                                    );
                                    if (!success && ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(
                                          content: Text('فشل في إرسال إثبات الدفع', style: GoogleFonts.cairo()),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107),
                              foregroundColor: Colors.black87,
                              disabledBackgroundColor: const Color(0xFFFFC107).withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            icon: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
                                  )
                                : const Icon(Icons.send_rounded),
                            label: Text(
                              isSubmitting ? 'جاري الإرسال...' : 'إرسال إثبات الدفع',
                              style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(double total, String currency) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 56),
            const SizedBox(height: 16),
            Text(
              'تم إرسال إثبات الدفع',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'تم إرسال إثبات دفع مبلغ ${total.toInt()} $currency بنجاح.\nسيتم مراجعة الدفع وتأكيده من قبل الإدارة.',
          style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context, true); // Pop back with refresh
            },
            child: Text(
              'موافق',
              style: GoogleFonts.cairo(color: const Color(0xFFFFC107), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text(
            'تفاصيل الدفع والفاتورة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFFFFC107)),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocConsumer<OrderPaymentCubit, OrderPaymentState>(
            listener: (context, state) {
              if (state is OrderPaymentLoaded) {
                final availableMethods = state.details.paymentInfo?.availablePaymentMethods ??
                    state.details.financialView.walletInfo?.walletNumbers.keys.toList() ??
                    ['zain_cash'];
                if (_selectedMethod == null && availableMethods.isNotEmpty) {
                  setState(() {
                    _selectedMethod = availableMethods.first;
                  });
                }
              }
            },
            builder: (context, state) {
              if (state is OrderPaymentLoading || state is OrderPaymentInitial) {
                return _buildSkeletonLoader();
              }

              if (state is OrderPaymentError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: GoogleFonts.cairo(color: Colors.redAccent, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _cubit.fetchPaymentDetails(widget.orderId),
                          icon: const Icon(Icons.refresh),
                          label: Text('إعادة المحاولة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is OrderPaymentLoaded) {
                final order = state.details.order;
                final financial = state.details.financialView;
                final isPaid = financial.paymentStatus.toLowerCase() == 'paid';
                final isPending = financial.paymentStatus.toLowerCase() == 'pending';
                final availableMethods = state.details.paymentInfo?.availablePaymentMethods ??
                    financial.walletInfo?.walletNumbers.keys.toList() ??
                    ['zain_cash'];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Order & Payment Status ────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'رقم الفاتورة',
                                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.orderNumber.split('-').last,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : isPending
                                        ? Colors.orange.withValues(alpha: 0.15)
                                        : const Color(0xFFFFC107).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isPaid
                                      ? Colors.green
                                      : isPending
                                          ? Colors.orange
                                          : const Color(0xFFFFC107),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                isPaid
                                    ? 'تم الدفع ✅'
                                    : isPending
                                        ? 'قيد المراجعة ⏳'
                                        : 'بانتظار الدفع',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isPaid
                                      ? Colors.greenAccent
                                      : isPending
                                          ? Colors.orange
                                          : const Color(0xFFFFC107),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ─── Device Details Card ───────────────────
                      _buildSectionTitle('تفاصيل الجهاز والطلب', Icons.phone_iphone_outlined),
                      const SizedBox(height: 8),
                      _buildCard(
                        child: Column(
                          children: [
                            _buildInfoRow('نوع الجهاز', _getDeviceTypeLabel(order.device.type)),
                            _buildInfoRow('الماركة والموديل', '${order.device.brand} ${order.device.model}'),
                            _buildInfoRow('المشكلة المشخصة', _getProblemTypeLabel(order.device.problemType)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ─── Billing breakdown ──────────────────────
                      _buildSectionTitle('تفاصيل التكاليف والفاتورة', Icons.receipt_long_outlined),
                      const SizedBox(height: 8),
                      _buildCard(
                        child: _buildBillingRow(
                          'المبلغ الكلي المطلوب',
                          '${(financial.orderTotal > 0 ? financial.orderTotal : ((order.financialSnapshot != null && order.financialSnapshot!.clientTotal > 0) ? order.financialSnapshot!.clientTotal : (order.fees.total > 0 ? order.fees.total : (order.fees.repair + order.fees.delivery + order.fees.inspection)))).toInt()} ${financial.currency}',
                          isHighlighted: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ─── Payment Method & Wallet Info (if unpaid) ──
                      if (!isPaid && !isPending) ...[
                        _buildSectionTitle('طريقة الدفع', Icons.payment_outlined),
                        const SizedBox(height: 8),
                        ...availableMethods.map((method) {
                          final isSelected = _selectedMethod == method;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedMethod = method;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFFC107).withValues(alpha: 0.1)
                                      : const Color(0xFF141414),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFFC107)
                                        : Colors.white12,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getMethodIcon(method),
                                      color: isSelected ? const Color(0xFFFFC107) : Colors.white54,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getMethodName(method),
                                            style: GoogleFonts.cairo(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? const Color(0xFFFFC107) : Colors.white,
                                            ),
                                          ),
                                          Text(
                                            _getMethodDescription(method),
                                            style: GoogleFonts.cairo(
                                              fontSize: 11,
                                              color: isSelected ? Colors.white38 : Colors.white30,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle_rounded, color: Color(0xFFFFC107), size: 20)
                                    else
                                      const Icon(Icons.radio_button_off_outlined, color: Colors.white24, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),

                        // ─── Wallet Number for Transfer ───────────
                        _buildSectionTitle('رقم المحفظة للتحويل', Icons.phone_android_outlined),
                        const SizedBox(height: 8),
                        _buildWalletInfoCard(
                          financial.walletInfo ?? state.details.paymentInfo,
                          _selectedMethod ?? 'zain_cash',
                        ),
                        const SizedBox(height: 32),

                        // ─── Action Button ───────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => _showPaymentBottomSheet(financial.orderTotal > 0 ? financial.orderTotal : order.fees.total, financial.currency),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107),
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.check_outlined),
                            label: Text(
                              'تأكيد وإرسال إثبات الدفع',
                              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ] else if (isPending) ...[
                        // Pending review banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1.5),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.hourglass_top_outlined, color: Colors.orange, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'تم إرسال إثبات الدفع',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'إثبات الدفع قيد المراجعة من قبل الإدارة. سيتم تأكيد الدفع وتحديث حالة الطلب قريباً.',
                                style: GoogleFonts.cairo(fontSize: 12, color: Colors.white54),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Paid banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 1.5),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.verified_outlined, color: Colors.greenAccent, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'تم سداد الفاتورة بنجاح',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'تم استلام وتأكيد سداد المبلغ بالكامل. جهازك قيد التجهيز الآن.',
                                style: GoogleFonts.cairo(fontSize: 12, color: Colors.white54),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(fontSize: 13, color: Colors.white54)),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: isHighlighted ? 14 : 13,
              color: isHighlighted ? Colors.white : Colors.white54,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: isHighlighted ? 18 : 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: isHighlighted ? const Color(0xFFFFC107) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletInfoCard(dynamic walletInfo, String selectedMethod) {
    String walletNumber = '';
    String walletName = 'شركة الصيانة';
    String instructions = '';

    if (walletInfo is WalletInfoEntity) {
      walletNumber = walletInfo.walletNumbers[selectedMethod] ?? '';
      walletName = walletInfo.walletOwnerName;
      instructions = walletInfo.paymentInstructions;
    } else if (walletInfo is PaymentInfoEntity) {
      walletNumber = walletInfo.walletNumbers[selectedMethod] ?? '';
      walletName = walletInfo.walletOwnerName;
      instructions = walletInfo.paymentInstructions;
    } else if (walletInfo is Map) {
      walletNumber = walletInfo['walletNumber']?.toString() ?? walletInfo['number']?.toString() ?? '';
      walletName = walletInfo['name']?.toString() ?? walletInfo['walletName']?.toString() ?? 'زين كاش';
    } else if (walletInfo is String) {
      walletNumber = walletInfo;
    }

    if (walletNumber.isEmpty) {
      walletNumber = 'سيتم تزويدك بالرقم قريباً';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'قم بتحويل المبلغ إلى المحفظة التالية:',
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getMethodIcon(selectedMethod), color: const Color(0xFFFFC107), size: 20),
                const SizedBox(width: 10),
                SelectableText(
                  walletNumber,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFC107),
                    letterSpacing: 1.5,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'باسم: $walletName',
            style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
          ),
          if (instructions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              instructions,
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.white54),
            ),
          ],
        ],
      ),
    );
  }

  String _getMethodName(String method) {
    switch (method) {
      case 'zain_cash': return 'زين كاش';
      case 'western_union': return 'ويسترن يونيون';
      case 'visa': return 'فيزا كارد';
      case 'mastercard': return 'ماستر كارد';
      default: return method;
    }
  }

  String _getMethodDescription(String method) {
    switch (method) {
      case 'zain_cash': return 'الدفع عبر محفظة زين كاش الإلكترونية';
      case 'western_union': return 'تحويل مالي عبر ويسترن يونيون';
      case 'visa': return 'الدفع الآمن باستخدام بطاقة فيزا';
      case 'mastercard': return 'الدفع الآمن باستخدام بطاقة ماستر كارد';
      default: return 'الدفع الإلكتروني السريع والآمن';
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'zain_cash': return Icons.account_balance_wallet_outlined;
      case 'western_union': return Icons.monetization_on_outlined;
      case 'visa':
      case 'mastercard': return Icons.credit_card_outlined;
      default: return Icons.payment_outlined;
    }
  }

  String _getDeviceTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'phone': return 'هاتف محمول';
      case 'tablet': return 'تابلت';
      case 'laptop': return 'كمبيوتر محمول';
      default: return type;
    }
  }

  String _getProblemTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'screen': return 'شاشة مكسورة';
      case 'battery': return 'تلف البطارية';
      case 'software': return 'مشكلة نظام/سوفتوير';
      case 'hardware': return 'عطل بورد/هاردوير';
      case 'other': return 'أعطال أخرى';
      default: return type;
    }
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: Colors.white10,
        highlightColor: Colors.white24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 20),
            Container(height: 20, width: 150, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 20),
            Container(height: 20, width: 180, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 20),
            Container(height: 20, width: 140, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 10),
            Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ],
        ),
      ),
    );
  }
}
