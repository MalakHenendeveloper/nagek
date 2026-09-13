import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/admin_settlements_report_entity.dart';
import '../../cubit/admin_settlements_report_cubit.dart';
import '../../cubit/admin_settlements_report_state.dart';

class AdminSettlementsReportView extends StatefulWidget {
  const AdminSettlementsReportView({super.key});

  @override
  State<AdminSettlementsReportView> createState() =>
      _AdminSettlementsReportViewState();
}

class _AdminSettlementsReportViewState
    extends State<AdminSettlementsReportView> {
  int _selectedTab = 0; // 0: Centers, 1: Delegates
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<AdminSettlementsReportCubit>().fetchReport();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString).toLocal();
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
      final monthName = months[date.month - 1];
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'م' : 'ص';
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.day} $monthName ${date.year} - $hour:$minute $period';
    } catch (_) {
      return isoString;
    }
  }

  void _confirmAndToggleSettlement({
    required String orderId,
    required String orderNumber,
    required String party,
    required String partyTitle,
    required bool currentSettled,
  }) {
    final willSettle = !currentSettled;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              willSettle ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: willSettle ? Colors.greenAccent : Colors.orangeAccent,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              willSettle ? 'تأكيد التسوية' : 'إلغاء التسوية',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          willSettle
              ? 'هل أنت متأكد من تسوية مستحق $partyTitle للطلب $orderNumber؟'
              : 'هل أنت متأكد من إلغاء تسوية مستحق $partyTitle للطلب $orderNumber؟',
          style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'تراجع',
              style: GoogleFonts.cairo(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AdminSettlementsReportCubit>().updateSettlement(
                    orderId: orderId,
                    party: party,
                    settled: willSettle,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: willSettle ? Colors.green : Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              willSettle ? 'نعم، تأكيد التسوية' : 'نعم، إلغاء التسوية',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<AdminSettlementsReportCubit, AdminSettlementsReportState>(
        listener: (context, state) {
          if (state is AdminSettlementsReportLoaded) {
            if (state.actionSuccessMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.actionSuccessMessage!,
                    style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.green[800],
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            if (state.actionErrorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.actionErrorMessage!,
                    style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.red[800],
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is AdminSettlementsReportLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC107)),
            );
          }

          if (state is AdminSettlementsReportError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: GoogleFonts.cairo(color: Colors.white70, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<AdminSettlementsReportCubit>().fetchReport(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
          }

          if (state is AdminSettlementsReportLoaded) {
            final report = state.report;
            final updatingKey = state.updatingKey;

            return RefreshIndicator(
              color: const Color(0xFFFFC107),
              backgroundColor: const Color(0xFF1E1E1E),
              onRefresh: () async {
                await context.read<AdminSettlementsReportCubit>().fetchReport();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Section
                    _buildSummaryCards(report.summary),
                    const SizedBox(height: 20),

                    // Search Field
                    _buildSearchBar(),
                    const SizedBox(height: 16),

                    // Segmented Tabs
                    _buildTabs(
                      centersCount: report.centers.length,
                      delegatesCount: report.delegates.length,
                    ),
                    const SizedBox(height: 16),

                    // Tab Content
                    if (_selectedTab == 0)
                      _buildCentersList(report.centers, updatingKey)
                    else
                      _buildDelegatesList(report.delegates, updatingKey),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryCards(AdminSettlementsSummaryReportEntity summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics_outlined, color: Color(0xFFFFC107), size: 20),
            const SizedBox(width: 8),
            Text(
              'ملخص التسويات المالية الشاملة',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Total Remaining Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2C1E00), Color(0xFF1E1600)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجمالي المتبقي غير المسدد',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${summary.totalRemaining.toInt()} د.ع',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFFFFC107),
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Centers & Delegates Summary Breakdown Grid
        Row(
          children: [
            Expanded(
              child: _buildSummaryMiniCard(
                title: 'مستحقات المراكز',
                totalDue: summary.centersTotalDue,
                settled: summary.centersTotalSettled,
                remaining: summary.centersRemaining,
                icon: Icons.storefront_rounded,
                accentColor: const Color(0xFF64B5F6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryMiniCard(
                title: 'مستحقات المناديب',
                totalDue: summary.delegatesTotalDue,
                settled: summary.delegatesTotalSettled,
                remaining: summary.delegatesRemaining,
                icon: Icons.delivery_dining_rounded,
                accentColor: const Color(0xFF81C784),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryMiniCard({
    required String title,
    required double totalDue,
    required double settled,
    required double remaining,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildMiniStatRow('المستحق:', '${totalDue.toInt()} د.ع', Colors.white70),
          const SizedBox(height: 4),
          _buildMiniStatRow('المسدد:', '${settled.toInt()} د.ع', Colors.greenAccent),
          const SizedBox(height: 4),
          _buildMiniStatRow('المتبقي:', '${remaining.toInt()} د.ع', const Color(0xFFFFC107), isBold: true),
        ],
      ),
    );
  }

  Widget _buildMiniStatRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 11, color: Colors.white38),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'ابحث بالاسم أو رقم الهاتف...',
          hintStyle: GoogleFonts.cairo(color: Colors.white30, fontSize: 12),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFFC107), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabs({required int centersCount, required int delegatesCount}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              index: 0,
              title: 'مراكز الصيانة',
              count: centersCount,
              icon: Icons.storefront_rounded,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton(
              index: 1,
              title: 'المندوبين',
              count: delegatesCount,
              icon: Icons.delivery_dining_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String title,
    required int count,
    required IconData icon,
  }) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFC107) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : Colors.white54,
            ),
            const SizedBox(width: 6),
            Text(
              '$title ($count)',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentersList(List<AdminCenterSettlementReportEntity> centers, String? updatingKey) {
    final filtered = centers.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.centerName.toLowerCase().contains(_searchQuery) ||
          c.phone.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyListState('لا توجد مراكز مطابقة للبحث');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final center = filtered[index];
        return _buildCenterCard(center, updatingKey);
      },
    );
  }

  Widget _buildCenterCard(AdminCenterSettlementReportEntity center, String? updatingKey) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Colors.white54,
          iconColor: const Color(0xFFFFC107),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF64B5F6).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront_rounded, color: Color(0xFF64B5F6), size: 22),
          ),
          title: Text(
            center.centerName.isNotEmpty ? center.centerName : 'مركز صيانة',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                if (center.phone.isNotEmpty) ...[
                  const Icon(Icons.phone_outlined, size: 12, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text(
                    center.phone,
                    style: GoogleFonts.cairo(fontSize: 11, color: Colors.white54),
                  ),
                  const SizedBox(width: 10),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${center.totalOrders} طلبات',
                    style: GoogleFonts.cairo(fontSize: 10, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'المتبقي',
                style: GoogleFonts.cairo(fontSize: 10, color: Colors.white38),
              ),
              Text(
                '${center.remaining.toInt()} د.ع',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: center.remaining > 0 ? const Color(0xFFFFC107) : Colors.greenAccent,
                ),
              ),
            ],
          ),
          children: [
            const Divider(color: Colors.white10, height: 16),
            // Financial Summary Bar for Center
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCenterStatItem('إجمالي المستحق', '${center.totalDue.toInt()} د.ع', Colors.white70),
                  Container(height: 24, width: 1, color: Colors.white10),
                  _buildCenterStatItem('المسدد', '${center.totalSettled.toInt()} د.ع', Colors.greenAccent),
                  Container(height: 24, width: 1, color: Colors.white10),
                  _buildCenterStatItem('المتبقي', '${center.remaining.toInt()} د.ع', const Color(0xFFFFC107)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Orders list
            if (center.orders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'لا توجد طلبات مسجلة لهذا المركز',
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
                ),
              )
            else ...[
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'تفاصيل طلبات المركز (${center.orders.length}):',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...center.orders.map((o) => _buildCenterOrderItem(o, updatingKey, center.centerName)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCenterStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 10, color: Colors.white38),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCenterOrderItem(
    AdminCenterOrderReportEntity order,
    String? updatingKey,
    String centerName,
  ) {
    final isUpdatingThis = updatingKey == '${order.orderId}-center';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_outlined, color: Color(0xFFFFC107), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderNumber.isNotEmpty ? order.orderNumber : 'طلب #${order.orderId}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (order.recordedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(order.recordedAt),
                    style: GoogleFonts.cairo(fontSize: 10, color: Colors.white38),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${order.amount.toInt()} د.ع',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFC107),
                ),
              ),
              const SizedBox(height: 4),
              isUpdatingThis
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFC107)),
                    )
                  : InkWell(
                      onTap: () => _confirmAndToggleSettlement(
                        orderId: order.orderId,
                        orderNumber: order.orderNumber,
                        party: 'center',
                        partyTitle: 'مركز الصيانة ($centerName)',
                        currentSettled: order.settled,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: order.settled
                              ? Colors.green.withValues(alpha: 0.15)
                              : const Color(0xFFFFC107).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: order.settled
                                ? Colors.green.withValues(alpha: 0.4)
                                : const Color(0xFFFFC107).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              order.settled ? Icons.check_circle : Icons.pending_actions_outlined,
                              size: 12,
                              color: order.settled ? Colors.greenAccent : const Color(0xFFFFC107),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.settled ? 'مسدد (إلغاء؟)' : 'تسوية الآن',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: order.settled ? Colors.greenAccent : const Color(0xFFFFC107),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDelegatesList(List<AdminDelegateSettlementReportEntity> delegates, String? updatingKey) {
    final filtered = delegates.where((d) {
      if (_searchQuery.isEmpty) return true;
      return d.name.toLowerCase().contains(_searchQuery) ||
          d.phone.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyListState('لا يوجد مناديب مطابقين للبحث');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final delegate = filtered[index];
        return _buildDelegateCard(delegate, updatingKey);
      },
    );
  }

  Widget _buildDelegateCard(AdminDelegateSettlementReportEntity delegate, String? updatingKey) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Colors.white54,
          iconColor: const Color(0xFFFFC107),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF81C784).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delivery_dining_rounded, color: Color(0xFF81C784), size: 22),
          ),
          title: Text(
            delegate.name.isNotEmpty ? delegate.name : 'مندوب توصيل',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                if (delegate.phone.isNotEmpty) ...[
                  const Icon(Icons.phone_outlined, size: 12, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text(
                    delegate.phone,
                    style: GoogleFonts.cairo(fontSize: 11, color: Colors.white54),
                  ),
                  const SizedBox(width: 10),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${delegate.pickupTrips} استلام • ${delegate.deliveryTrips} توصيل',
                    style: GoogleFonts.cairo(fontSize: 10, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'المتبقي',
                style: GoogleFonts.cairo(fontSize: 10, color: Colors.white38),
              ),
              Text(
                '${delegate.remaining.toInt()} د.ع',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: delegate.remaining > 0 ? const Color(0xFFFFC107) : Colors.greenAccent,
                ),
              ),
            ],
          ),
          children: [
            const Divider(color: Colors.white10, height: 16),
            // Delegate Financial Breakdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCenterStatItem('استلام', '${delegate.pickupDue.toInt()} د.ع', const Color(0xFF64B5F6)),
                  Container(height: 24, width: 1, color: Colors.white10),
                  _buildCenterStatItem('توصيل', '${delegate.deliveryDue.toInt()} د.ع', const Color(0xFFFFB74D)),
                  Container(height: 24, width: 1, color: Colors.white10),
                  _buildCenterStatItem('الإجمالي', '${delegate.totalDue.toInt()} د.ع', Colors.white70),
                  Container(height: 24, width: 1, color: Colors.white10),
                  _buildCenterStatItem('المتبقي', '${delegate.remaining.toInt()} د.ع', const Color(0xFFFFC107)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Trips list
            if (delegate.trips.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'لا توجد رحلات مسجلة لهذا المندوب',
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
                ),
              )
            else ...[
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'تفاصيل رحلات المندوب (${delegate.trips.length}):',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...delegate.trips.map((t) => _buildDelegateTripItem(t, updatingKey, delegate.name)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDelegateTripItem(
    AdminDelegateTripReportEntity trip,
    String? updatingKey,
    String delegateName,
  ) {
    final isPickup = trip.tripType.toLowerCase() == 'pickup';
    final partyType = isPickup ? 'pickup' : 'delivery';
    final isUpdatingThis = updatingKey == '${trip.orderId}-$partyType';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(
            isPickup ? Icons.two_wheeler : Icons.local_shipping_outlined,
            color: isPickup ? const Color(0xFF64B5F6) : const Color(0xFFFFB74D),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      trip.orderNumber.isNotEmpty ? trip.orderNumber : 'طلب #${trip.orderId}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isPickup
                            ? const Color(0xFF64B5F6).withValues(alpha: 0.15)
                            : const Color(0xFFFFB74D).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPickup ? 'استلام' : 'توصيل',
                        style: GoogleFonts.cairo(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isPickup ? const Color(0xFF64B5F6) : const Color(0xFFFFB74D),
                        ),
                      ),
                    ),
                  ],
                ),
                if (trip.recordedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(trip.recordedAt),
                    style: GoogleFonts.cairo(fontSize: 10, color: Colors.white38),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${trip.amount.toInt()} د.ع',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFC107),
                ),
              ),
              const SizedBox(height: 4),
              isUpdatingThis
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFC107)),
                    )
                  : InkWell(
                      onTap: () => _confirmAndToggleSettlement(
                        orderId: trip.orderId,
                        orderNumber: trip.orderNumber,
                        party: partyType,
                        partyTitle: 'مندوب ${isPickup ? "الاستلام" : "التوصيل"} ($delegateName)',
                        currentSettled: trip.settled,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: trip.settled
                              ? Colors.green.withValues(alpha: 0.15)
                              : const Color(0xFFFFC107).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: trip.settled
                                ? Colors.green.withValues(alpha: 0.4)
                                : const Color(0xFFFFC107).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              trip.settled ? Icons.check_circle : Icons.pending_actions_outlined,
                              size: 12,
                              color: trip.settled ? Colors.greenAccent : const Color(0xFFFFC107),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trip.settled ? 'مسدد (إلغاء؟)' : 'تسوية الآن',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: trip.settled ? Colors.greenAccent : const Color(0xFFFFC107),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyListState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.cairo(fontSize: 13, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}
