import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/di/di.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/routes_manager/routes.dart';
import '../../../centers/presentation/cubit/center_dashboard_orders_cubit.dart';
import '../../../centers/presentation/cubit/center_dashboard_orders_state.dart';
import '../../../orders/domain/entities/order_entity.dart';

class CenterHome extends StatefulWidget {
  const CenterHome({super.key});

  @override
  State<CenterHome> createState() => _CenterHomeState();
}

class _CenterHomeState extends State<CenterHome> {
  final ScrollController _scrollController = ScrollController();
  late CenterDashboardOrdersCubit _cubit;
  String _selectedFilter = 'all'; // 'all', 'pending', 'ongoing', 'completed'
  int _selectedMenuIndex = 0; // 0: Orders Dashboard, 1: Services, 2: Profile, 3: Support

  @override
  void initState() {
    super.initState();
    _cubit = getIt<CenterDashboardOrdersCubit>()..fetchOrders(isRefresh: true);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_selectedMenuIndex == 0) {
        _cubit.fetchOrders();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await getIt<SecureStorageService>().clearAuth();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.loginRoute, (route) => false);
    }
  }

  Future<void> _makeCall(String phone) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  List<OrderEntity> _filterOrders(List<OrderEntity> orders) {
    switch (_selectedFilter) {
      case 'pending':
        return orders.where((o) => o.status.toLowerCase() == 'pending').toList();
      case 'ongoing':
        final nonOngoing = ['pending', 'completed', 'delivered', 'done', 'cancelled', 'rejected'];
        return orders.where((o) => !nonOngoing.contains(o.status.toLowerCase())).toList();
      case 'completed':
        return orders.where((o) => ['completed', 'delivered', 'done'].contains(o.status.toLowerCase())).toList();
      case 'all':
      default:
        return orders;
    }
  }

  String _getAppBarTitle() {
    switch (_selectedMenuIndex) {
      case 1:
        return 'إدارة الخدمات ورسوم الصيانة';
      case 2:
        return 'الملف الشخصي للمركز';
      case 3:
        return 'الدعم الفني والمساعدة';
      case 0:
      default:
        return 'شاشة مركز الصيانة';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: FutureBuilder<String?>(
        future: getIt<SecureStorageService>().getUserName(),
        builder: (context, nameSnapshot) {
          final centerName = nameSnapshot.data ?? 'مركز الصيانة';
          return Scaffold(
            backgroundColor: const Color(0xFF0F0F0F),
            appBar: AppBar(
              title: Text(
                _getAppBarTitle(),
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: const Color(0xFF141414),
              elevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFFFFC107)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFFFFC107)),
                  onPressed: () => _logout(context),
                  tooltip: 'تسجيل الخروج',
                ),
              ],
            ),
            drawer: Drawer(
              backgroundColor: const Color(0xFF141414),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    // Drawer Header
                    UserAccountsDrawerHeader(
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1E1E),
                        border: Border(
                          bottom: BorderSide(color: Colors.white10, width: 1),
                        ),
                      ),
                      accountName: Text(
                        centerName,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      accountEmail: Text(
                        'مركز صيانة معتمد',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFFFFC107),
                          fontSize: 12,
                        ),
                      ),
                      currentAccountPicture: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.store,
                          size: 40,
                          color: Color(0xFFFFC107),
                        ),
                      ),
                    ),

                    // Menu Items
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildDrawerItem(
                            index: 0,
                            title: 'لوحة التحكم والطلبات',
                            icon: Icons.dashboard_rounded,
                          ),
                          _buildDrawerItem(
                            index: 1,
                            title: 'إدارة الخدمات والأسعار',
                            icon: Icons.design_services_rounded,
                          ),
                          _buildDrawerItem(
                            index: 2,
                            title: 'الملف الشخصي للمركز',
                            icon: Icons.store_mall_directory_rounded,
                          ),
                          _buildDrawerItem(
                            index: 3,
                            title: 'الدعم الفني والمساعدة',
                            icon: Icons.contact_support_rounded,
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.white10, height: 1),

                    // Footer
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'نجيك للشركاء v1.0.0',
                        style: GoogleFonts.cairo(
                          color: Colors.white24,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: BlocBuilder<CenterDashboardOrdersCubit, CenterDashboardOrdersState>(
                builder: (context, state) {
                  return _getBodyWidget(state, centerName);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedMenuIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFC107).withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFFFFC107) : Colors.white60,
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFFFFC107) : Colors.white70,
            fontSize: 14,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedMenuIndex = index;
          });
          Navigator.pop(context); // Close Drawer
        },
      ),
    );
  }

  Widget _getBodyWidget(CenterDashboardOrdersState state, String centerName) {
    switch (_selectedMenuIndex) {
      case 1:
        return const _CenterServicesView();
      case 2:
        return _CenterProfileView(centerName: centerName);
      case 3:
        return const _SupportView();
      case 0:
      default:
        return _buildOrdersDashboard(state, centerName);
    }
  }

  // ─── Orders Dashboard View ──────────────────────────────
  Widget _buildOrdersDashboard(CenterDashboardOrdersState state, String centerName) {
    int totalCount = 0;
    int pendingCount = 0;
    int ongoingCount = 0;
    int completedCount = 0;
    List<OrderEntity> orders = [];
    bool hasReachedMax = false;
    bool isLoading = state is CenterDashboardOrdersLoading;

    if (state is CenterDashboardOrdersLoaded) {
      totalCount = state.totalCount;
      pendingCount = state.pendingCount;
      ongoingCount = state.inProgressCount;
      completedCount = state.completedCount;
      orders = state.orders;
      hasReachedMax = state.hasReachedMax;
    }

    final filteredOrders = _filterOrders(orders);

    return RefreshIndicator(
      onRefresh: () => _cubit.fetchOrders(isRefresh: true),
      color: const Color(0xFFFFC107),
      backgroundColor: const Color(0xFF141414),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header and welcome section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.store,
                          size: 40,
                          color: Color(0xFFFFC107),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحباً بك، $centerName',
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'لوحة التحكم ومتابعة طلبات الصيانة',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Statistics cards grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        title: 'إجمالي الطلبات',
                        value: totalCount.toString(),
                        icon: Icons.assignment_outlined,
                        color: const Color(0xFFFFC107),
                        isLoading: state is CenterDashboardOrdersInitial || (isLoading && orders.isEmpty),
                      ),
                      _buildStatCard(
                        title: 'طلبات جديدة',
                        value: pendingCount.toString(),
                        icon: Icons.new_releases_outlined,
                        color: Colors.orangeAccent,
                        isLoading: state is CenterDashboardOrdersInitial || (isLoading && orders.isEmpty),
                      ),
                      _buildStatCard(
                        title: 'تحت الصيانة',
                        value: ongoingCount.toString(),
                        icon: Icons.build_outlined,
                        color: Colors.blueAccent,
                        isLoading: state is CenterDashboardOrdersInitial || (isLoading && orders.isEmpty),
                      ),
                      _buildStatCard(
                        title: 'طلبات منجزة',
                        value: completedCount.toString(),
                        icon: Icons.check_circle_outline,
                        color: Colors.greenAccent,
                        isLoading: state is CenterDashboardOrdersInitial || (isLoading && orders.isEmpty),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Filter tabs
                  _buildFilterTabs(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Error message if any
          if (state is CenterDashboardOrdersError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    '⚠️ ${state.message}',
                    style: GoogleFonts.cairo(color: Colors.redAccent, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Orders list
          if (filteredOrders.isEmpty && !isLoading && state is! CenterDashboardOrdersInitial)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox_outlined, size: 64, color: Colors.white30),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد طلبات في هذا القسم حالياً',
                      style: GoogleFonts.cairo(fontSize: 16, color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= filteredOrders.length) {
                      if (hasReachedMax) {
                        return const SizedBox(height: 20);
                      }
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFFFFC107)),
                        ),
                      );
                    }
                    final order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                  childCount: filteredOrders.length + (state is CenterDashboardOrdersInitial || (isLoading && orders.isEmpty) ? 0 : 1),
                ),
              ),
            ),

          // Shimmer loaders when initial loading
          if (state is CenterDashboardOrdersInitial || (isLoading && orders.isEmpty))
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const _OrderCardSkeleton(),
                  childCount: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFC107),
                  ),
                )
              : Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'key': 'all', 'label': 'الكل'},
      {'key': 'pending', 'label': 'جديد'},
      {'key': 'ongoing', 'label': 'تحت الصيانة'},
      {'key': 'completed', 'label': 'مكتملة'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = f['key']!;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFC107) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    f['label']!,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isSelected ? Colors.black87 : Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
          Routes.centerOrderDetailsRoute,
          arguments: order.id,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header Row (Status & Order number)
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
                  '#ORD-${order.orderNumber.split('-').last}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Device & Client Info Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image or Device Icon
                if (order.device.images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      order.device.images.first,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultDeviceIcon(order.device.type),
                    ),
                  )
                else
                  _buildDefaultDeviceIcon(order.device.type),
                const SizedBox(width: 16),

                // Device Specs & Problem
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
                        order.device.problemDescription.isNotEmpty
                            ? order.device.problemDescription
                            : order.device.problemType,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 24),

            // Client Contact Info Row
            if (order.client != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18, color: Colors.white54),
                      const SizedBox(width: 8),
                      Text(
                        order.client!.name,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (order.client!.phone.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.phone_enabled_outlined, color: Color(0xFFFFC107), size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107).withValues(alpha: 0.1),
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () => _makeCall(order.client!.phone),
                    ),
                ],
              ),
              const Divider(color: Colors.white10, height: 24),
            ],

            // Footer Row: Date & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'رسوم الصيانة',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: Colors.white38,
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultDeviceIcon(String type) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Icon(
        type.toLowerCase() == 'phone' ? Icons.phone_iphone_outlined : Icons.build_circle_outlined,
        color: const Color(0xFFFFC107),
        size: 32,
      ),
    );
  }

  _StatusBadgeData _getStatusBadgeData(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusBadgeData(
          text: 'قيد الانتظار',
          backgroundColor: Colors.orange.withValues(alpha: 0.15),
          textColor: Colors.orangeAccent,
          showDot: true,
        );
      case 'awaiting_approval':
        return _StatusBadgeData(
          text: 'بانتظار الموافقة',
          backgroundColor: Colors.cyan.withValues(alpha: 0.15),
          textColor: Colors.cyanAccent,
          showDot: false,
        );
      case 'delegate_assigned':
      case 'assigned':
        return _StatusBadgeData(
          text: 'تم تعيين المندوب',
          backgroundColor: Colors.blue.withValues(alpha: 0.15),
          textColor: Colors.blueAccent,
          showDot: false,
        );
      case 'picking_up':
        return _StatusBadgeData(
          text: 'جاري الاستلام',
          backgroundColor: Colors.purple.withValues(alpha: 0.15),
          textColor: Colors.purpleAccent,
          showDot: true,
        );
      case 'picked_up':
        return _StatusBadgeData(
          text: 'تم الاستلام',
          backgroundColor: Colors.teal.withValues(alpha: 0.15),
          textColor: Colors.tealAccent,
          showDot: false,
        );
      case 'at_center':
        return _StatusBadgeData(
          text: 'في المركز',
          backgroundColor: Colors.teal.withValues(alpha: 0.15),
          textColor: Colors.tealAccent,
          showDot: false,
        );
      case 'inspecting':
        return _StatusBadgeData(
          text: 'جاري الفحص',
          backgroundColor: Colors.orange.withValues(alpha: 0.15),
          textColor: Colors.orangeAccent,
          showDot: true,
        );
      case 'approved':
        return _StatusBadgeData(
          text: 'تم الموافقة',
          backgroundColor: Colors.green.withValues(alpha: 0.15),
          textColor: Colors.greenAccent,
          showDot: false,
        );
      case 'rejected':
        return _StatusBadgeData(
          text: 'مرفوض',
          backgroundColor: Colors.red.withValues(alpha: 0.15),
          textColor: Colors.redAccent,
          showDot: false,
        );
      case 'ongoing':
      case 'repairing':
        return _StatusBadgeData(
          text: 'جاري الإصلاح',
          backgroundColor: Colors.amber.withValues(alpha: 0.15),
          textColor: const Color(0xFFFFC107),
          showDot: true,
        );
      case 'repaired':
        return _StatusBadgeData(
          text: 'تم الإصلاح',
          backgroundColor: Colors.lightGreen.withValues(alpha: 0.15),
          textColor: Colors.lightGreenAccent,
          showDot: false,
        );
      case 'in_transit':
      case 'delivering':
      case 'returning':
        return _StatusBadgeData(
          text: 'في الطريق',
          backgroundColor: Colors.indigo.withValues(alpha: 0.15),
          textColor: Colors.indigoAccent,
          showDot: true,
        );
      case 'delivered':
      case 'completed':
        return _StatusBadgeData(
          text: 'مكتمل',
          backgroundColor: Colors.green.withValues(alpha: 0.15),
          textColor: Colors.greenAccent,
          showDot: false,
        );
      case 'cancelled':
        return _StatusBadgeData(
          text: 'ملغي',
          backgroundColor: Colors.red.withValues(alpha: 0.15),
          textColor: Colors.redAccent,
          showDot: false,
        );
      default:
        return _StatusBadgeData(
          text: 'حالة غير معروفة',
          backgroundColor: Colors.grey.withValues(alpha: 0.15),
          textColor: Colors.white54,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.white10,
        highlightColor: Colors.white24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 80, height: 20, color: Colors.white),
                Container(width: 100, height: 20, color: Colors.white),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: double.infinity, height: 14, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 100, height: 16, color: Colors.white),
                Container(width: 80, height: 20, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 1. SERVICES VIEW ──────────────────────────────────────
class _CenterServicesView extends StatefulWidget {
  const _CenterServicesView();

  @override
  State<_CenterServicesView> createState() => _CenterServicesViewState();
}

class _CenterServicesViewState extends State<_CenterServicesView> {
  final List<Map<String, dynamic>> _dummyServices = [
    {'title': 'تبديل شاشة (درجة أولى)', 'price': '45,000 د.ع', 'icon': Icons.screenshot_rounded, 'isActive': true},
    {'title': 'تبديل شاشة (أصلية)', 'price': '85,000 د.ع', 'icon': Icons.screenshot_rounded, 'isActive': true},
    {'title': 'تبديل بطارية سريعة', 'price': '25,000 د.ع', 'icon': Icons.battery_charging_full_rounded, 'isActive': true},
    {'title': 'إصلاح منفذ الشحن Type-C', 'price': '15,000 د.ع', 'icon': Icons.usb_rounded, 'isActive': true},
    {'title': 'إصلاح لوحة البورد الرئيسي', 'price': '75,000 د.ع', 'icon': Icons.developer_board_rounded, 'isActive': false},
    {'title': 'صيانة كاميرا خلفية', 'price': '35,000 د.ع', 'icon': Icons.camera_alt_rounded, 'isActive': true},
    {'title': 'تحديث برمجيات وسوفتوير', 'price': '10,000 د.ع', 'icon': Icons.system_update_rounded, 'isActive': true},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _dummyServices.length,
      itemBuilder: (context, index) {
        final service = _dummyServices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(service['icon'] as IconData, color: const Color(0xFFFFC107), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['title'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      service['price'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: const Color(0xFFFFC107),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: service['isActive'] as bool,
                activeThumbColor: const Color(0xFFFFC107),
                activeTrackColor: const Color(0xFFFFC107).withValues(alpha: 0.3),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.white12,
                onChanged: (val) {
                  setState(() {
                    _dummyServices[index]['isActive'] = val;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── 2. PROFILE VIEW ───────────────────────────────────────
class _CenterProfileView extends StatelessWidget {
  final String centerName;

  const _CenterProfileView({required this.centerName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upper Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFFFC107).withValues(alpha: 0.1),
                  child: const Icon(Icons.store, color: Color(0xFFFFC107), size: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  centerName,
                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'رقم التعريف: #CTR-2026-A5',
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.white30),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(120 تقييم)',
                      style: GoogleFonts.cairo(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Detail list
          Text(
            'بيانات الاتصال والعمل',
            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                _buildProfileRow(Icons.phone_outlined, 'الهاتف الرئيسي', '01281221631'),
                const Divider(color: Colors.white10, height: 24),
                _buildProfileRow(Icons.location_on_outlined, 'العنوان بالتفصيل', 'بغداد - زيونة - شارع الربيعي'),
                const Divider(color: Colors.white10, height: 24),
                _buildProfileRow(Icons.access_time_rounded, 'أوقات العمل', '09:00 ص - 10:00 م'),
                const Divider(color: Colors.white10, height: 24),
                _buildProfileRow(Icons.verified_user_outlined, 'نوع الحساب', 'شريك مركز صيانة معتمد'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: Text(
                'تعديل ملف المركز',
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38)),
              Text(value, style: GoogleFonts.cairo(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 3. SUPPORT VIEW ───────────────────────────────────────
class _SupportView extends StatelessWidget {
  const _SupportView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFFC107), const Color(0xFFFF9800)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'هل تحتاج لمساعدة؟',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'نحن هنا لمساعدتك في نجيك وإدارة ورشة صيانتك بكل سهولة وسلاسة.',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.black87.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.help_center_rounded, color: Colors.black87, size: 64),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'الأسئلة الشائعة للشركاء',
            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 12),

          // FAQ items
          _buildFAQTile('كيف يمكنني تغيير حالة صيانة الجهاز؟', 'يمكنك فتح تفاصيل الطلب من لوحة التحكم، ومتابعة تحديثات الحالة ورفع الصور وتقارير الفحص والتقييم بسهولة بالضغط على تحديث الحالة.'),
          _buildFAQTile('كيف يتم تحصيل الأرباح ودخل الصيانة؟', 'يتم احتساب دخل الصيانة الخاص بمركزك ودفعه لك بانتظام بعد إتمام الطلب وتوصيل الجهاز وإتمام دفعة العميل بنجاح.'),
          _buildFAQTile('كيف أقوم بتعطيل أو تفعيل خدمة صيانة معينة؟', 'من القائمة الجانبية، اختر "إدارة الخدمات والأسعار" واستخدم زر التبديل لتفعيل أو تعطيل الخدمة مباشرة في تطبيق العميل.'),

          const SizedBox(height: 32),

          // Direct contacts
          Center(
            child: Text(
              'أو تواصل مع الدعم الفني مباشرة:',
              style: GoogleFonts.cairo(fontSize: 13, color: Colors.white38),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF141414),
                    foregroundColor: const Color(0xFFFFC107),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white10),
                    ),
                  ),
                  icon: const Icon(Icons.phone_rounded),
                  label: Text('اتصال بالهاتف', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // Launch direct support call line
                    final Uri tel = Uri(scheme: 'tel', path: '966501234568');
                    launchUrl(tel);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF141414),
                    foregroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white10),
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: Text('محادثة واتساب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final Uri whatsapp = Uri.parse('https://wa.me/966501234568');
                    launchUrl(whatsapp, mode: LaunchMode.externalApplication);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          colorScheme: const ColorScheme.dark(primary: Color(0xFFFFC107)),
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                answer,
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
