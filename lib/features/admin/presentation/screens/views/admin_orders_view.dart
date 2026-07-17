import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../cubit/admin_orders_cubit.dart';
import '../../cubit/admin_orders_state.dart';
import '../../../../orders/domain/entities/order_entity.dart';
import 'admin_order_details_bottom_sheet.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  final ScrollController _scrollController = ScrollController();
  late AdminOrdersCubit _ordersCubit;

  @override
  void initState() {
    super.initState();
    _ordersCubit = context.read<AdminOrdersCubit>();
    _scrollController.addListener(_onScroll);
    _ordersCubit.fetchOrders(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _ordersCubit.loadMore();
    }
  }

  static const Map<String, String> _statusLabels = {
    'pending': 'بانتظار المعالجة',
    'accepted': 'تم القبول',
    'assigned': 'تم التعيين',
    'delegate_assigned': 'تم تعيين المندوب',
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
  };

  static const Map<String, Color> _statusColors = {
    'pending': Color(0xFFFFC107),
    'accepted': Color(0xFF2196F3),
    'assigned': Color(0xFF2196F3),
    'delegate_assigned': Color(0xFF4CAF50),
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
  };

  static const Map<String, IconData> _deviceTypeIcons = {
    'phone': Icons.phone_android,
    'tablet': Icons.tablet_android,
    'laptop': Icons.laptop,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
      builder: (context, state) {
        if (state is AdminOrdersInitial || state is AdminOrdersLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (context, index) => const _OrderCardSkeleton(),
          );
        }

        if (state is AdminOrdersError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _ordersCubit.fetchOrders(isRefresh: true),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text('إعادة المحاولة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }

        List<OrderEntity> orders = [];
        OrdersPaginationEntity? pagination;
        bool isLoadingMore = false;

        if (state is AdminOrdersLoaded) {
          orders = state.orders;
          pagination = state.pagination;
        } else if (state is AdminOrdersLoadingMore) {
          orders = state.orders;
          pagination = state.pagination;
          isLoadingMore = true;
        }

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment_outlined, color: Colors.white24, size: 64),
                const SizedBox(height: 16),
                Text(
                  'لا توجد طلبات حالياً',
                  style: GoogleFonts.cairo(color: Colors.white38, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFFFFC107),
          backgroundColor: const Color(0xFF1E1E1E),
          onRefresh: () => _ordersCubit.fetchOrders(isRefresh: true),
          child: Column(
            children: [
              // Summary bar
              if (pagination != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.assignment, color: Color(0xFFFFC107), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'إجمالي الطلبات',
                            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${pagination.total}',
                          style: GoogleFonts.cairo(
                            color: const Color(0xFFFFC107),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Orders list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= orders.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(color: Color(0xFFFFC107)),
                        ),
                      );
                    }

                    final order = orders[index];
                    return _buildOrderCard(order);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(OrderEntity order) {
    final statusColor = _statusColors[order.status] ?? Colors.grey;
    final statusLabel = _statusLabels[order.status] ?? 'حالة غير معروفة';
    final deviceIcon = _deviceTypeIcons[order.device.type] ?? Icons.devices;

    final createdDate = DateTime.tryParse(order.createdAt);
    final dateStr = createdDate != null
        ? '${createdDate.toLocal().day}/${createdDate.toLocal().month}/${createdDate.toLocal().year}'
        : '';

    return GestureDetector(
      onTap: () {
        AdminOrderDetailsBottomSheet.show(context, order.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order number + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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

          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),

          // Device Info Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(deviceIcon, color: const Color(0xFFFFC107), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.device.brand} ${order.device.model}',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _getProblemTypeLabel(order.device.problemType),
                      style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Client + Center Row
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.white30, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.repairCenter.name.isNotEmpty
                      ? order.repairCenter.name
                      : 'لم يُحدد مركز',
                  style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.location_on_outlined, color: Colors.white30, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${order.pickupAddress.city} - ${order.pickupAddress.address}',
                  style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Footer Row: Fees + Date + Payment
          Row(
            children: [
              // Fees
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_outlined, color: Color(0xFFFFC107), size: 13),
                    const SizedBox(width: 4),
                    Text(
                      order.fees.total.toStringAsFixed(0),
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFFFC107),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Payment Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: order.paymentStatus == 'paid'
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                      : Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.paymentStatus == 'paid' ? 'مدفوع' : 'غير مدفوع',
                  style: GoogleFonts.cairo(
                    color: order.paymentStatus == 'paid' ? const Color(0xFF4CAF50) : Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              // Date
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Colors.white24, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: GoogleFonts.cairo(color: Colors.white38, fontSize: 11),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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

class _OrderCardSkeleton extends StatelessWidget {
  const _OrderCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E1E),
      highlightColor: const Color(0xFF2A2A2A),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 160, height: 14, color: Colors.white10),
                Container(width: 70, height: 20, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6))),
              ],
            ),
            const SizedBox(height: 14),
            Container(width: double.infinity, height: 1, color: Colors.white10),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 140, height: 13, color: Colors.white10),
                    const SizedBox(height: 6),
                    Container(width: 90, height: 11, color: Colors.white10),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(width: 120, height: 11, color: Colors.white10),
                const Spacer(),
                Container(width: 80, height: 11, color: Colors.white10),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(width: 50, height: 18, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6))),
                const SizedBox(width: 8),
                Container(width: 60, height: 18, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6))),
                const Spacer(),
                Container(width: 70, height: 11, color: Colors.white10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
