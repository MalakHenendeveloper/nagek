import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/admin_dashboard_cubit.dart';
import '../../cubit/admin_dashboard_state.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

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
                      color: Colors.white70,
                      fontSize: 16,
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
          final totalAll = state.totalUsers + state.totalDelegates + state.totalCenters;

          return RefreshIndicator(
            color: const Color(0xFFFFC107),
            onRefresh: () async {
              await context.read<AdminDashboardCubit>().fetchDashboardStats();
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Welcome banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1E1E), Color(0xFF141414)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نظرة عامة على النظام',
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'تابع آخر الإحصائيات والأرقام الخاصة بالمستخدمين والمندوبين ومراكز الصيانة المسجلة.',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.analytics_outlined,
                          color: Color(0xFFFFC107),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stat Cards Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isTablet = constraints.maxWidth > 600;
                    return GridView.count(
                      crossAxisCount: isTablet ? 3 : 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isTablet ? 1.3 : 2.5,
                      children: [
                        _buildStatCard(
                          title: 'إجمالي المستخدمين',
                          value: state.totalUsers.toString(),
                          icon: Icons.people_alt_outlined,
                          glowColor: const Color(0xFF2196F3),
                          subtitle: 'العملاء وممثلي المراكز',
                        ),
                        _buildStatCard(
                          title: 'إجمالي المندوبين',
                          value: state.totalDelegates.toString(),
                          icon: Icons.delivery_dining_outlined,
                          glowColor: const Color(0xFF4CAF50),
                          subtitle: 'مناديب التوصيل والاستلام',
                        ),
                        _buildStatCard(
                          title: 'مراكز الصيانة',
                          value: state.totalCenters.toString(),
                          icon: Icons.build_circle_outlined,
                          glowColor: const Color(0xFFFF9800),
                          subtitle: 'الورش ومراكز الخدمة المعتمدة',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Distribution Chart / Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white10,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نسبة توزيع الكيانات في النظام',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (totalAll == 0)
                        Center(
                          child: Text(
                            'لا توجد بيانات كافية',
                            style: GoogleFonts.cairo(color: Colors.grey),
                          ),
                        )
                      else ...[
                        // Custom stacked horizontal progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: 16,
                            child: Row(
                              children: [
                                if (state.totalUsers > 0)
                                  Expanded(
                                    flex: state.totalUsers,
                                    child: Container(color: const Color(0xFF2196F3)),
                                  ),
                                if (state.totalDelegates > 0)
                                  Expanded(
                                    flex: state.totalDelegates,
                                    child: Container(color: const Color(0xFF4CAF50)),
                                  ),
                                if (state.totalCenters > 0)
                                  Expanded(
                                    flex: state.totalCenters,
                                    child: Container(color: const Color(0xFFFF9800)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLegendItem(
                              label: 'المستخدمون',
                              count: state.totalUsers,
                              percent: (state.totalUsers / totalAll * 100).toStringAsFixed(1),
                              color: const Color(0xFF2196F3),
                            ),
                            _buildLegendItem(
                              label: 'المندوبون',
                              count: state.totalDelegates,
                              percent: (state.totalDelegates / totalAll * 100).toStringAsFixed(1),
                              color: const Color(0xFF4CAF50),
                            ),
                            _buildLegendItem(
                              label: 'المراكز',
                              count: state.totalCenters,
                              percent: (state.totalCenters / totalAll * 100).toStringAsFixed(1),
                              color: const Color(0xFFFF9800),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color glowColor,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: glowColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    color: Colors.white30,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: glowColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: glowColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required String label,
    required int count,
    required String percent,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$count ($percent%)',
          style: GoogleFonts.cairo(
            color: Colors.white38,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
