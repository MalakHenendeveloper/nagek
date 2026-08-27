import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/admin_dashboard_entity.dart';

class AdminFinancialBreakdownScreen extends StatefulWidget {
  final AdminFinancialSummaryEntity financial;

  const AdminFinancialBreakdownScreen({super.key, required this.financial});

  @override
  State<AdminFinancialBreakdownScreen> createState() =>
      _AdminFinancialBreakdownScreenState();
}

class _AdminFinancialBreakdownScreenState
    extends State<AdminFinancialBreakdownScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F12),
        appBar: AppBar(
          backgroundColor: const Color(0xFF16161C),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            'التفاصيل المالية والتقارير',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              height: 44,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF22222B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(9),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white60,
                labelStyle: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'المندوبين'),
                  Tab(text: 'مراكز الصيانة'),
                  Tab(text: 'الإدارة'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDelegateTab(),
            _buildCenterTab(),
            _buildAdminTab(),
          ],
        ),
      ),
    );
  }

  // ─── Delegate Tab ───────────────────────────────────────────────────

  Widget _buildDelegateTab() {
    final delegates = widget.financial.delegateBreakdown;
    return Column(
      children: [
        Expanded(
          child: delegates.isEmpty
              ? _buildEmptyState('لا توجد بيانات مندوبين حالياً', Icons.two_wheeler_outlined)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: delegates.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final del = delegates[index];
                    return _buildListItem(
                      title: del.name,
                      subtitle: '${del.completedTrips} رحلة مكتملة',
                      amount: del.earnings,
                      icon: Icons.two_wheeler_outlined,
                      accentColor: const Color(0xFF4CAF50),
                    );
                  },
                ),
        ),
        _buildBottomTotalBar(
          label: 'إجمالي مستحقات المندوبين',
          totalAmount: widget.financial.totalDelegateEarnings,
          icon: Icons.two_wheeler_outlined,
          color: const Color(0xFF4CAF50),
        ),
      ],
    );
  }

  // ─── Center Tab ─────────────────────────────────────────────────────

  Widget _buildCenterTab() {
    final centers = widget.financial.centerBreakdown;
    return Column(
      children: [
        Expanded(
          child: centers.isEmpty
              ? _buildEmptyState('لا توجد بيانات مراكز صيانة حالياً', Icons.storefront_outlined)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: centers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final center = centers[index];
                    return _buildListItem(
                      title: center.centerName,
                      subtitle: '${center.completedOrders} طلب مكتمل',
                      amount: center.revenue,
                      icon: Icons.storefront_outlined,
                      accentColor: const Color(0xFFFF9800),
                    );
                  },
                ),
        ),
        _buildBottomTotalBar(
          label: 'إجمالي إيرادات مراكز الصيانة',
          totalAmount: widget.financial.totalCenterRevenue,
          icon: Icons.storefront_outlined,
          color: const Color(0xFFFF9800),
        ),
      ],
    );
  }

  // ─── Admin Tab ──────────────────────────────────────────────────────

  Widget _buildAdminTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('مدفوعات العملاء'),
              const SizedBox(height: 8),
              _buildSummaryRow('إجمالي المدفوعات', widget.financial.totalClientPayments, Colors.white),
              _buildSummaryRow('مدفوعات مؤكدة', widget.financial.confirmedClientPayments, const Color(0xFF4CAF50)),
              _buildSummaryRow('مدفوعات معلقة', widget.financial.pendingClientPayments, const Color(0xFFFFB300)),
              
              const SizedBox(height: 20),
              _buildSectionHeader('التوزيع المالي والعمولات'),
              const SizedBox(height: 8),
              _buildSummaryRow('عمولة الإدارة الصافية', widget.financial.totalAdminCommission, const Color(0xFFFFC107)),
              _buildSummaryRow('إجمالي إيرادات المراكز', widget.financial.totalCenterRevenue, const Color(0xFFFF9800)),
              _buildSummaryRow('إجمالي مستحقات المندوبين', widget.financial.totalDelegateEarnings, const Color(0xFF4CAF50)),

              /*
              const SizedBox(height: 20),
              _buildSectionHeader('التسويات المالية'),
              const SizedBox(height: 8),
              _buildSummaryRow('تسويات مدفوعة', widget.financial.paidSettlementsAmount, const Color(0xFF81C784)),
              _buildSummaryRow('تسويات معلقة', widget.financial.pendingSettlementsAmount, const Color(0xFFBA68C8)),
              */
            ],
          ),
        ),
        _buildBottomTotalBar(
          label: 'إجمالي صافي ربح الإدارة',
          totalAmount: widget.financial.totalAdminCommission,
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFFFFC107),
        ),
      ],
    );
  }

  // ─── Helper UI Components ──────────────────────────────────────────

  Widget _buildListItem({
    required String title,
    required String subtitle,
    required double amount,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF18181E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${amount.toStringAsFixed(0)} د.ع',
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF18181E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(0)} د.ع',
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTotalBar({
    required String label,
    required double totalAmount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161C),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '${totalAmount.toStringAsFixed(0)} د.ع',
              style: GoogleFonts.cairo(
                color: const Color(0xFFFFC107),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white24, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.cairo(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
