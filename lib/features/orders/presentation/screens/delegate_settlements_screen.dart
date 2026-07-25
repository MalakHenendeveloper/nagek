import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../domain/entities/delegate_settlement_entity.dart';
import '../cubit/delegate_settlements_cubit.dart';
import '../cubit/delegate_settlements_state.dart';

class DelegateSettlementsScreen extends StatelessWidget {
  const DelegateSettlementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DelegateSettlementsCubit>()..fetchSettlements(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text(
            'التسويات المالية للمندوب',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          foregroundColor: const Color(0xFFFFC107),
        ),
        body: const Directionality(
          textDirection: TextDirection.rtl,
          child: _DelegateSettlementsBody(),
        ),
      ),
    );
  }
}

class _DelegateSettlementsBody extends StatefulWidget {
  const _DelegateSettlementsBody();

  @override
  State<_DelegateSettlementsBody> createState() => _DelegateSettlementsBodyState();
}

class _DelegateSettlementsBodyState extends State<_DelegateSettlementsBody> {
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;

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

  String _formatDateOnly(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _translateStage(String stage) {
    switch (stage.toLowerCase()) {
      case 'pickup':
        return 'استلام';
      case 'delivery':
        return 'تسليم';
      default:
        return stage.isNotEmpty ? stage : 'توصيل';
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
      default:
        return status.isNotEmpty ? status : 'معلق';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.greenAccent;
      case 'pending':
        return const Color(0xFFFFC107);
      default:
        return Colors.white70;
    }
  }

  Future<void> _pickFromDate(BuildContext context) async {
    final cubit = context.read<DelegateSettlementsCubit>();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedFromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFC107),
              onPrimary: Colors.black,
              surface: Color(0xFF141414),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _selectedFromDate = picked;
      });
      cubit.fetchSettlements(
        dateFrom: _formatDateOnly(picked),
        page: 1,
      );
    }
  }

  Future<void> _pickToDate(BuildContext context) async {
    final cubit = context.read<DelegateSettlementsCubit>();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedToDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFC107),
              onPrimary: Colors.black,
              surface: Color(0xFF141414),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _selectedToDate = picked;
      });
      cubit.fetchSettlements(
        dateTo: _formatDateOnly(picked),
        page: 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DelegateSettlementsCubit>();
    final currentStatus = cubit.currentStatus;
    final currentSort = cubit.currentSort;

    return Column(
      children: [
        // Filter Header Panel
        Container(
          color: const Color(0xFF141414),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // 1. Status Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatusChip('الكل', 'all', currentStatus),
                    const SizedBox(width: 8),
                    _buildStatusChip('قيد الانتظار', 'pending', currentStatus),
                    const SizedBox(width: 8),
                    _buildStatusChip('تم الدفع', 'paid', currentStatus),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 2. Date Pickers & Sort Toggle Row
              Row(
                children: [
                  // From Date Button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _selectedFromDate != null
                            ? const Color(0xFFFFC107)
                            : Colors.white60,
                        side: BorderSide(
                          color: _selectedFromDate != null
                              ? const Color(0xFFFFC107)
                              : Colors.white24,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.calendar_today, size: 14),
                      label: Text(
                        _selectedFromDate != null
                            ? _formatDateOnly(_selectedFromDate!)
                            : 'من تاريخ',
                        style: GoogleFonts.cairo(fontSize: 11),
                      ),
                      onPressed: () => _pickFromDate(context),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // To Date Button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _selectedToDate != null
                            ? const Color(0xFFFFC107)
                            : Colors.white60,
                        side: BorderSide(
                          color: _selectedToDate != null
                              ? const Color(0xFFFFC107)
                              : Colors.white24,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.event, size: 14),
                      label: Text(
                        _selectedToDate != null
                            ? _formatDateOnly(_selectedToDate!)
                            : 'إلى تاريخ',
                        style: GoogleFonts.cairo(fontSize: 11),
                      ),
                      onPressed: () => _pickToDate(context),
                    ),
                  ),

                  if (_selectedFromDate != null || _selectedToDate != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.redAccent, size: 18),
                      tooltip: 'مسح التواريخ',
                      onPressed: () {
                        setState(() {
                          _selectedFromDate = null;
                          _selectedToDate = null;
                        });
                        context.read<DelegateSettlementsCubit>().fetchSettlements(
                              dateFrom: '',
                              dateTo: '',
                              page: 1,
                            );
                      },
                    ),
                  ],

                  const SizedBox(width: 8),

                  // Sort Toggle Icon
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        currentSort == 'newest'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: const Color(0xFFFFC107),
                        size: 18,
                      ),
                      tooltip: currentSort == 'newest' ? 'الأحدث أولاً' : 'الأقدم أولاً',
                      onPressed: () {
                        final newSort = currentSort == 'newest' ? 'oldest' : 'newest';
                        context
                            .read<DelegateSettlementsCubit>()
                            .fetchSettlements(sort: newSort, page: 1);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Settlements List Body
        Expanded(
          child: BlocBuilder<DelegateSettlementsCubit, DelegateSettlementsState>(
            builder: (context, state) {
              if (state is DelegateSettlementsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFC107)),
                );
              }

              if (state is DelegateSettlementsError) {
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
                            context.read<DelegateSettlementsCubit>().fetchSettlements();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is DelegateSettlementsLoaded) {
                final settlements = state.settlements;
                final pagination = state.pagination;

                if (settlements.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<DelegateSettlementsCubit>().fetchSettlements(),
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
                                Icons.receipt_long_outlined,
                                color: Colors.white24,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد تسويات مالية بالمواصفات المحددة',
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
                      context.read<DelegateSettlementsCubit>().fetchSettlements(),
                  color: const Color(0xFFFFC107),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: settlements.length,
                          itemBuilder: (context, index) {
                            final item = settlements[index];
                            return _buildSettlementCard(item);
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
                                            .read<DelegateSettlementsCubit>()
                                            .fetchSettlements(page: pagination.page - 1);
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
                                            .read<DelegateSettlementsCubit>()
                                            .fetchSettlements(page: pagination.page + 1);
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

  Widget _buildStatusChip(String label, String value, String currentStatus) {
    final isSelected = currentStatus == value;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.cairo(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
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
          context.read<DelegateSettlementsCubit>().fetchSettlements(
                status: value,
                page: 1,
              );
        }
      },
    );
  }

  Widget _buildSettlementCard(DelegateSettlementEntity item) {
    final statusColor = _getStatusColor(item.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
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
          // Row 1: Order Number & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt, color: Color(0xFFFFC107), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    item.orderNumber.isNotEmpty
                        ? item.orderNumber
                        : 'طلب رقم: #${item.id.substring(0, 8)}',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _translateStatus(item.status),
                  style: GoogleFonts.cairo(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.white10, height: 1),
          ),

          // Row 2: Amount & Recipient Name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المستلم',
                    style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        item.recipientName.isNotEmpty ? item.recipientName : 'غير محدد',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'المبلغ المستحق',
                    style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.amount.toStringAsFixed(0)} د.ع',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFFFC107),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 3: Stage Badge & Creation Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, color: Colors.white70, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'مرحلة ${_translateStage(item.stage)}',
                      style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (item.createdAt.isNotEmpty)
                Text(
                  _formatDate(item.createdAt),
                  style: GoogleFonts.cairo(color: Colors.white38, fontSize: 11),
                ),
            ],
          ),

          // Optional Payment Method / Paid Details
          if (item.paymentMethod != null || item.paidAt != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'طريقة الدفع: ${item.paymentMethod ?? "مباشر"}',
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11),
                  ),
                  if (item.paidAt != null) ...[
                    const Spacer(),
                    Text(
                      'تاريخ الدفع: ${_formatDate(item.paidAt!)}',
                      style: GoogleFonts.cairo(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Notes
          if (item.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'ملاحظات: ${item.notes}',
              style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
