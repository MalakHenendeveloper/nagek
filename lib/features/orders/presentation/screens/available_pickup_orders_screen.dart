import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/di/di.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/available_pickup_orders_cubit.dart';
import '../cubit/available_pickup_orders_state.dart';

class AvailablePickupOrdersScreen extends StatefulWidget {
  const AvailablePickupOrdersScreen({super.key});

  @override
  State<AvailablePickupOrdersScreen> createState() =>
      _AvailablePickupOrdersScreenState();
}

class _AvailablePickupOrdersScreenState
    extends State<AvailablePickupOrdersScreen>
    with SingleTickerProviderStateMixin {
  late AvailablePickupOrdersCubit _cubit;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cubit = getIt<AvailablePickupOrdersCubit>()..fetchAvailablePickupOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cubit.close();
    super.dispose();
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '';
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
            'الطلبات المتاحة',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFFFC107),
            indicatorWeight: 3,
            labelColor: const Color(0xFFFFC107),
            unselectedLabelColor: Colors.white54,
            labelStyle: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.cairo(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.call_received, size: 20),
                text: 'طلبات الاستلام',
              ),
              Tab(
                icon: Icon(Icons.local_shipping, size: 20),
                text: 'طلبات التوصيل',
              ),
            ],
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocConsumer<AvailablePickupOrdersCubit, AvailablePickupOrdersState>(
            listener: (context, state) {
              if (state is AvailablePickupOrdersAcceptLoading) {
                _showAcceptingDialog(
                  context,
                  'جاري قبول المهمة وتعيينك كابتن للطلب...',
                );
              } else if (state is AvailablePickupOrdersAcceptSuccess) {
                Navigator.of(context, rootNavigator: true).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      'تم قبول المهمة بنجاح! يمكنك متابعتها من شاشة مهامي النشطة',
                      style: GoogleFonts.cairo(color: Colors.white),
                      textAlign: TextAlign.right,
                    ),
                  ),
                );
              } else if (state is AvailablePickupOrdersAcceptError) {
                Navigator.of(context, rootNavigator: true).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      state.message,
                      style: GoogleFonts.cairo(color: Colors.white),
                      textAlign: TextAlign.right,
                    ),
                  ),
                );
              }
            },
            buildWhen: (previous, current) {
              return current is AvailablePickupOrdersInitial ||
                  current is AvailablePickupOrdersLoading ||
                  current is AvailablePickupOrdersLoaded ||
                  current is AvailablePickupOrdersError;
            },
            builder: (context, state) {
              if (state is AvailablePickupOrdersLoading) {
                return _buildSkeletonLoading();
              } else if (state is AvailablePickupOrdersError) {
                return _buildErrorState(state.message);
              } else if (state is AvailablePickupOrdersLoaded) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Pickup Orders
                    _buildOrdersList(
                      orders: state.pickupOrders,
                      emptyMessage: 'لا توجد طلبات استلام متاحة',
                      emptyDescription:
                          'لا توجد أجهزة بانتظار الاستلام من العملاء حالياً، اسحب للأسفل للتحديث.',
                      isDelivery: false,
                    ),
                    // Tab 2: Delivery Orders
                    _buildOrdersList(
                      orders: state.deliveryOrders,
                      emptyMessage: 'لا توجد طلبات توصيل متاحة',
                      emptyDescription:
                          'لا توجد أجهزة تم إصلاحها وبانتظار التوصيل للعملاء حالياً، اسحب للأسفل للتحديث.',
                      isDelivery: true,
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList({
    required List<OrderEntity> orders,
    required String emptyMessage,
    required String emptyDescription,
    required bool isDelivery,
  }) {
    if (orders.isEmpty) {
      return _buildEmptyState(emptyMessage, emptyDescription);
    }
    return RefreshIndicator(
      color: const Color(0xFFFFC107),
      backgroundColor: const Color(0xFF141414),
      onRefresh: () => _cubit.fetchAvailablePickupOrders(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return isDelivery
              ? _buildDeliveryOrderCard(order)
              : _buildPickupOrderCard(order);
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Pickup Order Card (existing design)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPickupOrderCard(OrderEntity order) {
    final formattedDate = _formatDate(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFC107).withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Order number & Status)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'متاح للاستلام',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                ),
                Text(
                  'رقم الطلب: #${order.orderNumber.split('-').last}',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          // Content body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device Info
                _buildDeviceInfo(order),

                const SizedBox(height: 16),

                // Pickup address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white38,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'العنوان: ${order.pickupAddress.city}، ${order.pickupAddress.address}',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Client Info Container
                if (order.client != null) _buildClientInfo(order),

                const SizedBox(height: 16),

                // Date & Delivery Fees Row
                _buildDateAndFees(formattedDate, order),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      'قبول المهمة',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      _cubit.acceptPickup(order.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Delivery Order Card (new design)
  // ══════════════════════════════════════════════════════════════
  Widget _buildDeliveryOrderCard(OrderEntity order) {
    final formattedDate = _formatDate(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.greenAccent.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Order number & Status)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.build_circle,
                        color: Colors.greenAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'جاهز للتوصيل',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'رقم الطلب: #${order.orderNumber.split('-').last}',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          // Content body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device Info
                _buildDeviceInfo(order),

                const SizedBox(height: 16),

                // Center Info (pickup from center)
                if (order.repairCenter.name.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blueAccent.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.store,
                            color: Colors.blueAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'استلام من المركز',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order.repairCenter.name,
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (order.repairCenter.address.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  order.repairCenter.address,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                              if (order.repairCenter.phone.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 13,
                                      color: Colors.blueAccent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      order.repairCenter.phone,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: Colors.blueAccent.shade100,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.copy_rounded,
                                        size: 16,
                                        color: Colors.blueAccent,
                                      ),
                                      tooltip: 'نسخ رقم المركز',
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: order.repairCenter.phone,
                                          ),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                Colors.teal.shade800,
                                            content: Text(
                                              'تم نسخ رقم المركز ✅',
                                              style: GoogleFonts.cairo(
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (order.repairCenter.address.isNotEmpty ||
                            order.repairCenter.name.isNotEmpty)
                          IconButton(
                            tooltip: 'نسخ عنوان المركز',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            onPressed: () {
                              final textToCopy =
                                  order.repairCenter.address.isNotEmpty
                                  ? order.repairCenter.address
                                  : order.repairCenter.name;
                              Clipboard.setData(
                                ClipboardData(text: textToCopy),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.teal.shade800,
                                  content: Text(
                                    'تم نسخ عنوان المركز للحافظة',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Delivery address (client destination)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFFFFC107),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'توصيل للعميل',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: const Color(0xFFFFC107),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order.pickupAddress.city}، ${order.pickupAddress.address}',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Client Info Container
                if (order.client != null) _buildClientInfo(order),

                const SizedBox(height: 12),

                // ⚠️ Warning Banner: Call client to confirm delivery location
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orangeAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'تنبيه: يرجى الاتصال بالعميل للتأكد من موقع التسليم الفعلي قبل التحرك بالجهاز.',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orangeAccent,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Date & Delivery Fees Row
                _buildDateAndFees(formattedDate, order),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delivery_dining),
                    label: Text(
                      'قبول مهمة التوصيل',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      _cubit.acceptDelivery(order.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Shared Widgets
  // ══════════════════════════════════════════════════════════════

  Widget _buildDeviceInfo(OrderEntity order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            order.device.type.toLowerCase() == 'phone'
                ? Icons.phone_iphone
                : order.device.type.toLowerCase() == 'tablet'
                ? Icons.tablet_mac
                : Icons.laptop_mac,
            color: const Color(0xFFFFC107),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${order.device.brand} ${order.device.model}',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'المشكلة: ${_translateProblemType(order.device.problemType)}',
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70),
              ),
              if (order.device.problemDescription.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  order.device.problemDescription,
                  style: GoogleFonts.cairo(fontSize: 13, color: Colors.white38),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientInfo(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFFFC107).withValues(alpha: 0.1),
                child: Text(
                  order.client!.name.isNotEmpty
                      ? order.client!.name[0].toUpperCase()
                      : 'ع',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFFFFC107),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.client!.name,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.client!.phone,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            tooltip: 'نسخ رقم العميل',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.copy_rounded, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: order.client!.phone));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.teal.shade800,
                  content: Text(
                    'تم نسخ رقم العميل ✅',
                    style: GoogleFonts.cairo(color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndFees(String formattedDate, OrderEntity order) {
    final double feeVal = order.fees.delegateFeeValue > 0
        ? order.fees.delegateFeeValue
        : (order.financialSnapshot?.delegateFee ?? 0) > 0
        ? order.financialSnapshot!.delegateFee
        : (order.fees.delivery > 0 ? order.fees.delivery : 500.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'تاريخ الإنشاء: $formattedDate',
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
        ),
        Text(
          'أجرة التوصيل: ${feeVal.toStringAsFixed(0)} د.ع',
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFC107),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Dialogs & Helpers
  // ══════════════════════════════════════════════════════════════

  void _showAcceptingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: const Color(0xFF141414),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFFFFC107)),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: GoogleFonts.cairo(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _translateProblemType(String type) {
    switch (type.toLowerCase()) {
      case 'screen':
        return 'كسر شاشة';
      case 'battery':
        return 'مشكلة بطارية';
      case 'camera':
        return 'كاميرا';
      case 'software':
        return 'نظام التشغيل / سوفتوير';
      case 'charging':
        return 'منفذ الشحن / الشاحن';
      case 'back_glass':
        return 'الزجاج الخلفي';
      default:
        return type.isNotEmpty ? type : 'أخرى';
    }
  }

  Widget _buildEmptyState(String title, String description) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.assignment_turned_in_outlined,
                size: 64,
                color: Color(0xFFFFC107),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.white38),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(
                'تحديث القائمة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _cubit.fetchAvailablePickupOrders(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMsg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ غير متوقع',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMsg,
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.white38),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _cubit.fetchAvailablePickupOrders(),
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.white.withValues(alpha: 0.05),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 80, height: 20, color: Colors.white),
                    Container(width: 100, height: 16, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(width: 80, height: 12, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 12,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 100, height: 12, color: Colors.white),
                    Container(width: 80, height: 14, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
