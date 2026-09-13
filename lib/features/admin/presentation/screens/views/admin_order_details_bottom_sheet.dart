import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/di/di.dart';
import '../../cubit/admin_order_details_cubit.dart';
import '../../cubit/admin_order_details_state.dart';
import '../../../../orders/domain/entities/order_entity.dart';

class AdminOrderDetailsBottomSheet extends StatelessWidget {
  final String orderId;

  const AdminOrderDetailsBottomSheet({super.key, required this.orderId});

  static Future<void> show(BuildContext context, String orderId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminOrderDetailsBottomSheet(orderId: orderId),
    );
  }

  static const Map<String, String> _statusLabels = {
    'pending': 'بانتظار المعالجة',
    'accepted': 'تم القبول',
    'assigned': 'تم التعيين',
    'picking_up': 'جاري الاستلام',
    'picked_up': 'تم الاستلام',
    'at_center': 'في المركز',
    'inspecting': 'جاري الفحص',
    'awaiting_approval': 'بانتظار الموافقة',
    'approved': 'تم الموافقة',
    'repairing': 'جاري الإصلاح',
    'repaired': 'تم الإصلاح',
    'returning': 'جاري التوصيل',
    'delivering': 'جاري التوصيل',
    'delivered': 'تم التوصيل',
    'completed': 'مكتمل',
    'cancelled': 'ملغي',
    'rejected': 'مرفوض',
    'delegate_assigned': 'تم تعيين المندوب',
  };

  static const Map<String, Color> _statusColors = {
    'pending': Color(0xFFFFC107),
    'accepted': Color(0xFF2196F3),
    'assigned': Color(0xFF2196F3),
    'picking_up': Color(0xFF9C27B0),
    'picked_up': Color(0xFF9C27B0),
    'at_center': Color(0xFF00BCD4),
    'inspecting': Color(0xFFFF9800),
    'awaiting_approval': Color(0xFFFFC107),
    'approved': Color(0xFF4CAF50),
    'repairing': Color(0xFFFF5722),
    'repaired': Color(0xFF8BC34A),
    'returning': Color(0xFF3F51B5),
    'delivering': Color(0xFF3F51B5),
    'delivered': Color(0xFF4CAF50),
    'completed': Color(0xFF4CAF50),
    'cancelled': Colors.redAccent,
    'rejected': Colors.redAccent,
    'delegate_assigned': Color(0xFF4CAF50),
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminOrderDetailsCubit>(
      create: (context) =>
          getIt<AdminOrderDetailsCubit>()..fetchOrderDetails(orderId),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F0F),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(top: BorderSide(color: Colors.white10, width: 1.5)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 50,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تفاصيل الطلب الكاملة',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Expanded(
              child:
                  BlocBuilder<AdminOrderDetailsCubit, AdminOrderDetailsState>(
                    builder: (context, state) {
                      if (state is AdminOrderDetailsLoading ||
                          state is AdminOrderDetailsInitial) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFC107),
                          ),
                        );
                      } else if (state is AdminOrderDetailsError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.redAccent,
                                  size: 50,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  state.message,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC107),
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<AdminOrderDetailsCubit>()
                                        .fetchOrderDetails(orderId);
                                  },
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: Text(
                                    'إعادة المحاولة',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (state is AdminOrderDetailsLoaded) {
                        return _buildOrderDetailsContent(state.order);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsContent(OrderEntity order) {
    final statusColor = _statusColors[order.status] ?? Colors.grey;
    final statusLabel = _statusLabels[order.status] ?? 'حالة غير معروفة';

    final createdDate = DateTime.tryParse(order.createdAt);
    final dateStr = createdDate != null
        ? '${createdDate.toLocal().day}/${createdDate.toLocal().month}/${createdDate.toLocal().year} - ${createdDate.toLocal().hour}:${createdDate.toLocal().minute.toString().padLeft(2, '0')}'
        : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'رقم الطلب:',
                      style: GoogleFonts.cairo(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.cairo(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  order.orderNumber,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      color: Colors.white30,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'تاريخ الإنشاء: $dateStr',
                      style: GoogleFonts.cairo(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.payment_outlined,
                      color: Colors.white30,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'حالة الدفع: ',
                      style: GoogleFonts.cairo(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      (order.paymentStatus.toLowerCase() == 'paid' ||
                              order.paymentStatus.toLowerCase() == 'confirmed' ||
                              order.paymentStatus.toLowerCase() == 'approved' ||
                              order.paymentStatus.toLowerCase() == 'completed')
                          ? 'مدفوع'
                          : (order.paymentStatus.toLowerCase() == 'pending'
                              ? 'قيد التعديل / الدفع'
                              : 'غير مدفوع'),
                      style: GoogleFonts.cairo(
                        color: (order.paymentStatus.toLowerCase() == 'paid' ||
                                order.paymentStatus.toLowerCase() == 'confirmed' ||
                                order.paymentStatus.toLowerCase() == 'approved' ||
                                order.paymentStatus.toLowerCase() == 'completed')
                            ? const Color(0xFF4CAF50)
                            : (order.paymentStatus.toLowerCase() == 'pending'
                                ? const Color(0xFFFFC107)
                                : Colors.redAccent),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Client Details Section
          if (order.client != null) ...[
            _buildSectionTitle('بيانات العميل (صاحب الطلب)'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildDetailItem(
                    Icons.person_outline,
                    'اسم العميل',
                    order.client!.name.isNotEmpty
                        ? order.client!.name
                        : 'غير محدد',
                  ),
                  const SizedBox(height: 10),
                  _buildDetailItem(
                    Icons.phone_android,
                    'هاتف العميل',
                    order.client!.phone.isNotEmpty
                        ? order.client!.phone
                        : 'غير محدد',
                  ),
                  if (order.client!.email.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildDetailItem(
                      Icons.email_outlined,
                      'البريد الإلكتروني',
                      order.client!.email,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Device Details Section
          _buildSectionTitle('بيانات الجهاز المشخص'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(
                  Icons.devices,
                  'نوع وموديل الجهاز',
                  '${order.device.brand} ${order.device.model}',
                ),
                const SizedBox(height: 10),
                _buildDetailItem(
                  Icons.build_outlined,
                  'نوع المشكلة',
                  _getProblemTypeLabel(order.device.problemType),
                ),
                if (order.device.problemDescription.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildDetailItem(
                    Icons.description_outlined,
                    'وصف المشكلة من العميل',
                    order.device.problemDescription,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Address Details Section
          _buildSectionTitle('عنوان الاستلام والتسليم'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                _buildDetailItem(
                  Icons.location_city_outlined,
                  'المدينة',
                  order.pickupAddress.city,
                ),
                const SizedBox(height: 10),
                _buildDetailItem(
                  Icons.location_on_outlined,
                  'العنوان التفصيلي',
                  order.pickupAddress.address,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Repair Center Section
          _buildSectionTitle('مركز الصيانة الموكل'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: order.repairCenter.name.isNotEmpty
                ? Column(
                    children: [
                      _buildDetailItem(
                        Icons.business_outlined,
                        'اسم المركز',
                        order.repairCenter.name,
                      ),
                      const SizedBox(height: 10),
                      _buildDetailItem(
                        Icons.phone_android,
                        'هاتف المركز',
                        order.repairCenter.phone,
                      ),
                      if (order.repairCenter.address.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildDetailItem(
                          Icons.location_on_outlined,
                          'عنوان المركز',
                          order.repairCenter.address,
                        ),
                      ],
                    ],
                  )
                : Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white38,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'لم يتم تحديد مركز صيانة لهذا الطلب بعد',
                        style: GoogleFonts.cairo(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 20),

          // Fees Section
          _buildSectionTitle('الرسوم وتوزيع التكاليف'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Builder(
              builder: (context) {
                // // Pickup delegate fee (client -> center)
                // final pickupFee = (order.financialSnapshot != null && order.financialSnapshot!.inspectionFee > 0)
                //     ? order.financialSnapshot!.inspectionFee
                //     : order.fees.inspection;

                // // Delivery delegate fee (center -> client)
                // final deliveryFee = (order.financialSnapshot != null && order.financialSnapshot!.deliveryFee > 0)
                //     ? order.financialSnapshot!.deliveryFee
                //     : order.fees.delivery;

                // // Center payout
                // final centerAmount = (order.financialSnapshot != null && order.financialSnapshot!.centerAmount > 0)
                //     ? order.financialSnapshot!.centerAmount
                //     : order.fees.repair;

                // Client total
                final clientTotal = (order.financialSnapshot != null && order.financialSnapshot!.clientTotal > 0)
                    ? order.financialSnapshot!.clientTotal
                    : (order.fees.total > 0
                        ? order.fees.total
                        : order.fees.repair + order.fees.delivery + order.fees.inspection);

                // // Admin commission = total - center - pickup - delivery
                // final adminCommission = clientTotal - centerAmount - pickupFee - deliveryFee;

                return Column(
                  children: [
                    // _buildFeeRow('أجر مندوب التوصيل (من المركز للعميل)', pickupFee),
                    // const SizedBox(height: 8),
                    // _buildFeeRow('أجر مندوب الاستلام (إلى المركز)', deliveryFee),
                    // const SizedBox(height: 8),
                    // _buildFeeRow('مستحق مركز الصيانة', centerAmount),
                    // const SizedBox(height: 8),
                    // _buildFeeRow('عمولة الإدارة', adminCommission),
                    // const Padding(
                    //   padding: EdgeInsets.symmetric(vertical: 10),
                    //   child: Divider(color: Colors.white10, height: 1),
                    // ),
                    _buildFeeRow(
                      'المجموع الكلي المطلوب من العميل',
                      clientTotal,
                      isTotal: true,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Status History Timeline Section
          _buildSectionTitle('جدول المتابعة والخط الزمني'),
          const SizedBox(height: 12),
          if (order.statusHistory.isEmpty)
            Text(
              'لا يوجد سجل متابعة للطلب',
              style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.statusHistory.length,
              itemBuilder: (context, index) {
                final history = order.statusHistory[index];
                return _buildTimelineStep(
                  history,
                  index == order.statusHistory.length - 1,
                );
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        color: const Color(0xFFFFC107),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 18),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: GoogleFonts.cairo(color: Colors.white38, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
            textDirection: label.contains('هاتف') || label.contains('البريد')
                ? TextDirection.ltr
                : null,
            textAlign: label.contains('هاتف') || label.contains('البريد')
                ? TextAlign.left
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFeeRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: isTotal ? Colors.white : Colors.white60,
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(0)} ر.س',
          style: GoogleFonts.cairo(
            color: isTotal ? const Color(0xFFFFC107) : Colors.white,
            fontSize: isTotal ? 15 : 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep(StatusHistoryEntity history, bool isLast) {
    final statusColor = _statusColors[history.status] ?? Colors.grey;
    final statusLabel = _statusLabels[history.status] ?? 'حالة غير معروفة';

    final parsedDate = DateTime.tryParse(history.timestamp);
    final dateStr = parsedDate != null
        ? '${parsedDate.toLocal().day}/${parsedDate.toLocal().month} - ${parsedDate.toLocal().hour}:${parsedDate.toLocal().minute.toString().padLeft(2, '0')}'
        : '';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: Colors.white10)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        statusLabel,
                        style: GoogleFonts.cairo(
                          color: statusColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: GoogleFonts.cairo(
                          color: Colors.white30,
                          fontSize: 11,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                  if (history.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      history.note,
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getProblemTypeLabel(String type) {
    switch (type) {
      case 'screen':
        return 'مشكلة في الشاشة';
      case 'battery':
        return 'مشكلة في البطارية';
      case 'software':
        return 'مشكلة برمجية';
      case 'charging':
        return 'مشكلة في الشحن';
      case 'camera':
        return 'مشكلة في الكاميرا';
      case 'speaker':
        return 'مشكلة في السماعة';
      case 'water_damage':
        return 'ضرر مياه';
      default:
        return type.isNotEmpty ? type : 'أخرى';
    }
  }
}
