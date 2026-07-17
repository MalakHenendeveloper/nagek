import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../cubit/admin_payments_cubit.dart';
import '../../cubit/admin_payments_state.dart';
import '../../../domain/entities/admin_payment_entity.dart';

class AdminPaymentsView extends StatefulWidget {
  const AdminPaymentsView({super.key});

  @override
  State<AdminPaymentsView> createState() => _AdminPaymentsViewState();
}

class _AdminPaymentsViewState extends State<AdminPaymentsView> {
  final ScrollController _scrollController = ScrollController();
  late AdminPaymentsCubit _paymentsCubit;
  bool _isLoadingDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _paymentsCubit = context.read<AdminPaymentsCubit>();
    _scrollController.addListener(_onScroll);
    _paymentsCubit.fetchPayments(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _paymentsCubit.fetchPayments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminPaymentsCubit, AdminPaymentsState>(
      listener: (context, state) {
        if (state is AdminPaymentsLoaded) {
          if (state.isReviewLoading) {
            _showLoadingDialog();
          } else {
            _dismissLoadingDialog();
          }

          if (state.reviewSuccessMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.reviewSuccessMessage!,
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh list
            _paymentsCubit.fetchPayments(isRefresh: true);
          } else if (state.reviewError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.reviewError!,
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is AdminPaymentsInitial || (state is AdminPaymentsLoading && state is! AdminPaymentsLoaded)) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (context, index) => const _PaymentCardSkeleton(),
          );
        } else if (state is AdminPaymentsError && state is! AdminPaymentsLoaded) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _paymentsCubit.fetchPayments(isRefresh: true),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'إعادة المحاولة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is AdminPaymentsLoaded) {
          final payments = state.payments;
          if (payments.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_outlined, color: Colors.white24, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد عمليات دفع مسجلة حالياً',
                      style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFFFC107),
            onRefresh: () async {
              await _paymentsCubit.fetchPayments(isRefresh: true);
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.hasReachedMax ? payments.length : payments.length + 1,
              itemBuilder: (context, index) {
                if (index >= payments.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFFFC107)),
                    ),
                  );
                }

                final payment = payments[index];
                return _buildPaymentCard(payment);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPaymentCard(AdminPaymentEntity payment) {
    // Translate status
    String statusAr = 'بانتظار التأكيد';
    Color statusColor = Colors.orange;
    if (payment.status == 'approved' || payment.status == 'confirmed') {
      statusAr = 'تم التأكيد ✅';
      statusColor = Colors.green;
    } else if (payment.status == 'rejected') {
      statusAr = 'مرفوض ❌';
      statusColor = Colors.redAccent;
    }

    // Translate method
    String methodAr = payment.paymentMethod;
    if (payment.paymentMethod == 'zain_cash') {
      methodAr = 'زين كاش';
    } else if (payment.paymentMethod == 'asia_hawala') {
      methodAr = 'آسيا حوالة';
    } else if (payment.paymentMethod == 'cod') {
      methodAr = 'الدفع عند التسليم';
    } else if (payment.paymentMethod == 'credit_card') {
      methodAr = 'بطاقة ائتمانية';
    }

    final dateString = payment.createdAt.isNotEmpty
        ? DateTime.tryParse(payment.createdAt)?.toLocal().toString().substring(0, 16) ?? ''
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Order Number & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رقم الطلب',
                    style: GoogleFonts.cairo(color: Colors.white30, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    payment.order.orderNumber.split('-').last,
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFFFC107),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  statusAr,
                  style: GoogleFonts.cairo(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),

          // Client Info
          _buildDetailRow(
            label: 'العميل',
            value: payment.client.name,
            icon: Icons.person_outline,
          ),
          _buildDetailRow(
            label: 'رقم الهاتف',
            value: payment.client.phone,
            icon: Icons.phone_outlined,
            isLtr: true,
          ),

          // Financial Info
          _buildDetailRow(
            label: 'المبلغ المدفوع',
            value: '${payment.amount.toInt()} د.ع',
            icon: Icons.monetization_on_outlined,
            valueColor: const Color(0xFFFFC107),
            isBold: true,
          ),
          _buildDetailRow(
            label: 'طريقة الدفع',
            value: methodAr,
            icon: Icons.payment_outlined,
          ),

          // Wallet Details
          if (payment.senderWalletNumber.isNotEmpty)
            _buildDetailRow(
              label: 'رقم المحفظة المرسلة',
              value: payment.senderWalletNumber,
              icon: Icons.account_balance_wallet_outlined,
              isLtr: true,
              trailing: IconButton(
                icon: const Icon(Icons.copy, size: 16, color: Colors.white54),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: payment.senderWalletNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نسخ رقم المحفظة'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),

          if (dateString.isNotEmpty) ...[
            const Divider(color: Colors.white10, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تاريخ التحويل',
                  style: GoogleFonts.cairo(color: Colors.white30, fontSize: 11),
                ),
                Text(
                  dateString,
                  style: GoogleFonts.cairo(color: Colors.white30, fontSize: 11),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ],

          if (payment.status != 'approved' && payment.status != 'confirmed' && payment.status != 'rejected') ...[
            const Divider(color: Colors.white10, height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(payment.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'رفض الدفع',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showApproveConfirmation(payment.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'تأكيد الدفع',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    bool isLtr = false,
    Color? valueColor,
    bool isBold = false,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: GoogleFonts.cairo(color: Colors.white54, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: valueColor ?? Colors.white,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            trailing,
          ],
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    if (_isLoadingDialogOpen) return;
    _isLoadingDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFC107)),
      ),
    ).then((_) => _isLoadingDialogOpen = false);
  }

  void _dismissLoadingDialog() {
    if (_isLoadingDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isLoadingDialogOpen = false;
    }
  }

  void _showApproveConfirmation(String paymentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تأكيد الدفع',
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        content: Text(
          'هل أنت متأكد من تأكيد استلام هذا الدفع؟ سيتم تحديث حالة الطلب.',
          style: GoogleFonts.cairo(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _paymentsCubit.reviewPayment(paymentId: paymentId, status: 'confirmed');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'نعم، تأكيد',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(String paymentId) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'رفض الدفع',
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'يرجى إدخال سبب الرفض:',
                style: GoogleFonts.cairo(color: Colors.white70),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                maxLines: 3,
                style: GoogleFonts.cairo(color: Colors.white),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'مثال: رقم الحوالة غير صحيح',
                  hintStyle: GoogleFonts.cairo(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى كتابة سبب الرفض';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                _paymentsCubit.reviewPayment(
                  paymentId: paymentId,
                  status: 'rejected',
                  rejectionReason: controller.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'تأكيد الرفض',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCardSkeleton extends StatelessWidget {
  const _PaymentCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E1E),
      highlightColor: const Color(0xFF2A2A2A),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
