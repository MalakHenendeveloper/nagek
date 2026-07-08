import 'package:flutter/material.dart';
import 'package:flutter_application_nagek/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../domain/entities/inspection_entity.dart';
import '../../domain/entities/price_offer_entity.dart';
import '../cubit/order_tracking_cubit.dart';
import '../cubit/order_tracking_state.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late OrderTrackingCubit _cubit;
  bool _isStepperExpanded = false;

  // The 13 status stages in order
  final List<String> _stages = [
    'pending',
    'delegate_assigned',
    'picked_up',
    'at_center',
    'inspecting',
    'awaiting_approval',
    'approved',
    'repairing',
    'repaired',
    'returning',
    'delivered'
  ];

  @override
  void initState() {
    super.initState();
    _cubit = getIt<OrderTrackingCubit>()..fetchOrderTracking(widget.orderId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  String _getStageTitle(String status) {
    switch (status) {
      case 'pending':
        return 'تم إنشاء الطلب';
      case 'delegate_assigned':
        return 'تم تعيين مندوب الاستلام';
      case 'picked_up':
        return 'تم استلام الجهاز';
      case 'at_center':
        return 'وصل للجهاز للمركز';
      case 'inspecting':
        return 'جاري الفحص';
      case 'awaiting_approval':
        return 'بانتظار موافقتك على التكلفة';
      case 'approved':
        return 'تمت الموافقة من قبلك';
      case 'rejected':
        return 'تم الرفض من قبلك';
      case 'repairing':
        return 'جاري الإصلاح';
      case 'repaired':
        return 'تم الإصلاح بنجاح';
      case 'returning':
        return 'جاري تسليم الجهاز إليك';
      case 'delivered':
        return 'تم التسليم بنجاح';
      case 'cancelled':
        return 'تم إلغاء الطلب';
      default:
        return 'حالة غير معروفة';
    }
  }

  String _formatDateTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      final isPm = date.hour >= 12;
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = isPm ? 'م' : 'ص';
      return '${date.day} ${months[date.month - 1]}، $hour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.black, // Dark background as in request mockup
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'تتبع الطلب',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
            builder: (context, state) {
              if (state is OrderTrackingLoading || state is OrderTrackingInitial) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFC107),
                  ),
                );
              } else if (state is OrderTrackingError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.cairo(color: Colors.red),
                  ),
                );
              } else if (state is OrderTrackingLoaded) {
                final order = state.order;
                final tracking = state.tracking;
                final inspection = state.inspection;
                final priceOffer = state.priceOffer;

                // Adjust stages if order is rejected or cancelled
                List<String> activeStages = List.from(_stages);
                if (tracking.status == 'rejected' || order.status == 'rejected') {
                  activeStages.remove('approved');
                  activeStages.insert(activeStages.indexOf('awaiting_approval') + 1, 'rejected');
                }
                if (tracking.status == 'cancelled' || order.status == 'cancelled') {
                  activeStages.add('cancelled');
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Yellow Top Badge Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${order.device.brand} ${order.device.model}',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  'رقم الطلب',
                                  style: GoogleFonts.cairo(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '#${order.orderNumber.split('-').last}',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.build_circle_outlined, color: Colors.black),
                                const SizedBox(width: 8),
                                Text(
                                  'الحالة الحالية: ${_getStageTitle(tracking.status)}',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      // Detailed Order Information Card
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تفاصيل الطلب والجهاز',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFFFFC107),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('نوع الجهاز:', order.device.type),
                            _buildInfoRow('الماركة والموديل:', '${order.device.brand} ${order.device.model}'),
                            _buildInfoRow('نوع المشكلة:', order.device.problemType),
                            _buildInfoRow('وصف المشكلة:', order.device.problemDescription.isNotEmpty ? order.device.problemDescription : 'لا يوجد وصف'),
                            const Divider(color: Colors.white12, height: 24),
                            
                            Text(
                              'عنوان الاستلام والتوصيل',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFFFFC107),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow('المدينة:', order.pickupAddress.city),
                            _buildInfoRow('العنوان:', order.pickupAddress.address),
                            const Divider(color: Colors.white12, height: 24),

                            Text(
                              'مركز الصيانة المتعاقد',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFFFFC107),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow('اسم المركز:', order.repairCenter.name),
                            _buildInfoRow('عنوان المركز:', order.repairCenter.address),
                            _buildInfoRow('رقم الهاتف:', order.repairCenter.phone),
                            const Divider(color: Colors.white12, height: 24),

                            Text(
                              'حالة الأمان ورمز التحقق (OTP)',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFFFFC107),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow('رمز الاستلام (Pickup OTP):', order.pickupOTPVerified ? 'تم التحقق ✔' : 'بانتظار التحقق ⏳'),
                            _buildInfoRow('رمز التسليم (Delivery OTP):', order.deliveryOTPVerified ? 'تم التحقق ✔' : 'بانتظار التحقق ⏳'),

                            if (order.clientApprovalStatus != null) ...[
                              const Divider(color: Colors.white12, height: 24),
                              Text(
                                'اعتماد العميل للطلب',
                                style: GoogleFonts.cairo(
                                  color: const Color(0xFFFFC107),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'حالة الاعتماد:', 
                                order.clientApprovalStatus == 'approved' 
                                    ? 'تمت الموافقة من قبلك' 
                                    : (order.clientApprovalStatus == 'rejected' ? 'تم الرفض' : 'قيد الانتظار')
                              ),
                              if (order.clientApprovalTimestamp != null)
                                _buildInfoRow('تاريخ الاعتماد:', _formatDateTime(order.clientApprovalTimestamp!)),
                            ],
                          ],
                        ),
                      ),

                      // Fees & Payment Status Section
                      const SizedBox(height: 16),
                      priceOffer != null
                          ? _buildPriceOfferCard(priceOffer, order.paymentStatus)
                          : _buildStandardFeesCard(order),

                      // Inspection Report Card (only if inspection exists)
                      if (inspection != null) ...[
                        const SizedBox(height: 16),
                        _buildInspectionCard(inspection),
                      ],

                      const SizedBox(height: 32),

                      // Stepper Header with Show More/Less toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'مراحل التتبع',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (activeStages.length > 4)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isStepperExpanded = !_isStepperExpanded;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isStepperExpanded ? Icons.expand_less : Icons.expand_more,
                                      color: const Color(0xFFFFC107),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isStepperExpanded ? 'عرض أقل' : 'عرض الكل',
                                      style: GoogleFonts.cairo(
                                        color: const Color(0xFFFFC107),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stepper List (collapsible)
                      ...(() {
                        // Determine which stages to show
                        List<int> visibleIndices;
                        if (_isStepperExpanded || activeStages.length <= 4) {
                          visibleIndices = List.generate(activeStages.length, (i) => i);
                        } else {
                          // Find the current active stage index
                          int currentActiveIdx = activeStages.indexWhere(
                            (s) => s.toLowerCase() == tracking.status.toLowerCase(),
                          );
                          if (currentActiveIdx == -1) currentActiveIdx = 0;

                          // Show: first stage, current-1, current, current+1 (unique, sorted)
                          final Set<int> indices = {0};
                          if (currentActiveIdx > 0) indices.add(currentActiveIdx - 1);
                          indices.add(currentActiveIdx);
                          if (currentActiveIdx + 1 < activeStages.length) indices.add(currentActiveIdx + 1);
                          visibleIndices = indices.toList()..sort();
                        }

                        return List.generate(visibleIndices.length, (vi) {
                          final index = visibleIndices[vi];
                          final stage = activeStages[index];
                          final isAwaitingApproval = stage == 'awaiting_approval';
                          final isLastVisible = vi == visibleIndices.length - 1;

                          // Check if there's a gap between this and next visible index
                          final bool hasGapAfter = !isLastVisible && visibleIndices[vi + 1] != index + 1;

                          // Find status update in history
                          final historyIndex = tracking.statusHistory.indexWhere(
                              (element) => element.status.toLowerCase() == stage.toLowerCase());
                          final hasCompleted = historyIndex != -1;

                          // Check if it's the current active stage
                          final isActive = tracking.status.toLowerCase() == stage.toLowerCase();

                          String timestamp = '';
                          if (hasCompleted) {
                            timestamp = _formatDateTime(tracking.statusHistory[historyIndex].timestamp);
                          }

                          // Stepper color configurations
                          Color stepColor = Colors.grey[800]!;
                          if (hasCompleted || isActive) {
                            stepColor = const Color(0xFFFFC107);
                          }

                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Indicator line and dot column
                                  Column(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isActive
                                              ? const Color(0xFFFFC107)
                                              : (hasCompleted ? const Color(0xFFFFC107) : Colors.transparent),
                                          border: Border.all(
                                            color: stepColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: hasCompleted
                                              ? const Icon(Icons.check, size: 14, color: Colors.black)
                                              : (isActive
                                                  ? Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.black,
                                                      ),
                                                    )
                                                  : null),
                                        ),
                                      ),
                                      if (!isLastVisible)
                                        Container(
                                          width: 2,
                                          height: isAwaitingApproval && isActive ? 120 : 50,
                                          color: hasCompleted ? const Color(0xFFFFC107) : Colors.grey[800],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),

                                  // Content Details column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getStageTitle(stage),
                                          style: GoogleFonts.cairo(
                                            color: hasCompleted || isActive ? Colors.white : Colors.grey[600],
                                            fontWeight: hasCompleted || isActive ? FontWeight.bold : FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (hasCompleted && timestamp.isNotEmpty)
                                          Text(
                                            timestamp,
                                            style: GoogleFonts.cairo(
                                              color: Colors.grey[500],
                                              fontSize: 11,
                                            ),
                                          ),

                                        // Special Awaiting Approval Block (If active)
                                        if (isAwaitingApproval && isActive) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[900],
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: const Color(0xFFFFC107), width: 1),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Text(
                                                  'يرجى مراجعة تكلفة وطلب الصيانة بالتفصيل للموافقة للبدء بالإصلاح:',
                                                  style: GoogleFonts.cairo(
                                                    color: Colors.white70,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                if (priceOffer != null) ...[
                                                  if (priceOffer.spareParts.isNotEmpty) ...[
                                                    Text(
                                                      'قطع الغيار:',
                                                      style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                                                    ),
                                                    ...priceOffer.spareParts.map((part) =>
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text('• ${part.name}', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11)),
                                                          Text('${part.cost.toInt()} ر.س', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11)),
                                                        ],
                                                      )
                                                    ),
                                                    const Divider(color: Colors.white12),
                                                  ],
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('أجور اليد:', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11)),
                                                      Text('${priceOffer.laborCost.toInt()} ر.س', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11)),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('رسوم الفحص:', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11)),
                                                      Text('${priceOffer.inspectionFee.toInt()} ر.س', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11)),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('رسوم التوصيل:', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11)),
                                                      Text('${priceOffer.deliveryFee.toInt()} ر.س', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11)),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('المدة المتوقعة:', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11)),
                                                      Text('${priceOffer.estimatedDays} أيام', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11)),
                                                    ],
                                                  ),
                                                  const Divider(color: Colors.white12),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('الإجمالي:', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                                      Text('${priceOffer.totalCost.toInt()} ر.س', style: GoogleFonts.cairo(color: const Color(0xFFFFC107), fontWeight: FontWeight.bold, fontSize: 13)),
                                                    ],
                                                  ),
                                                ] else ...[
                                                  // Fallback to order fees
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('رسوم الفحص:', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11)),
                                                      Text('${order.fees.inspection.toInt()} ر.س', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11)),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('تكلفة التوصيل:', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11)),
                                                      Text('${order.fees.delivery.toInt()} ر.س', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11)),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('تكلفة الإصلاح المقدرة:', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11)),
                                                      Text('${order.fees.repair.toInt()} ر.س', style: GoogleFonts.cairo(color: const Color(0xFFFFC107), fontSize: 11)),
                                                    ],
                                                  ),
                                                  const Divider(color: Colors.white12),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('الإجمالي المالي:', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                                      Text('${order.fees.total.toInt()} ر.س', style: GoogleFonts.cairo(color: const Color(0xFFFFC107), fontWeight: FontWeight.bold, fontSize: 13)),
                                                    ],
                                                  ),
                                                ],
                                                const SizedBox(height: 16),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: state.isApproving
                                                            ? null
                                                            : () async {
                                                                final success = await context.read<OrderTrackingCubit>().approvePriceOffer(order.id);
                                                                if (context.mounted) {
                                                                  if (success) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                      const SnackBar(
                                                                        content: Text('تمت الموافقة على عرض السعر بنجاح، سيبدأ الإصلاح قريباً'),
                                                                        backgroundColor: Colors.green,
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                      const SnackBar(
                                                                        content: Text('حدث خطأ أثناء الموافقة، يرجى المحاولة لاحقاً'),
                                                                        backgroundColor: Colors.red,
                                                                      ),
                                                                    );
                                                                  }
                                                                }
                                                              },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: const Color(0xFFFFC107),
                                                          foregroundColor: Colors.black,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                                        ),
                                                        child: state.isApproving
                                                            ? const SizedBox(
                                                                width: 16,
                                                                height: 16,
                                                                child: CircularProgressIndicator(
                                                                  color: Colors.black,
                                                                  strokeWidth: 2,
                                                                ),
                                                              )
                                                            : Text(
                                                                'موافقة',
                                                                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
                                                              ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: OutlinedButton(
                                                        onPressed: state.isApproving
                                                            ? null
                                                            : () {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text('يرجى التواصل مع الدعم الفني لتعديل أو رفض العرض'),
                                                                  ),
                                                                );
                                                              },
                                                        style: OutlinedButton.styleFrom(
                                                          side: const BorderSide(color: Colors.red),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                                        ),
                                                        child: Text(
                                                          'رفض',
                                                          style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Show dots for gap between visible stages
                              if (hasGapAfter)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Row(
                                    children: [
                                      Column(
                                        children: List.generate(3, (_) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 3),
                                          child: Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        });
                      })(),

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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionCard(InspectionEntity inspection) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fact_check_outlined,
                color: Color(0xFFFFC107),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'تقرير الفحص الفني',
                style: GoogleFonts.cairo(
                  color: const Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 24),
          _buildInfoRow('الفني المسؤول:', inspection.technician.isNotEmpty ? inspection.technician : 'غير محدد'),
          if (inspection.inspectedAt.isNotEmpty)
            _buildInfoRow('تاريخ الفحص:', _formatDateTime(inspection.inspectedAt)),
          const Divider(color: Colors.white12, height: 24),
          Text(
            'المشاكل المكتشفة:',
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          if (inspection.findings.isEmpty)
            Text(
              'لم يتم تسجيل أي مشاكل.',
              style: GoogleFonts.cairo(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            )
          else
            ...inspection.findings.map((finding) {
              final severityColor = _getSeverityColor(finding.severity);
              final severityIcon = _getSeverityIcon(finding.severity);
              final severityText = _getSeverityText(finding.severity);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      severityIcon,
                      color: severityColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            finding.issue,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: severityColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: severityColor.withValues(alpha: 0.3), width: 0.5),
                            ),
                            child: Text(
                              severityText,
                              style: GoogleFonts.cairo(
                                color: severityColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          if (inspection.notes.isNotEmpty) ...[
            const Divider(color: Colors.white12, height: 24),
            Text(
              'ملاحظات الفني:',
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                inspection.notes,
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          if (inspection.images.isNotEmpty) ...[
            const Divider(color: Colors.white12, height: 24),
            Text(
              'صور الفحص:',
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: inspection.images.map((imageUrl) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    InteractiveViewer(
                                      child: Image.network(
                                        imageUrl,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.grey[800],
                                          width: double.infinity,
                                          height: 300,
                                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[800],
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[800],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getSeverityText(String severity) {
    switch (severity.toLowerCase()) {
      case 'major':
        return 'عالية الخطورة';
      case 'moderate':
        return 'متوسطة الخطورة';
      case 'minor':
        return 'بسيطة';
      default:
        return severity;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'major':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      case 'minor':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'major':
        return Icons.error_outline;
      case 'moderate':
        return Icons.warning_amber_outlined;
      case 'minor':
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildPriceOfferCard(PriceOfferEntity priceOffer, String paymentStatus) {
    final isPaid = paymentStatus.toLowerCase() == 'paid';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
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
                'عرض السعر المقدم وتفاصيل التكلفة',
                style: GoogleFonts.cairo(
                  color: const Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withValues(alpha: 0.2)
                      : const Color(0xFFFFC107).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPaid ? Colors.green : const Color(0xFFFFC107),
                    width: 1,
                  ),
                ),
                child: Text(
                  isPaid ? 'تم الدفع' : 'غير مدفوع',
                  style: GoogleFonts.cairo(
                    color: isPaid ? Colors.green : const Color(0xFFFFC107),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 24),
          if (priceOffer.spareParts.isNotEmpty) ...[
            Text(
              'قطع الغيار المطلوبة:',
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            ...priceOffer.spareParts.map((part) =>
              _buildInfoRow('• ${part.name}:', '${part.cost.toInt()} ر.س')
            ),
            const Divider(color: Colors.white12, height: 20),
          ],
          _buildInfoRow('أجور الإصلاح (اليد):', '${priceOffer.laborCost.toInt()} ر.س'),
          _buildInfoRow('رسوم الفحص:', '${priceOffer.inspectionFee.toInt()} ر.س'),
          _buildInfoRow('رسوم التوصيل:', '${priceOffer.deliveryFee.toInt()} ر.س'),
          _buildInfoRow('مدة العمل المتوقعة:', '${priceOffer.estimatedDays} أيام'),
          if (priceOffer.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildInfoRow('ملاحظات المركز:', priceOffer.notes),
          ],
          const Divider(color: Colors.white12, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي الكلي:',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${priceOffer.totalCost.toInt()} ر.س',
                style: GoogleFonts.cairo(
                  color: const Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStandardFeesCard(OrderEntity order) {
    final isPaid = order.paymentStatus.toLowerCase() == 'paid';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
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
                'الملخص المالي وحالة الدفع',
                style: GoogleFonts.cairo(
                  color: const Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withValues(alpha: 0.2)
                      : const Color(0xFFFFC107).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPaid ? Colors.green : const Color(0xFFFFC107),
                    width: 1,
                  ),
                ),
                child: Text(
                  isPaid ? 'تم الدفع' : 'غير مدفوع',
                  style: GoogleFonts.cairo(
                    color: isPaid ? Colors.green : const Color(0xFFFFC107),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 24),
          _buildInfoRow('رسوم الفحص:', '${order.fees.inspection.toInt()} ر.س'),
          _buildInfoRow('تكلفة التوصيل:', '${order.fees.delivery.toInt()} ر.س'),
          _buildInfoRow('تكلفة الإصلاح المقدرة:', '${order.fees.repair.toInt()} ر.س'),
          const Divider(color: Colors.white12, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي المالي:',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${order.fees.total.toInt()} ر.س',
                style: GoogleFonts.cairo(
                  color: const Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
