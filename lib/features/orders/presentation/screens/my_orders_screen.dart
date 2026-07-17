import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routes_manager/routes.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  late OrdersCubit _ordersCubit;
  bool _showActive = true; // Tab toggle state: true for Active, false for Previous

  @override
  void initState() {
    super.initState();
    _ordersCubit = getIt<OrdersCubit>()..fetchOrders(limit: 10);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _ordersCubit.fetchOrders(limit: 10);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _ordersCubit.close();
    super.dispose();
  }

  // Filter orders based on selected tab
  List<OrderEntity> _filterOrders(List<OrderEntity> orders) {
    final activeStatuses = ['pending', 'awaiting_approval', 'ongoing', 'repairing', 'accepted', 'pickup_assigned', 'in_transit'];
    if (_showActive) {
      return orders.where((order) => activeStatuses.contains(order.status.toLowerCase())).toList();
    } else {
      return orders.where((order) => !activeStatuses.contains(order.status.toLowerCase())).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _ordersCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFAF5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE0E0E0),
                              image: DecorationImage(
                                image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'طلباتي',
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.menu, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Custom Tab Toggles
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showActive = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _showActive ? const Color(0xFFFFC107) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'طلبات نشطة',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _showActive ? Colors.black87 : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showActive = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_showActive ? const Color(0xFFFFC107) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'طلبات سابقة',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: !_showActive ? Colors.black87 : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Content
                  Expanded(
                    child: BlocBuilder<OrdersCubit, OrdersState>(
                      builder: (context, state) {
                        if (state is OrdersInitial || (state is OrdersLoading && _ordersCubit.state is! OrdersLoaded)) {
                          return ListView.builder(
                            itemCount: 3,
                            itemBuilder: (context, index) => const _OrderCardSkeleton(),
                          );
                        } else if (state is OrdersError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: GoogleFonts.cairo(color: Colors.red),
                            ),
                          );
                        } else if (state is OrdersLoaded) {
                          final allOrders = state.orders;
                          final filteredOrders = _filterOrders(allOrders);

                          if (filteredOrders.isEmpty) {
                            return Center(
                              child: Text(
                                _showActive ? 'لا توجد طلبات نشطة حالياً' : 'لا توجد طلبات سابقة',
                                style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey),
                              ),
                            );
                          }

                          return RefreshIndicator(
                            color: const Color(0xFFFFC107),
                            onRefresh: () async {
                              await _ordersCubit.fetchOrders(limit: 10, isRefresh: true);
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: state.hasReachedMax ? filteredOrders.length + 1 : filteredOrders.length + 2,
                              itemBuilder: (context, index) {
                                // Show Help Card at the very end of the list
                                if (index == filteredOrders.length || (state.hasReachedMax && index == filteredOrders.length)) {
                                  if (index == filteredOrders.length) {
                                    return const SizedBox(height: 10);
                                  }
                                  return _buildHelpCard();
                                }

                                if (index > filteredOrders.length) {
                                  return const _OrderCardSkeleton();
                                }

                                final order = filteredOrders[index];
                                return _buildOrderCard(order);
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order) {
    final statusData = _getStatusBadgeData(order.status);
    final formattedDate = _formatDate(order.createdAt);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.orderTrackingRoute,
          arguments: order.id,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Status tag & Order Number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusData.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (statusData.showDot)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: statusData.textColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Text(
                        statusData.text,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusData.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'رقم الطلب: #${order.orderNumber.split('-').last}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Device details & date
            Text(
              '${order.device.brand} ${order.device.model}',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Problem, Wrench/Phone Icon, & Price
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    order.device.type.toLowerCase() == 'phone' ? Icons.phone_iphone : Icons.build,
                    color: const Color(0xFFFFC107),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.device.problemDescription.isNotEmpty
                            ? order.device.problemDescription
                            : order.device.problemType,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        formattedDate,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${order.fees.total.toInt()} د.ع',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFC107),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Actions Buttons Row
            Row(
              children: [
                // Chat/Message Button
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 12),
                // Track Order button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.orderTrackingRoute,
                        arguments: order.id,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _getActionButtonLabel(order.status),
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Support/Help Card at bottom
  Widget _buildHelpCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black,
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&q=80&w=600'),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل تحتاج مساعدة؟',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'فريق الدعم الفني متواجد لمساعدتك على مدار الساعة',
                  style: GoogleFonts.cairo(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _showSupportNumberDialog(context);
            },
            icon: const Icon(Icons.chat, size: 16),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            label: Text(
              'تحدث معنا',
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _getActionButtonLabel(String status) {
    if (status.toLowerCase() == 'awaiting_approval') {
      return 'تتبع الفني';
    }
    return 'تتبع الطلب';
  }

  _StatusBadgeData _getStatusBadgeData(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusBadgeData(
          text: 'قيد الانتظار',
          backgroundColor: const Color(0xFFFFF9C4),
          textColor: const Color(0xFF8B7500),
          showDot: true,
        );
      case 'awaiting_approval':
        return _StatusBadgeData(
          text: 'بانتظار الموافقة',
          backgroundColor: const Color(0xFFE0F7FA),
          textColor: const Color(0xFF00838F),
          showDot: false,
        );
      case 'delegate_assigned':
      case 'assigned':
        return _StatusBadgeData(
          text: 'تم تعيين المندوب',
          backgroundColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2E7D32),
          showDot: false,
        );
      case 'picking_up':
        return _StatusBadgeData(
          text: 'جاري الاستلام',
          backgroundColor: const Color(0xFFF3E5F5),
          textColor: const Color(0xFF7B1FA2),
          showDot: true,
        );
      case 'picked_up':
        return _StatusBadgeData(
          text: 'تم الاستلام',
          backgroundColor: const Color(0xFFE0F2F1),
          textColor: const Color(0xFF00695C),
          showDot: false,
        );
      case 'at_center':
        return _StatusBadgeData(
          text: 'في المركز',
          backgroundColor: const Color(0xFFE0F7FA),
          textColor: const Color(0xFF006064),
          showDot: false,
        );
      case 'inspecting':
        return _StatusBadgeData(
          text: 'جاري الفحص',
          backgroundColor: const Color(0xFFFFF3E0),
          textColor: const Color(0xFFE65100),
          showDot: true,
        );
      case 'approved':
        return _StatusBadgeData(
          text: 'تم الموافقة',
          backgroundColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2E7D32),
          showDot: false,
        );
      case 'rejected':
        return _StatusBadgeData(
          text: 'مرفوض',
          backgroundColor: const Color(0xFFFFEBEE),
          textColor: const Color(0xFFC62828),
          showDot: false,
        );
      case 'ongoing':
      case 'repairing':
        return _StatusBadgeData(
          text: 'جاري الإصلاح',
          backgroundColor: const Color(0xFFFFF9C4),
          textColor: const Color(0xFF8B7500),
          showDot: true,
        );
      case 'repaired':
        return _StatusBadgeData(
          text: 'تم الإصلاح',
          backgroundColor: const Color(0xFFF1F8E9),
          textColor: const Color(0xFF558B2F),
          showDot: false,
        );
      case 'in_transit':
      case 'delivering':
      case 'returning':
        return _StatusBadgeData(
          text: 'في الطريق',
          backgroundColor: const Color(0xFFE3F2FD),
          textColor: const Color(0xFF1565C0),
          showDot: true,
        );
      case 'delivered':
        return _StatusBadgeData(
          text: 'تم التوصيل',
          backgroundColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2E7D32),
          showDot: false,
        );
      case 'completed':
        return _StatusBadgeData(
          text: 'مكتمل',
          backgroundColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2E7D32),
          showDot: false,
        );
      case 'cancelled':
        return _StatusBadgeData(
          text: 'ملغي',
          backgroundColor: const Color(0xFFFFEBEE),
          textColor: const Color(0xFFC62828),
          showDot: false,
        );
      default:
        return _StatusBadgeData(
          text: 'حالة غير معروفة',
          backgroundColor: const Color(0xFFF5F5F5),
          textColor: Colors.black54,
          showDot: true,
        );
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '';
    }
  }

  void _showSupportNumberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFCFAF5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'رقم الدعم الفني',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'يمكنك نسخ الرقم والتواصل معنا عبر واتساب:',
                style: GoogleFonts.cairo(color: Colors.black87, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_android_outlined, color: Color(0xFFFFC107)),
                    const SizedBox(width: 8),
                    SelectableText(
                      '+9647824774219',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إغلاق',
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: '+9647824774219'));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم نسخ رقم الدعم الفني بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: Text(
                'نسخ الرقم',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );
      },
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

class _OrderCardSkeleton extends StatelessWidget {
  const _OrderCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: 180,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
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
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
