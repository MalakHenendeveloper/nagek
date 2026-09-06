import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routes_manager/routes.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/center_order_details_entity.dart';
import '../cubit/center_order_details_cubit.dart';
import '../cubit/center_order_details_state.dart';

class CenterOrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const CenterOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<CenterOrderDetailsScreen> createState() => _CenterOrderDetailsScreenState();
}

class _CenterOrderDetailsScreenState extends State<CenterOrderDetailsScreen> {
  late CenterOrderDetailsCubit _cubit;
  bool _isLoadingDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<CenterOrderDetailsCubit>()..fetchOrderDetails(widget.orderId);
  }

  @override
  void dispose() {
    _dismissLoadingDialog();
    _cubit.close();
    super.dispose();
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

  Future<void> _makeCall(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text(
            'تفاصيل الطلب',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFFFFC107)),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocListener<CenterOrderDetailsCubit, CenterOrderDetailsState>(
            listener: (context, state) {
              if (state is CenterOrderStatusUpdateLoading) {
                _showLoadingDialog();
              } else {
                _dismissLoadingDialog();
              }

              if (state is CenterOrderStatusUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تحديث حالة الطلب بنجاح',
                      style: GoogleFonts.cairo(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                _cubit.fetchOrderDetails(widget.orderId);
              } else if (state is CenterOrderStatusUpdateError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: GoogleFonts.cairo(color: Colors.white),
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: BlocBuilder<CenterOrderDetailsCubit, CenterOrderDetailsState>(
              buildWhen: (previous, current) =>
                  current is CenterOrderDetailsLoading ||
                  current is CenterOrderDetailsInitial ||
                  current is CenterOrderDetailsLoaded ||
                  current is CenterOrderDetailsError,
              builder: (context, state) {
              if (state is CenterOrderDetailsLoading || state is CenterOrderDetailsInitial) {
                return _buildSkeletonLoader();
              }

              if (state is CenterOrderDetailsError) {
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
                          onPressed: () => _cubit.fetchOrderDetails(widget.orderId),
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

              if (state is CenterOrderDetailsLoaded) {
                return _buildContent(state.details);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    ),
  );
}

  Widget _buildContent(CenterOrderDetailsEntity details) {
    final order = details.order;
    final financial = details.financialView;
    final statusData = _getStatusBadgeData(order.status);

    return RefreshIndicator(
      onRefresh: () => _cubit.fetchOrderDetails(widget.orderId),
      color: const Color(0xFFFFC107),
      backgroundColor: const Color(0xFF141414),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Order Number & Status Header ─────────────────────
            _buildCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رقم الطلب',
                          style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.orderNumber,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusData.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (statusData.showDot)
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              color: statusData.textColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          statusData.text,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusData.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Device Information ───────────────────────────────
            _buildSectionTitle('معلومات الجهاز', Icons.phone_iphone_outlined),
            const SizedBox(height: 8),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device images
                  if (order.device.images.isNotEmpty) ...[
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: order.device.images.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showImageDialog(context, order.device.images[index]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                order.device.images[index],
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.broken_image, color: Colors.white24, size: 40),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildInfoRow('النوع', _getDeviceTypeLabel(order.device.type)),
                  _buildInfoRow('الماركة', order.device.brand),
                  _buildInfoRow('الموديل', order.device.model),
                  _buildInfoRow('نوع المشكلة', _getProblemTypeLabel(order.device.problemType)),
                  const Divider(color: Colors.white10, height: 20),
                  Text(
                    'وصف المشكلة',
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      order.device.problemDescription.isNotEmpty
                          ? order.device.problemDescription
                          : 'لا يوجد وصف',
                      style: GoogleFonts.cairo(fontSize: 14, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Client Info ──────────────────────────────────────
            if (order.client != null) ...[
              _buildSectionTitle('معلومات العميل', Icons.person_outline),
              const SizedBox(height: 8),
              _buildCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Color(0xFFFFC107), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.client!.name,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (order.client!.phone.isNotEmpty)
                                Text(
                                  order.client!.phone,
                                  style: GoogleFonts.cairo(fontSize: 13, color: Colors.white54),
                                ),
                            ],
                          ),
                        ),
                        if (order.client!.phone.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.phone_enabled_outlined, color: Color(0xFFFFC107)),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107).withValues(alpha: 0.1),
                            ),
                            onPressed: () => _makeCall(order.client!.phone),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ─── Delegate Info ────────────────────────────────────
            _buildDelegateSection(order),

            // ─── Pickup Address ───────────────────────────────────
            _buildSectionTitle('عنوان الاستلام', Icons.location_on_outlined),
            const SizedBox(height: 8),
            _buildCard(
              child: Column(
                children: [
                  _buildInfoRow('العنوان', order.pickupAddress.address),
                  _buildInfoRow('المدينة', order.pickupAddress.city),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Fees & Financial View ────────────────────────────
            _buildSectionTitle('المعلومات المالية', Icons.account_balance_wallet_outlined),
            const SizedBox(height: 8),
            _buildCard(
              child: Column(
                children: [
                  _buildFinancialRow(
                    'مستحق مركز الصيانة',
                    '${(financial.repairIncome > 0 ? financial.repairIncome : (order.financialSnapshot?.centerAmount ?? order.fees.repair)).toInt()} ${financial.currency}',
                    isHighlighted: true,
                    highlightColor: Colors.greenAccent,
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  _buildFinancialRow(
                    'حالة الدفع',
                    _getPaymentStatusLabel(financial.paymentStatus),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Submit Inspection Action ─────────────────────────
            if (_canSubmitInspection(order.status)) ...[  
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      Routes.submitInspectionRoute,
                      arguments: widget.orderId,
                    );
                    if (result == true) {
                      _cubit.fetchOrderDetails(widget.orderId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.assignment_add),
                  label: Text(
                    'تسجيل نتيجة الفحص',
                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ─── Submit Price Offer Action ────────────────────────
            if (_canSubmitPriceOffer(order.status)) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      Routes.submitPriceOfferRoute,
                      arguments: widget.orderId,
                    );
                    if (result == true) {
                      _cubit.fetchOrderDetails(widget.orderId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.local_offer_outlined),
                  label: Text(
                    'تقديم عرض سعر صيانة',
                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ─── Start Repair Action ──────────────────────────────
            if (_canStartRepair(order.status)) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _cubit.updateOrderStatus(
                      orderId: widget.orderId,
                      status: 'repairing',
                      note: 'بدأت عملية الإصلاح',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.build_outlined),
                  label: Text(
                    'بدء الإصلاح',
                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ─── Mark As Repaired Action ──────────────────────────
            if (_canMarkAsRepaired(order.status)) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.greenAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'برجاء الضغط عند الانتهاء من التصليح لمعرفة المناديب واستلام الجهاز وتسجيل الاوردر للسنتر لاحتساب الارباح بعد انتهاء التصليح.\n\n⚠️ تنبيه هام: إذا قمت بتأكيد الإصلاح قبل الانتهاء الفعلي وجاء المندوب للمركز، سيتم خصم تكلفة المندوب من أرباح السنتر.',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _cubit.updateOrderStatus(
                      orderId: widget.orderId,
                      status: 'repaired',
                      note: 'تم الانتهاء من عملية الإصلاح',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    'تم الإصلاح',
                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.white54),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, {bool isHighlighted = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: isHighlighted ? Colors.white : Colors.white54,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: isHighlighted ? 16 : 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: isHighlighted ? (highlightColor ?? const Color(0xFFFFC107)) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              color: const Color(0xFF141414),
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.white24, size: 60),
              ),
            ),
          ),
        ),
      ),
    );
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
            Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 16),
            Container(height: 20, width: 150, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 16),
            Container(height: 20, width: 120, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 16),
            Container(height: 20, width: 130, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 16),
            Container(height: 20, width: 140, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 160, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────

  bool _canSubmitInspection(String status) {
    final allowedStatuses = [
      'picked_up',
      'at_center',
      'inspecting',
    ];
    return allowedStatuses.contains(status.toLowerCase());
  }

  bool _canSubmitPriceOffer(String status) {
    final allowedStatuses = [
      'inspecting',
      'at_center',
    ];
    return allowedStatuses.contains(status.toLowerCase());
  }

  bool _canStartRepair(String status) {
    return status.toLowerCase() == 'approved';
  }

  bool _canMarkAsRepaired(String status) {
    return status.toLowerCase() == 'repairing' || status.toLowerCase() == 'ongoing';
  }


  String _getDeviceTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'phone':
        return 'هاتف';
      case 'tablet':
        return 'تابلت';
      case 'laptop':
        return 'لابتوب';
      default:
        return type;
    }
  }

  String _getProblemTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'screen':
        return 'شاشة';
      case 'battery':
        return 'بطارية';
      case 'software':
        return 'برمجيات';
      case 'hardware':
        return 'هاردوير';
      case 'other':
        return 'أخرى';
      default:
        return type;
    }
  }

  String _getPaymentStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'مدفوع ✅';
      case 'unpaid':
        return 'غير مدفوع';
      case 'partial':
        return 'دفع جزئي';
      default:
        return status;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'awaiting_approval':
        return 'بانتظار الموافقة';
      case 'delegate_assigned':
      case 'assigned':
        return 'تم تعيين المندوب';
      case 'picking_up':
        return 'جاري الاستلام';
      case 'picked_up':
        return 'تم الاستلام';
      case 'at_center':
        return 'في المركز';
      case 'inspecting':
        return 'جاري الفحص';
      case 'approved':
        return 'تم الموافقة';
      case 'rejected':
        return 'مرفوض';
      case 'ongoing':
      case 'repairing':
        return 'جاري الإصلاح';
      case 'repaired':
        return 'تم الإصلاح';
      case 'in_transit':
      case 'delivering':
      case 'returning':
        return 'في الطريق';
      case 'delivered':
        return 'تم التوصيل';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  String _formatDateTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final amPm = date.hour >= 12 ? 'م' : 'ص';
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.day} ${months[date.month - 1]} ${date.year} - $hour:$minute $amPm';
    } catch (e) {
      return '';
    }
  }

  _StatusBadgeData _getStatusBadgeData(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusBadgeData(text: 'قيد الانتظار', backgroundColor: Colors.orange.withValues(alpha: 0.15), textColor: Colors.orangeAccent, showDot: true);
      case 'awaiting_approval':
        return _StatusBadgeData(text: 'بانتظار الموافقة', backgroundColor: Colors.cyan.withValues(alpha: 0.15), textColor: Colors.cyanAccent, showDot: false);
      case 'delegate_assigned':
      case 'assigned':
        return _StatusBadgeData(text: 'تم تعيين المندوب', backgroundColor: Colors.blue.withValues(alpha: 0.15), textColor: Colors.blueAccent, showDot: false);
      case 'picking_up':
        return _StatusBadgeData(text: 'جاري الاستلام', backgroundColor: Colors.purple.withValues(alpha: 0.15), textColor: Colors.purpleAccent, showDot: true);
      case 'picked_up':
        return _StatusBadgeData(text: 'تم الاستلام', backgroundColor: Colors.teal.withValues(alpha: 0.15), textColor: Colors.tealAccent, showDot: false);
      case 'at_center':
        return _StatusBadgeData(text: 'في المركز', backgroundColor: Colors.teal.withValues(alpha: 0.15), textColor: Colors.tealAccent, showDot: false);
      case 'inspecting':
        return _StatusBadgeData(text: 'جاري الفحص', backgroundColor: Colors.orange.withValues(alpha: 0.15), textColor: Colors.orangeAccent, showDot: true);
      case 'approved':
        return _StatusBadgeData(text: 'تم الموافقة', backgroundColor: Colors.green.withValues(alpha: 0.15), textColor: Colors.greenAccent, showDot: false);
      case 'rejected':
        return _StatusBadgeData(text: 'مرفوض', backgroundColor: Colors.red.withValues(alpha: 0.15), textColor: Colors.redAccent, showDot: false);
      case 'ongoing':
      case 'repairing':
        return _StatusBadgeData(text: 'جاري الإصلاح', backgroundColor: Colors.amber.withValues(alpha: 0.15), textColor: const Color(0xFFFFC107), showDot: true);
      case 'repaired':
        return _StatusBadgeData(text: 'تم الإصلاح', backgroundColor: Colors.lightGreen.withValues(alpha: 0.15), textColor: Colors.lightGreenAccent, showDot: false);
      case 'in_transit':
      case 'delivering':
      case 'returning':
        return _StatusBadgeData(text: 'في الطريق', backgroundColor: Colors.indigo.withValues(alpha: 0.15), textColor: Colors.indigoAccent, showDot: true);
      case 'delivered':
      case 'completed':
        return _StatusBadgeData(text: 'مكتمل', backgroundColor: Colors.green.withValues(alpha: 0.15), textColor: Colors.greenAccent, showDot: false);
      case 'cancelled':
        return _StatusBadgeData(text: 'ملغي', backgroundColor: Colors.red.withValues(alpha: 0.15), textColor: Colors.redAccent, showDot: false);
      default:
        return _StatusBadgeData(text: 'حالة غير معروفة', backgroundColor: Colors.grey.withValues(alpha: 0.15), textColor: Colors.white54, showDot: true);
    }
  }

  Widget _buildDelegateSection(OrderEntity order) {
    final pickupDel = order.pickupDelegate ?? order.delegate;
    final deliveryDel = order.deliveryDelegate;

    final hasPickup = pickupDel != null && pickupDel.name.isNotEmpty;
    final hasDelivery = deliveryDel != null && deliveryDel.name.isNotEmpty;

    if (!hasPickup && !hasDelivery) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('معلومات المندوب', Icons.two_wheeler_outlined),
        const SizedBox(height: 8),
        _buildCard(
          child: Column(
            children: [
              if (hasPickup) ...[
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.two_wheeler, color: Colors.greenAccent, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'استلم من العميل وسلّم للمركز',
                            style: GoogleFonts.cairo(fontSize: 11, color: Colors.white54),
                          ),
                          Text(
                            pickupDel.name,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (pickupDel.phone.isNotEmpty)
                            Text(
                              pickupDel.phone,
                              style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
                            ),
                        ],
                      ),
                    ),
                    if (pickupDel.phone.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.phone_enabled_outlined, color: Colors.greenAccent),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.greenAccent.withValues(alpha: 0.1),
                        ),
                        onPressed: () => _makeCall(pickupDel.phone),
                      ),
                  ],
                ),
              ],
              if (hasPickup && hasDelivery)
                const Divider(color: Colors.white10, height: 20),
              if (hasDelivery) ...[
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_shipping_outlined, color: Color(0xFFFFC107), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'استلم من المركز وسلّم للعميل',
                            style: GoogleFonts.cairo(fontSize: 11, color: Colors.white54),
                          ),
                          Text(
                            deliveryDel.name,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (deliveryDel.phone.isNotEmpty)
                            Text(
                              deliveryDel.phone,
                              style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
                            ),
                        ],
                      ),
                    ),
                    if (deliveryDel.phone.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.phone_enabled_outlined, color: Color(0xFFFFC107)),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107).withValues(alpha: 0.1),
                        ),
                        onPressed: () => _makeCall(deliveryDel.phone),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _StatusBadgeData {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final bool showDot;

  _StatusBadgeData({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.showDot,
  });
}
