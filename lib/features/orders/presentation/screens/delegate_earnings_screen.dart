import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../domain/entities/delegate_dashboard_entity.dart';
import '../cubit/delegate_dashboard_cubit.dart';
import '../cubit/delegate_dashboard_state.dart';

class DelegateEarningsScreen extends StatelessWidget {
  const DelegateEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DelegateDashboardCubit>()..fetchDelegateDashboard(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text(
            'أرباح المندوب',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          foregroundColor: const Color(0xFFFFC107),
        ),
        body: const Directionality(
          textDirection: TextDirection.rtl,
          child: _DelegateEarningsBody(),
        ),
      ),
    );
  }
}

class _DelegateEarningsBody extends StatelessWidget {
  const _DelegateEarningsBody();

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString);
      final months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  String _translateTripType(String tripType) {
    switch (tripType.toLowerCase()) {
      case 'pickup':
        return 'استلام';
      case 'delivery':
        return 'تسليم';
      default:
        return tripType.isNotEmpty ? tripType : 'رحلة';
    }
  }

  Color _getTripTypeColor(String tripType) {
    switch (tripType.toLowerCase()) {
      case 'delivery':
        return Colors.greenAccent;
      case 'pickup':
        return Colors.cyanAccent;
      default:
        return Colors.white70;
    }
  }

  IconData _getTripTypeIcon(String tripType) {
    switch (tripType.toLowerCase()) {
      case 'delivery':
        return Icons.local_shipping_outlined;
      case 'pickup':
        return Icons.archive_outlined;
      default:
        return Icons.swap_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DelegateDashboardCubit, DelegateDashboardState>(
      builder: (context, state) {
        if (state is DelegateDashboardLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          );
        }

        if (state is DelegateDashboardError) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(color: Colors.redAccent, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.refresh),
                    label: Text('إعادة المحاولة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      context.read<DelegateDashboardCubit>().fetchDelegateDashboard();
                    },
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DelegateDashboardLoaded) {
          final summary = state.dashboard.summary;
          final earningHistory = state.dashboard.earningHistory;

          return RefreshIndicator(
            onRefresh: () => context.read<DelegateDashboardCubit>().fetchDelegateDashboard(),
            color: const Color(0xFFFFC107),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Earnings Card ──
                  _buildTotalEarningsHeroCard(summary.totalEarnings),

                  const SizedBox(height: 20),

                  // ── Trip Stats Title ──
                  Text(
                    'ملخص الرحلات',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Trip Stats Grid ──
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'إجمالي الرحلات',
                          value: '${summary.totalTripsCount}',
                          unit: 'رحلة',
                          icon: Icons.route_outlined,
                          color: const Color(0xFFFFC107),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'رحلات الاستلام',
                          value: '${summary.pickupTripsCount}',
                          unit: 'استلام',
                          icon: Icons.archive_outlined,
                          color: Colors.cyanAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'رحلات التسليم',
                          value: '${summary.deliveryTripsCount}',
                          unit: 'تسليم',
                          icon: Icons.local_shipping_outlined,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 28),

                  // ── Earning History Title ──
                  Text(
                    'سجل الأرباح (${earningHistory.length})',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (earningHistory.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.history_outlined, color: Colors.white24, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'لا توجد أرباح مسجلة حتى الآن',
                            style: GoogleFonts.cairo(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: earningHistory.length,
                      itemBuilder: (context, index) {
                        return _buildEarningHistoryCard(context, earningHistory[index]);
                      },
                    ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ── Hero Card ──
  Widget _buildTotalEarningsHeroCard(double totalEarnings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF332600), Color(0xFF1F1A00), Color(0xFF141414)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Color(0xFFFFC107), size: 26),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'إجمالي الأرباح',
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'محدّث',
                  style: GoogleFonts.cairo(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                totalEarnings.toStringAsFixed(0),
                style: GoogleFonts.cairo(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFFFFC107), height: 1.0),
              ),
              const SizedBox(width: 8),
              Text(
                'د.ع',
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'مجموع الأرباح المكتسبة من رحلات الاستلام والتسليم.',
            style: GoogleFonts.cairo(fontSize: 11, color: Colors.white38, height: 1.3),
          ),
        ],
      ),
    );
  }

  // ── Metric Card ──
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(unit, style: GoogleFonts.cairo(fontSize: 11, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.cairo(fontSize: 12, color: Colors.white54)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // ── Earning History Card ──
  Widget _buildEarningHistoryCard(BuildContext context, DelegateEarningHistoryEntity item) {
    final tripColor = _getTripTypeColor(item.tripType);
    final tripIcon = _getTripTypeIcon(item.tripType);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tripColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // Row 1: Order Number + Trip Type Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.receipt_outlined, color: const Color(0xFFFFC107), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.orderNumber,
                            style: GoogleFonts.cairo(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: tripColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: tripColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tripIcon, color: tripColor, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          _translateTripType(item.tripType),
                          style: GoogleFonts.cairo(color: tripColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Colors.white10, height: 1),
              ),

              // Row 2: Label (route description)
              Row(
                children: [
                  const Icon(Icons.swap_horiz, color: Colors.white38, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.label,
                      style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Row 3: Client Name
              Row(
                children: [
                  const Icon(Icons.person_outline, color: Colors.white38, size: 14),
                  const SizedBox(width: 4),
                  Text('العميل: ', style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12)),
                  Text(
                    item.clientName.isNotEmpty ? item.clientName : 'غير محدد',
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Row 4: Amount + Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Amount
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: item.amount > 0
                          ? const Color(0xFFFFC107).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: item.amount > 0
                            ? const Color(0xFFFFC107).withValues(alpha: 0.4)
                            : Colors.white12,
                      ),
                    ),
                    child: Text(
                      item.amount > 0 ? '+${item.amount.toStringAsFixed(0)} د.ع' : '0 د.ع',
                      style: GoogleFonts.cairo(
                        color: item.amount > 0 ? const Color(0xFFFFC107) : Colors.white38,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Date
                  if (item.completedAt.isNotEmpty)
                    Text(
                      _formatDate(item.completedAt),
                      style: GoogleFonts.cairo(color: Colors.white38, fontSize: 10),
                    ),
                ],
              ),
            ],
          ),
        );
      }
}
