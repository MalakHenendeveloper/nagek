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
import '../../../centers/presentation/cubit/center_dashboard_cubit.dart';
import '../../../centers/presentation/cubit/center_dashboard_state.dart';
import '../../../centers/presentation/cubit/my_center_services_cubit.dart';
import '../../../centers/presentation/cubit/my_center_services_state.dart';
import '../../../centers/presentation/cubit/update_center_profile_cubit.dart';
import '../../../centers/presentation/cubit/update_center_profile_state.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../widgets/center_dashboard_drawer.dart';

class CenterHome extends StatefulWidget {
  const CenterHome({super.key});

  @override
  State<CenterHome> createState() => _CenterHomeState();
}

class _CenterHomeState extends State<CenterHome> {
  final ScrollController _scrollController = ScrollController();
  late final CenterDashboardOrdersCubit _cubit =
      getIt<CenterDashboardOrdersCubit>()..fetchOrders(isRefresh: true);
  late final CenterDashboardCubit _dashboardCubit =
      getIt<CenterDashboardCubit>()..fetchCenterDashboard();
  String _selectedFilter = 'all'; // 'all', 'pending', 'ongoing', 'completed'
  final int _selectedMenuIndex =
      0; // 0: Orders Dashboard, 1: Services, 2: Profile, 3: Support

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_selectedMenuIndex == 0) {
        _cubit.fetchOrders();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    _dashboardCubit.close();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await getIt<SecureStorageService>().clearAuth();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.loginRoute,
        (route) => false,
      );
    }
  }

  Future<void> _makeCall(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  List<OrderEntity> _filterOrders(List<OrderEntity> orders) {
    switch (_selectedFilter) {
      case 'pending':
        return orders
            .where((o) => o.status.toLowerCase() == 'pending')
            .toList();
      case 'ongoing':
        final nonOngoing = [
          'pending',
          'completed',
          'delivered',
          'done',
          'cancelled',
          'rejected',
        ];
        return orders
            .where((o) => !nonOngoing.contains(o.status.toLowerCase()))
            .toList();
      case 'completed':
        return orders
            .where(
              (o) => [
                'completed',
                'delivered',
                'done',
              ].contains(o.status.toLowerCase()),
            )
            .toList();
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _dashboardCubit),
      ],
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
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(
                      Icons.analytics_outlined,
                      color: Color(0xFFFFC107),
                    ),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                    tooltip: 'لوحة الإحصائيات والإيرادات',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFFFFC107)),
                  onPressed: () => _logout(context),
                  tooltip: 'تسجيل الخروج',
                ),
              ],
            ),
            drawer: const CenterDashboardDrawer(),
            body: Directionality(
              textDirection: TextDirection.rtl,
              child:
                  BlocBuilder<
                    CenterDashboardOrdersCubit,
                    CenterDashboardOrdersState
                  >(
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
  Widget _buildOrdersDashboard(
    CenterDashboardOrdersState state,
    String centerName,
  ) {
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
      onRefresh: () async {
        _cubit.fetchOrders(isRefresh: true);
        _dashboardCubit.fetchCenterDashboard();
      },
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
                        isLoading:
                            state is CenterDashboardOrdersInitial ||
                            (isLoading && orders.isEmpty),
                      ),
                      _buildStatCard(
                        title: 'طلبات جديدة',
                        value: pendingCount.toString(),
                        icon: Icons.new_releases_outlined,
                        color: Colors.orangeAccent,
                        isLoading:
                            state is CenterDashboardOrdersInitial ||
                            (isLoading && orders.isEmpty),
                      ),
                      _buildStatCard(
                        title: 'تحت الصيانة',
                        value: ongoingCount.toString(),
                        icon: Icons.build_outlined,
                        color: Colors.blueAccent,
                        isLoading:
                            state is CenterDashboardOrdersInitial ||
                            (isLoading && orders.isEmpty),
                      ),
                      _buildStatCard(
                        title: 'طلبات منجزة',
                        value: completedCount.toString(),
                        icon: Icons.check_circle_outline,
                        color: Colors.greenAccent,
                        isLoading:
                            state is CenterDashboardOrdersInitial ||
                            (isLoading && orders.isEmpty),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Financial Revenue & Summary Cards ──────────────────────
                  BlocBuilder<CenterDashboardCubit, CenterDashboardState>(
                    builder: (context, dashState) {
                      double totalRevenue = 0.0;
                      int completedOrdersCount = 0;
                      int currentCenterOrdersCount = 0;
                      bool isDashLoading = dashState is CenterDashboardLoading;

                      if (dashState is CenterDashboardLoaded) {
                        final summary = dashState.dashboard.summary;
                        totalRevenue = summary.totalRevenue;
                        completedOrdersCount = summary.completedOrdersCount;
                        currentCenterOrdersCount =
                            summary.currentCenterOrdersCount;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الإيرادات وملخص أداء المركز',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFinancialCard(
                                  title: 'إجمالي الإيرادات',
                                  value:
                                      '${totalRevenue.toStringAsFixed(0)} د.ع',
                                  icon: Icons.account_balance_wallet_outlined,
                                  color: const Color(0xFFFFC107),
                                  isLoading: isDashLoading,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFinancialCard(
                                  title: 'الطلبات المنجزة',
                                  value: '$completedOrdersCount أوردر',
                                  icon: Icons.check_circle_outline,
                                  color: Colors.greenAccent,
                                  isLoading: isDashLoading,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildFinancialCard(
                            title: 'الأجهزة الموجودة بالمركز حالياً',
                            value: '$currentCenterOrdersCount جهاز',
                            icon: Icons.build_outlined,
                            color: Colors.cyanAccent,
                            isLoading: isDashLoading,
                          ),
                          if (dashState is CenterDashboardError) ...[
                            const SizedBox(height: 8),
                            Text(
                              '⚠️ خطأ في تحميل بيانات لوحة المركز: ${dashState.message}',
                              style: GoogleFonts.cairo(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    '⚠️ ${state.message}',
                    style: GoogleFonts.cairo(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Orders list
          if (filteredOrders.isEmpty &&
              !isLoading &&
              state is! CenterDashboardOrdersInitial)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.white30,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد طلبات في هذا القسم حالياً',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.white54,
                      ),
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
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFC107),
                          ),
                        ),
                      );
                    }
                    final order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                  childCount:
                      filteredOrders.length +
                      (state is CenterDashboardOrdersInitial ||
                              (isLoading && orders.isEmpty)
                          ? 0
                          : 1),
                ),
              ),
            ),

          // Shimmer loaders when initial loading
          if (state is CenterDashboardOrdersInitial ||
              (isLoading && orders.isEmpty))
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
        border: Border.all(color: color.withValues(alpha: 0.15)),
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
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.cairo(fontSize: 12, color: Colors.white54),
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

  Widget _buildFinancialCard({
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
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.white54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          isLoading
              ? SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
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
                  color: isSelected
                      ? const Color(0xFFFFC107)
                      : Colors.transparent,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultDeviceIcon(order.device.type),
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
                      const Icon(
                        Icons.person_outline,
                        size: 18,
                        color: Colors.white54,
                      ),
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
                      icon: const Icon(
                        Icons.phone_enabled_outlined,
                        color: Color(0xFFFFC107),
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFFC107,
                        ).withValues(alpha: 0.1),
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () => _makeCall(order.client!.phone),
                    ),
                ],
              ),
              const Divider(color: Colors.white10, height: 24),
            ],

            // Delegate Info Row(s)
            ..._buildDelegateInfoRows(order),

            // Footer Row: Date & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
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
                    Builder(
                      builder: (context) {
                        final double centerPrice =
                            (order.financialSnapshot?.centerAmount ?? 0) > 0
                            ? order.financialSnapshot!.centerAmount
                            : ((order.financialSnapshot?.repairAmount ?? 0) > 0
                                ? order.financialSnapshot!.repairAmount
                                : (order.fees.repair > 0
                                      ? order.fees.repair
                                      : (order.fees.total > 0
                                            ? order.fees.total
                                            : (order.financialSnapshot?.clientTotal ?? 0))));
                        return Text(
                          '${centerPrice.toInt()} د.ع',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFC107),
                          ),
                        );
                      },
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

  List<Widget> _buildDelegateInfoRows(OrderEntity order) {
    final pickupDel = order.pickupDelegate ?? order.delegate;
    final deliveryDel = order.deliveryDelegate;

    final hasPickup = pickupDel != null && pickupDel.name.isNotEmpty;
    final hasDelivery = deliveryDel != null && deliveryDel.name.isNotEmpty;

    if (!hasPickup && !hasDelivery) {
      return [];
    }

    return [
      if (hasPickup)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Icon(Icons.two_wheeler, size: 16, color: Colors.greenAccent.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Text(
                'العميل → المركز: ',
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
              ),
              Expanded(
                child: Text(
                  pickupDel.name,
                  style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      if (hasDelivery)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Icon(Icons.local_shipping_outlined, size: 16, color: const Color(0xFFFFC107).withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Text(
                'المركز → العميل: ',
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
              ),
              Expanded(
                child: Text(
                  deliveryDel.name,
                  style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      const Divider(color: Colors.white10, height: 16),
    ];
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
        type.toLowerCase() == 'phone'
            ? Icons.phone_iphone_outlined
            : Icons.build_circle_outlined,
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
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 14,
                        color: Colors.white,
                      ),
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
class _CenterServicesView extends StatelessWidget {
  const _CenterServicesView();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MyCenterServicesCubit>()..fetchMyServices(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton.extended(
            backgroundColor: const Color(0xFFFFC107),
            foregroundColor: Colors.black,
            icon: const Icon(Icons.add),
            label: Text(
              'إضافة خدمة جديدة',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              final added = await Navigator.pushNamed(
                ctx,
                Routes.addCenterServiceRoute,
              );
              if (added == true) {
                if (ctx.mounted) {
                  ctx.read<MyCenterServicesCubit>().fetchMyServices();
                }
              }
            },
          ),
        ),
        body: BlocBuilder<MyCenterServicesCubit, MyCenterServicesState>(
          builder: (context, state) {
            if (state is MyCenterServicesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFC107)),
              );
            }

            if (state is MyCenterServicesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: GoogleFonts.cairo(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        'إعادة المحاولة',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => context
                          .read<MyCenterServicesCubit>()
                          .fetchMyServices(),
                    ),
                  ],
                ),
              );
            }

            if (state is MyCenterServicesLoaded) {
              final services = state.services;
              if (services.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<MyCenterServicesCubit>().fetchMyServices(),
                  color: const Color(0xFFFFC107),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.build_circle_outlined,
                              size: 64,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد خدمات مسجلة حالياً لمركز الصيانة',
                              style: GoogleFonts.cairo(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    context.read<MyCenterServicesCubit>().fetchMyServices(),
                color: const Color(0xFFFFC107),
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: service.isAvailable
                              ? const Color(0xFFFFC107).withValues(alpha: 0.2)
                              : Colors.white10,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.build,
                                    color: Color(0xFFFFC107),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    service.serviceName,
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: service.isAvailable
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  service.isAvailable ? 'متاحة' : 'غير متاحة',
                                  style: GoogleFonts.cairo(
                                    color: service.isAvailable
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (service.description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              service.description,
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const Divider(color: Colors.white10, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'السعر: ${service.price.toStringAsFixed(0)} د.ع',
                                style: GoogleFonts.cairo(
                                  color: const Color(0xFFFFC107),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (service.estimatedTime.isNotEmpty)
                                Text(
                                  'الوقت المقدر: ${service.estimatedTime}',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
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
                  backgroundColor: const Color(
                    0xFFFFC107,
                  ).withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.store,
                    color: Color(0xFFFFC107),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  centerName,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'رقم التعريف: #CTR-2026-A5',
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.white30),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFC107),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(120 تقييم)',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
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
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
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
                _buildProfileRow(
                  Icons.phone_outlined,
                  'الهاتف الرئيسي',
                  '01281221631',
                ),
                const Divider(color: Colors.white10, height: 24),
                _buildProfileRow(
                  Icons.location_on_outlined,
                  'العنوان بالتفصيل',
                  'بغداد - زيونة - شارع الربيعي',
                ),
                const Divider(color: Colors.white10, height: 24),
                _buildProfileRow(
                  Icons.access_time_rounded,
                  'أوقات العمل',
                  '09:00 ص - 10:00 م',
                ),
                const Divider(color: Colors.white10, height: 24),
                _buildProfileRow(
                  Icons.verified_user_outlined,
                  'نوع الحساب',
                  'شريك مركز صيانة معتمد',
                ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: Text(
                'تعديل ملف المركز',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _EditCenterProfileBottomSheet(initialName: centerName),
                );
              },
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
              Text(
                label,
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditCenterProfileBottomSheet extends StatefulWidget {
  final String initialName;

  const _EditCenterProfileBottomSheet({required this.initialName});

  @override
  State<_EditCenterProfileBottomSheet> createState() =>
      __EditCenterProfileBottomSheetState();
}

class __EditCenterProfileBottomSheetState
    extends State<_EditCenterProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initialName);
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UpdateCenterProfileCubit>(),
      child: BlocConsumer<UpdateCenterProfileCubit, UpdateCenterProfileState>(
        listener: (context, state) {
          if (state is UpdateCenterProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم تحديث ملف مركز الصيانة بنجاح',
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is UpdateCenterProfileFailure) {
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
        builder: (context, state) {
          final isLoading = state is UpdateCenterProfileLoading;
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF141414),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
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
                    const SizedBox(height: 16),
                    Text(
                      'تحديث بيانات مركز الصيانة',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: 'اسم المركز',
                      icon: Icons.store,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'يرجى إدخال اسم المركز'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'رقم الهاتف',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _emailController,
                      label: 'البريد الإلكتروني',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _addressController,
                      label: 'العنوان',
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context
                                      .read<UpdateCenterProfileCubit>()
                                      .updateCenterProfile(
                                        name: _nameController.text.trim(),
                                        phone: _phoneController.text.trim(),
                                        email: _emailController.text.trim(),
                                        address: _addressController.text.trim(),
                                      );
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                'حفظ التعديلات',
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFFFFC107), size: 20),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFC107)),
        ),
      ),
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
                const Icon(
                  Icons.help_center_rounded,
                  color: Colors.black87,
                  size: 64,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'الأسئلة الشائعة للشركاء',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),

          // FAQ items
          _buildFAQTile(
            'كيف يمكنني تغيير حالة صيانة الجهاز؟',
            'يمكنك فتح تفاصيل الطلب من لوحة التحكم، ومتابعة تحديثات الحالة ورفع الصور وتقارير الفحص والتقييم بسهولة بالضغط على تحديث الحالة.',
          ),
          _buildFAQTile(
            'كيف يتم تحصيل الأرباح ودخل الصيانة؟',
            'يتم احتساب دخل الصيانة الخاص بمركزك ودفعه لك بانتظام بعد إتمام الطلب وتوصيل الجهاز وإتمام دفعة العميل بنجاح.',
          ),
          _buildFAQTile(
            'كيف أقوم بتعطيل أو تفعيل خدمة صيانة معينة؟',
            'من القائمة الجانبية، اختر "إدارة الخدمات والأسعار" واستخدم زر التبديل لتفعيل أو تعطيل الخدمة مباشرة في تطبيق العميل.',
          ),

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
                  label: Text(
                    'اتصال بالهاتف',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
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
                  label: Text(
                    'محادثة واتساب',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    final Uri whatsapp = Uri.parse(
                      'https://wa.me/966501234568',
                    );
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
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                answer,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
