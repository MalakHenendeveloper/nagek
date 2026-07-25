import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../domain/entities/admin_settlements_summary_entity.dart';
import '../cubit/admin_settlements_summary_cubit.dart';
import '../cubit/admin_settlements_summary_state.dart';

class AdminSettlementsSummaryScreen extends StatelessWidget {
  const AdminSettlementsSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AdminSettlementsSummaryCubit>()..fetchSummary(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text(
            'ملخص التسويات المجمع (الإدارة)',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          foregroundColor: const Color(0xFFFFC107),
        ),
        body: const Directionality(
          textDirection: TextDirection.rtl,
          child: _AdminSettlementsSummaryBody(),
        ),
      ),
    );
  }
}

class _AdminSettlementsSummaryBody extends StatefulWidget {
  const _AdminSettlementsSummaryBody();

  @override
  State<_AdminSettlementsSummaryBody> createState() =>
      _AdminSettlementsSummaryBodyState();
}

class _AdminSettlementsSummaryBodyState
    extends State<_AdminSettlementsSummaryBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _translateRecipientType(String type) {
    switch (type.toLowerCase()) {
      case 'admin':
        return 'إدارة';
      case 'delegate':
        return 'مندوب';
      case 'center':
        return 'مركز صيانة';
      default:
        return type.isNotEmpty ? type : 'مستلم';
    }
  }

  Color _getRecipientColor(String type) {
    switch (type.toLowerCase()) {
      case 'admin':
        return const Color(0xFFFFC107);
      case 'delegate':
        return const Color(0xFF4CAF50);
      case 'center':
        return const Color(0xFF2196F3);
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AdminSettlementsSummaryCubit>();
    final currentRecipientType = cubit.currentRecipientType;
    final currentSortBy = cubit.currentSortBy;
    final currentSortOrder = cubit.currentSortOrder;

    return Column(
      children: [
        // Filter Header Panel
        Container(
          color: const Color(0xFF141414),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // 1. Search Bar
              TextField(
                controller: _searchController,
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'البحث باسم المستلم...',
                  hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 12),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFFFC107), size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            context.read<AdminSettlementsSummaryCubit>().fetchSummary(search: '', page: 1);
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: const Color(0xFF0F0F0F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
                onSubmitted: (val) {
                  context.read<AdminSettlementsSummaryCubit>().fetchSummary(search: val.trim(), page: 1);
                },
              ),

              const SizedBox(height: 10),

              // 2. Recipient Type Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'الجهة: ',
                      style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                    ),
                    _buildFilterChip('الكل', 'all', currentRecipientType, (val) {
                      context.read<AdminSettlementsSummaryCubit>().fetchSummary(recipientType: val, page: 1);
                    }),
                    const SizedBox(width: 6),
                    _buildFilterChip('إدارة', 'admin', currentRecipientType, (val) {
                      context.read<AdminSettlementsSummaryCubit>().fetchSummary(recipientType: val, page: 1);
                    }),
                    const SizedBox(width: 6),
                    _buildFilterChip('مندوب', 'delegate', currentRecipientType, (val) {
                      context.read<AdminSettlementsSummaryCubit>().fetchSummary(recipientType: val, page: 1);
                    }),
                    const SizedBox(width: 6),
                    _buildFilterChip('مركز', 'center', currentRecipientType, (val) {
                      context.read<AdminSettlementsSummaryCubit>().fetchSummary(recipientType: val, page: 1);
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 3. Sort By Options & Sort Order Toggle
              Row(
                children: [
                  Text(
                    'ترتيب حسب: ',
                    style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSortChip('إجمالي الأرباح', 'totalEarnings', currentSortBy, (val) {
                            context.read<AdminSettlementsSummaryCubit>().fetchSummary(sortBy: val, page: 1);
                          }),
                          const SizedBox(width: 6),
                          _buildSortChip('المبلغ المعلق', 'pendingAmount', currentSortBy, (val) {
                            context.read<AdminSettlementsSummaryCubit>().fetchSummary(sortBy: val, page: 1);
                          }),
                          const SizedBox(width: 6),
                          _buildSortChip('المبلغ المدفوع', 'paidAmount', currentSortBy, (val) {
                            context.read<AdminSettlementsSummaryCubit>().fetchSummary(sortBy: val, page: 1);
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        currentSortOrder == 'desc'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: const Color(0xFFFFC107),
                        size: 18,
                      ),
                      tooltip: currentSortOrder == 'desc' ? 'تنازلي (الأعلى أولاً)' : 'تصاعدي (الأقل أولاً)',
                      onPressed: () {
                        final newOrder = currentSortOrder == 'desc' ? 'asc' : 'desc';
                        context.read<AdminSettlementsSummaryCubit>().fetchSummary(sortOrder: newOrder, page: 1);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Summaries List Body
        Expanded(
          child: BlocBuilder<AdminSettlementsSummaryCubit, AdminSettlementsSummaryState>(
            builder: (context, state) {
              if (state is AdminSettlementsSummaryLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFC107)),
                );
              }

              if (state is AdminSettlementsSummaryError) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
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
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                          onPressed: () {
                            context.read<AdminSettlementsSummaryCubit>().fetchSummary();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is AdminSettlementsSummaryLoaded) {
                final summaries = state.summaries;
                final pagination = state.pagination;

                if (summaries.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<AdminSettlementsSummaryCubit>().fetchSummary(),
                    color: const Color(0xFFFFC107),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.pie_chart_outline,
                                color: Colors.white24,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد ملخصات مجمعة بالمواصفات المحددة',
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
                      context.read<AdminSettlementsSummaryCubit>().fetchSummary(),
                  color: const Color(0xFFFFC107),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: summaries.length,
                          itemBuilder: (context, index) {
                            final item = summaries[index];
                            return _buildRecipientSummaryCard(context, item);
                          },
                        ),
                      ),

                      // Pagination Controls
                      if (pagination.pages > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF141414),
                            border: Border(top: BorderSide(color: Colors.white10)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFC107),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.chevron_left, size: 18),
                                label: Text(
                                  'السابقة',
                                  style: GoogleFonts.cairo(fontSize: 12),
                                ),
                                onPressed: pagination.page > 1
                                    ? () {
                                        context
                                            .read<AdminSettlementsSummaryCubit>()
                                            .fetchSummary(page: pagination.page - 1);
                                      }
                                    : null,
                              ),
                              Text(
                                'صفحة ${pagination.page} من ${pagination.pages} (الإجمالي: ${pagination.total})',
                                style: GoogleFonts.cairo(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFC107),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.chevron_right, size: 18),
                                label: Text(
                                  'التالية',
                                  style: GoogleFonts.cairo(fontSize: 12),
                                ),
                                onPressed: pagination.page < pagination.pages
                                    ? () {
                                        context
                                            .read<AdminSettlementsSummaryCubit>()
                                            .fetchSummary(page: pagination.page + 1);
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String currentValue,
    Function(String) onSelect,
  ) {
    final isSelected = currentValue == value;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.cairo(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFFFC107),
      backgroundColor: Colors.white10,
      side: BorderSide(
        color: isSelected ? const Color(0xFFFFC107) : Colors.white24,
      ),
      onSelected: (selected) {
        if (selected) {
          onSelect(value);
        }
      },
    );
  }

  Widget _buildSortChip(
    String label,
    String value,
    String currentValue,
    Function(String) onSelect,
  ) {
    final isSelected = currentValue == value;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.cairo(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 10,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFFFC107),
      backgroundColor: Colors.white10,
      side: BorderSide(
        color: isSelected ? const Color(0xFFFFC107) : Colors.white12,
      ),
      onSelected: (selected) {
        if (selected) {
          onSelect(value);
        }
      },
    );
  }

  Widget _buildRecipientSummaryCard(
    BuildContext context,
    AdminSettlementRecipientSummaryEntity item,
  ) {
    final recipientColor = _getRecipientColor(item.recipientType);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: recipientColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name & Type Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: recipientColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.recipientType == 'delegate'
                          ? Icons.delivery_dining
                          : item.recipientType == 'center'
                              ? Icons.storefront
                              : Icons.admin_panel_settings,
                      color: recipientColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.recipientName.isNotEmpty ? item.recipientName : 'مستلم غير محدد',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${item.recipientId}',
                        style: GoogleFonts.cairo(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: recipientColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: recipientColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _translateRecipientType(item.recipientType),
                  style: GoogleFonts.cairo(
                    color: recipientColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white10, height: 1),
          ),

          // Total Earnings Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A2200), Color(0xFF141414)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إجمالي الأرباح المستحقة',
                  style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '${item.totalEarnings.toStringAsFixed(0)} د.ع',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFFFFC107),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Stats Grid Row (Pending Amount / Paid Amount / Pending Count / Paid Count)
          Row(
            children: [
              Expanded(
                child: _buildSubStatBox(
                  title: 'مبالغ معلقة',
                  value: '${item.pendingAmount.toStringAsFixed(0)} د.ع',
                  countLabel: '${item.pendingSettlementsCount} تسوية معلقة',
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSubStatBox(
                  title: 'مبالغ مدفوعة',
                  value: '${item.paidAmount.toStringAsFixed(0)} د.ع',
                  countLabel: '${item.paidSettlementsCount} تسوية مدفوعة',
                  color: Colors.greenAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubStatBox({
    required String title,
    required String value,
    required String countLabel,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            countLabel,
            style: GoogleFonts.cairo(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
