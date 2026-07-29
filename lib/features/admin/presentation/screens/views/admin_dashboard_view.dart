import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/admin_dashboard_entity.dart';
import '../../cubit/admin_dashboard_cubit.dart';
import '../../cubit/admin_dashboard_state.dart';
import '../admin_financial_breakdown_screen.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '';
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
        'ديسمبر'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year} (${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')})';
    } catch (e) {
      return isoString;
    }
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'paid':
        return 'تم الدفع';
      case 'completed':
        return 'مكتمل';
      case 'approved':
        return 'مقبول';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'cancelled':
        return 'ملغي';
      default:
        return status.isNotEmpty ? status : 'معلق';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'approved':
        return Colors.greenAccent;
      case 'pending':
      case 'in_progress':
        return const Color(0xFFFFC107);
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFFC107),
            ),
          );
        } else if (state is AdminDashboardError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: GoogleFonts.cairo(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      context.read<AdminDashboardCubit>().fetchDashboardStats();
                    },
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
        } else if (state is AdminDashboardLoaded) {
          final dashboard = state.dashboard;

          return RefreshIndicator(
            color: const Color(0xFFFFC107),
            onRefresh: () async {
              await context.read<AdminDashboardCubit>().fetchDashboardStats();
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // 1. Welcome Banner Header
                _buildWelcomeHeader(context),

                const SizedBox(height: 24),

                // 2. Orders Summary Section
                _buildOrdersSummarySection(dashboard.orders),

                const SizedBox(height: 24),

                // 3. Financial Summary Section
                _buildFinancialSummarySection(dashboard.financial),

                const SizedBox(height: 24),

                // 4. Users Breakdown Section
                _buildUsersSection(dashboard.users),

                const SizedBox(height: 24),

                // 5. Recent Activity Section
                _buildRecentActivitySection(dashboard.recentActivity),

                const SizedBox(height: 24),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E2400), Color(0xFF141414)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFC107).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لوحة إحصائيات الإدارة الشاملة',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'متابعة فورية للطلبات، المحفظة والمدفوعات، وإيرادات الكيانات.',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFFC107), size: 28),
            tooltip: 'تحديث البيانات',
            onPressed: () {
              context.read<AdminDashboardCubit>().fetchDashboardStats();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSummarySection(AdminOrdersSummaryEntity orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.shopping_bag_outlined, color: Color(0xFFFFC107), size: 20),
            const SizedBox(width: 8),
            Text(
              'ملخص طلبات النظام',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Featured Total Orders Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجمالي طلبات النظام',
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${orders.totalOrders} أوردر',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF2196F3),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Color(0xFF2196F3),
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 4 Status Grid Cards
        Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                title: 'قيد الانتظار',
                value: '${orders.pendingOrders}',
                icon: Icons.hourglass_empty,
                color: const Color(0xFFFFC107),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniStatCard(
                title: 'قيد التنفيذ',
                value: '${orders.inProgressOrders}',
                icon: Icons.engineering_outlined,
                color: Colors.cyanAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                title: 'طلبات مكتملة',
                value: '${orders.completedOrders}',
                icon: Icons.task_alt,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniStatCard(
                title: 'طلبات ملغاة',
                value: '${orders.cancelledOrders}',
                icon: Icons.cancel_outlined,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialSummarySection(AdminFinancialSummaryEntity financial) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                color: Color(0xFFFFC107), size: 20),
            const SizedBox(width: 8),
            Text(
              'الملخص المالي والمدفوعات',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 1. Total Client Payments Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1B0A), Color(0xFF141414)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إجمالي مدفوعات العملاء',
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    '${financial.totalClientPayments.toStringAsFixed(0)} د.ع',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFFFC107),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Colors.white10, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: Colors.greenAccent, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'مؤكدة: ${financial.confirmedClientPayments.toStringAsFixed(0)} د.ع',
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.hourglass_top,
                          color: Colors.orangeAccent, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'معلقة: ${financial.pendingClientPayments.toStringAsFixed(0)} د.ع',
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Revenue & Commission Breakdown
        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                title: 'عمولة الإدارة',
                value: '${financial.totalAdminCommission.toStringAsFixed(0)} د.ع',
                icon: Icons.monetization_on_outlined,
                color: const Color(0xFFFFC107),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFinancialCard(
                title: 'إيرادات المراكز',
                value: '${financial.totalCenterRevenue.toStringAsFixed(0)} د.ع',
                icon: Icons.storefront_outlined,
                color: Colors.orangeAccent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                title: 'أرباح المندوبين',
                value: '${financial.totalDelegateEarnings.toStringAsFixed(0)} د.ع',
                icon: Icons.two_wheeler_outlined,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Navigate to detailed breakdown
        Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminFinancialBreakdownScreen(financial: financial),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B0A), Color(0xFF141414)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bar_chart_outlined, color: Color(0xFFFFC107), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'عرض التفاصيل المالية الكاملة',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFFFC107),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios, color: Color(0xFFFFC107), size: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersSection(AdminUsersSummaryEntity users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_outline, color: Color(0xFFFFC107), size: 20),
            const SizedBox(width: 8),
            Text(
              'المستخدمون والكيانات',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                title: 'العملاء',
                value: '${users.totalClients}',
                icon: Icons.person_outline,
                color: const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniStatCard(
                title: 'المندوبون',
                value: '${users.totalDelegates}',
                icon: Icons.delivery_dining,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniStatCard(
                title: 'المراكز',
                value: '${users.totalCenters}',
                icon: Icons.build_circle_outlined,
                color: const Color(0xFFFF9800),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(AdminRecentActivityEntity activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: Color(0xFFFFC107), size: 20),
            const SizedBox(width: 8),
            Text(
              'أحدث النشاطات في النظام',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Recent Orders Sub-Section
        Text(
          'أحدث طلبات الصيانة',
          style: GoogleFonts.cairo(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (activity.recentOrders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'لا توجد طلبات حديثة',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12),
            ),
          )
        else
          Column(
            children: activity.recentOrders
                .map((order) => _buildOrderCard(order))
                .toList(),
          ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(AdminRecentOrderEntity order) {
    final statusColor = _getStatusColor(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderNumber,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _translateStatus(order.status),
                  style: GoogleFonts.cairo(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'العميل: ${order.clientName.isNotEmpty ? order.clientName : "غير معروف"}',
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11),
              ),
              if (order.repairCenterName != null && order.repairCenterName!.isNotEmpty)
                Text(
                  'المركز: ${order.repairCenterName}',
                  style: GoogleFonts.cairo(color: const Color(0xFFFFC107), fontSize: 11),
                ),
            ],
          ),
          if (order.createdAt.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _formatDate(order.createdAt),
              style: GoogleFonts.cairo(color: Colors.white38, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}
