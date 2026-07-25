import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/routes_manager/routes.dart';
import '../../../orders/presentation/cubit/delegate_orders_cubit.dart';
import '../../../orders/presentation/cubit/delegate_orders_state.dart';
import '../../../orders/presentation/cubit/delegate_dashboard_cubit.dart';
import '../../../orders/presentation/cubit/delegate_dashboard_state.dart';
import '../widgets/delegate_dashboard_drawer.dart';

class DelegateHome extends StatelessWidget {
  const DelegateHome({super.key});

  Future<void> _logout(BuildContext context) async {
    await getIt<SecureStorageService>().clearAuth();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.loginRoute, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<DelegateOrdersCubit>()..fetchDelegateOrders(),
        ),
        BlocProvider(
          create: (context) => getIt<DelegateDashboardCubit>()..fetchDelegateDashboard(),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        drawer: const DelegateDashboardDrawer(),
        appBar: AppBar(
          title: Text(
            'شاشة المندوب',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFFFFC107)),
              tooltip: 'فتح القائمة الجانبية',
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.insights, color: Color(0xFFFFC107)),
                tooltip: 'إحصائيات المندوب',
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              tooltip: 'تسجيل الخروج',
              onPressed: () => _logout(context),
            ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: FutureBuilder<String?>(
            future: getIt<SecureStorageService>().getUserName(),
            builder: (context, nameSnapshot) {
              final name = nameSnapshot.data ?? 'المندوب';
              return BlocBuilder<DelegateDashboardCubit, DelegateDashboardState>(
                builder: (context, dashState) {
                  return BlocBuilder<DelegateOrdersCubit, DelegateOrdersState>(
                    builder: (context, ordersState) {
                      // Dashboard data (from API)
                      double totalEarnings = 0.0;
                      int totalTripsCount = 0;
                      int pickupTripsCount = 0;
                      int deliveryTripsCount = 0;
                      bool isDashLoading = dashState is DelegateDashboardLoading;

                      if (dashState is DelegateDashboardLoaded) {
                        final summary = dashState.dashboard.summary;
                        totalEarnings = summary.totalEarnings;
                        totalTripsCount = summary.totalTripsCount;
                        pickupTripsCount = summary.pickupTripsCount;
                        deliveryTripsCount = summary.deliveryTripsCount;
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<DelegateOrdersCubit>().fetchDelegateOrders();
                          context.read<DelegateDashboardCubit>().fetchDelegateDashboard();
                        },
                        color: const Color(0xFFFFC107),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Welcome Section
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.local_shipping,
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
                                          'مرحباً بك يا كابتن $name',
                                          style: GoogleFonts.cairo(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'لوحة التحكم ومتابعة الطلبات المخصصة لك',
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

                              // Open Delegate Earnings Screen Shortcut Card
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, Routes.delegateEarningsRoute);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF332600), Color(0xFF141414)],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFFFC107).withValues(alpha: 0.5),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFC107).withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.account_balance_wallet,
                                          color: Color(0xFFFFC107),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'شاشة أرباح المندوب',
                                              style: GoogleFonts.cairo(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'عرض سجل الأرباح التفصيلي ورحلات الاستلام والتسليم',
                                              style: GoogleFonts.cairo(
                                                color: Colors.white54,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Color(0xFFFFC107),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Dashboard Stats Title
                              Text(
                                'ملخص الأداء والرحلات',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Row 1: Total Earnings & Total Trips
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'إجمالي الأرباح',
                                      value: '${totalEarnings.toStringAsFixed(0)} د.ع',
                                      icon: Icons.account_balance_wallet_outlined,
                                      color: const Color(0xFFFFC107),
                                      isLoading: isDashLoading,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'إجمالي الرحلات',
                                      value: '$totalTripsCount رحلة',
                                      icon: Icons.route_outlined,
                                      color: Colors.greenAccent,
                                      isLoading: isDashLoading,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Row 2: Pickup Trips & Delivery Trips
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'رحلات الاستلام',
                                      value: '$pickupTripsCount استلام',
                                      icon: Icons.archive_outlined,
                                      color: Colors.cyanAccent,
                                      isLoading: isDashLoading,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'رحلات التسليم',
                                      value: '$deliveryTripsCount تسليم',
                                      icon: Icons.local_shipping_outlined,
                                      color: Colors.purpleAccent,
                                      isLoading: isDashLoading,
                                    ),
                                  ),
                                ],
                              ),

                              if (dashState is DelegateDashboardError) ...[
                                const SizedBox(height: 12),
                                Text(
                                  '⚠️ حدث خطأ أثناء تحديث الإحصائيات: ${dashState.message}',
                                  style: GoogleFonts.cairo(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              if (ordersState is DelegateOrdersError) ...[
                                const SizedBox(height: 12),
                                Text(
                                  '⚠️ خطأ في تحميل الطلبات: ${ordersState.message}',
                                  style: GoogleFonts.cairo(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 36),

                              // Navigation Actions Title
                              Text(
                                'المهام والتوصيل',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Button 1: My Active Tasks
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC107),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.assignment),
                                  label: Text(
                                    'مهامي النشطة (طلباتي المقبولة)',
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () async {
                                    await Navigator.pushNamed(context, Routes.delegateTasksRoute);
                                    if (context.mounted) {
                                      context.read<DelegateOrdersCubit>().fetchDelegateOrders();
                                      context.read<DelegateDashboardCubit>().fetchDelegateDashboard();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Button 2: Available Pickup Orders
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFFFC107),
                                    side: const BorderSide(color: Color(0xFFFFC107), width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(Icons.search),
                                  label: Text(
                                    'عرض الطلبات النشطة المتاحة للجميع',
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      Routes.delegateAvailableOrdersRoute,
                                    );
                                    if (context.mounted) {
                                      context.read<DelegateOrdersCubit>().fetchDelegateOrders();
                                      context.read<DelegateDashboardCubit>().fetchDelegateDashboard();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Button 3: Delegate Settlements List
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white24, width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(Icons.receipt_long, color: Color(0xFFFFC107)),
                                  label: Text(
                                    'سجل التسويات المالية للمندوب',
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, Routes.delegateSettlementsRoute);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
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
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 4),
          isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
        ],
      ),
    );
  }
}
