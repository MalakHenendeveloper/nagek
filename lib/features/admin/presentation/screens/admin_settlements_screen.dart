import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../domain/entities/admin_settlement_entity.dart';
import '../cubit/admin_settlements_cubit.dart';
import '../cubit/admin_settlements_state.dart';

class AdminSettlementsScreen extends StatelessWidget {
  const AdminSettlementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AdminSettlementsCubit>()..fetchSettlements(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text(
            'قائمة تسويات النظام (الإدارة)',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          foregroundColor: const Color(0xFFFFC107),
        ),
        body: const Directionality(
          textDirection: TextDirection.rtl,
          child: _AdminSettlementsBody(),
        ),
      ),
    );
  }
}

class _AdminSettlementsBody extends StatefulWidget {
  const _AdminSettlementsBody();

  @override
  State<_AdminSettlementsBody> createState() => _AdminSettlementsBodyState();
}

class _AdminSettlementsBodyState extends State<_AdminSettlementsBody> {
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  final TextEditingController _orderController = TextEditingController();
  final TextEditingController _recipientIdController = TextEditingController();
  bool _showSearchFields = false;

  @override
  void dispose() {
    _orderController.dispose();
    _recipientIdController.dispose();
    super.dispose();
  }

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
      case 'admin':
        return 'عمولة إدارة';
      case 'repair':
        return 'صيانة مركز';
      case 'delivery':
        return 'توصيل مندوب';
      case 'pickup':
        return 'استلام مندوب';
      default:
        return stage.isNotEmpty ? stage : 'عام';
    }
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
    final cubit = context.read<AdminSettlementsCubit>();
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
    final cubit = context.read<AdminSettlementsCubit>();
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

  void _applySearch(BuildContext context) {
    context.read<AdminSettlementsCubit>().fetchSettlements(
          order: _orderController.text.trim(),
          recipientId: _recipientIdController.text.trim(),
          page: 1,
        );
  }

  void _showPayDialog(BuildContext context, AdminSettlementEntity item) {
    String selectedMethod = 'cash';
    final notesController = TextEditingController();
    final cubit = context.read<AdminSettlementsCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF141414),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFFFC107), width: 1),
              ),
              title: Row(
                children: [
                  const Icon(Icons.payment, color: Color(0xFFFFC107)),
                  const SizedBox(width: 8),
                  Text(
                    'تأكيد دفع التسوية',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رقم الطلب: ${item.orderNumber.isNotEmpty ? item.orderNumber : item.id}',
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'المستلم: ${item.recipientName}',
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'المبلغ: ${item.amount.toStringAsFixed(0)} د.ع',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFFFC107),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'طريقة الدفع:',
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text(
                          'نقدي (Cash)',
                          style: GoogleFonts.cairo(
                            color: selectedMethod == 'cash' ? Colors.black : Colors.white,
                            fontSize: 11,
                          ),
                        ),
                        selected: selectedMethod == 'cash',
                        selectedColor: const Color(0xFFFFC107),
                        backgroundColor: Colors.white10,
                        onSelected: (val) {
                          if (val) setDialogState(() => selectedMethod = 'cash');
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(
                          'محفظة (Wallet)',
                          style: GoogleFonts.cairo(
                            color: selectedMethod == 'wallet' ? Colors.black : Colors.white,
                            fontSize: 11,
                          ),
                        ),
                        selected: selectedMethod == 'wallet',
                        selectedColor: const Color(0xFFFFC107),
                        backgroundColor: Colors.white10,
                        onSelected: (val) {
                          if (val) setDialogState(() => selectedMethod = 'wallet');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'ملاحظات إضافية (اختياري)',
                      hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 11),
                      filled: true,
                      fillColor: const Color(0xFF0F0F0F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.cairo(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    cubit.paySettlement(
                          item.id,
                          paymentMethod: selectedMethod,
                          notes: notesController.text.trim(),
                        );
                  },
                  child: Text(
                    'تأكيد الدفع',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AdminSettlementsCubit>();
    final currentStatus = cubit.currentStatus;
    final currentRecipientType = cubit.currentRecipientType;
    final currentPaymentMethod = cubit.currentPaymentMethod;
    final currentSort = cubit.currentSort;

    return BlocListener<AdminSettlementsCubit, AdminSettlementsState>(
      listener: (context, state) {
        if (state is AdminSettlementPaySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFFFFC107),
            ),
          );
        } else if (state is AdminSettlementPayError) {
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
      child: Column(
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
                      Text(
                        'الحالة: ',
                        style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                      ),
                      _buildFilterChip('الكل', 'all', currentStatus, (val) {
                        context.read<AdminSettlementsCubit>().fetchSettlements(status: val, page: 1);
                      }),
                      const SizedBox(width: 6),
                      _buildFilterChip('قيد الانتظار', 'pending', currentStatus, (val) {
                        context.read<AdminSettlementsCubit>().fetchSettlements(status: val, page: 1);
                      }),
                      const SizedBox(width: 6),
                      _buildFilterChip('تم الدفع', 'paid', currentStatus, (val) {
                        context.read<AdminSettlementsCubit>().fetchSettlements(status: val, page: 1);
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

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
                        context.read<AdminSettlementsCubit>().fetchSettlements(recipientType: val, page: 1);
                      }),
                      const SizedBox(width: 6),
                      _buildFilterChip('إدارة', 'admin', currentRecipientType, (val) {
                        context.read<AdminSettlementsCubit>().fetchSettlements(recipientType: val, page: 1);
                      }),
                      const SizedBox(width: 6),
                      _buildFilterChip('مندوب', 'delegate', currentRecipientType, (val) {
                        context.read<AdminSettlementsCubit>().fetchSettlements(recipientType: val, page: 1);
                      }),
                      const SizedBox(width: 6),
                      _buildFilterChip('مركز صيانة', 'center', currentRecipientType, (val) {
                        context.read<AdminSettlementsCubit>().fetchSettlements(recipientType: val, page: 1);
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 3. Payment Method Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        'الدفع: ',
                        style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                      ),
                      _buildFilterChip('الكل', 'all', currentPaymentMethod, (val) {
                        context.read<AdminSettlementsCubit>().fetchSettlements(paymentMethod: val, page: 1);
                      }),
                      const SizedBox(width: 6),
                      _buildFilterChip('نقدي (Cash)', 'cash', currentPaymentMethod, (val) {
                        context.read<AdminSettlementsCubit>().fetchSettlements(paymentMethod: val, page: 1);
                      }),
                      const SizedBox(width: 6),
                      _buildFilterChip('محفظة (Wallet)', 'wallet', currentPaymentMethod, (val) {
                        context.read<AdminSettlementsCubit>().fetchSettlements(paymentMethod: val, page: 1);
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 4. Date Pickers & Search Toggle Row
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

                    const SizedBox(width: 8),

                    // Search Fields Toggle Button
                    IconButton(
                      icon: Icon(
                        _showSearchFields ? Icons.filter_alt_off : Icons.search,
                        color: const Color(0xFFFFC107),
                        size: 20,
                      ),
                      tooltip: 'البحث برقم الطلب / المعرف',
                      onPressed: () {
                        setState(() {
                          _showSearchFields = !_showSearchFields;
                        });
                      },
                    ),

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
                              .read<AdminSettlementsCubit>()
                              .fetchSettlements(sort: newSort, page: 1);
                        },
                      ),
                    ),
                  ],
                ),

                // 5. Expandable Search Inputs (Order ID / Recipient ID)
                if (_showSearchFields) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _orderController,
                          style: GoogleFonts.cairo(color: Colors.white, fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'رقم/معرف الطلب (Order ID)',
                            hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 11),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            filled: true,
                            fillColor: const Color(0xFF0F0F0F),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                          ),
                          onSubmitted: (_) => _applySearch(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _recipientIdController,
                          style: GoogleFonts.cairo(color: Colors.white, fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'معرف المستلم (Recipient ID)',
                            hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 11),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            filled: true,
                            fillColor: const Color(0xFF0F0F0F),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                          ),
                          onSubmitted: (_) => _applySearch(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _applySearch(context),
                        child: const Icon(Icons.search, size: 18),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Settlements List Body
          Expanded(
            child: BlocBuilder<AdminSettlementsCubit, AdminSettlementsState>(
              builder: (context, state) {
                if (state is AdminSettlementsLoading || state is AdminSettlementPayLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFC107)),
                  );
                }

                if (state is AdminSettlementsError) {
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
                              context.read<AdminSettlementsCubit>().fetchSettlements();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is AdminSettlementsLoaded) {
                  final settlements = state.settlements;
                  final pagination = state.pagination;

                  if (settlements.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () =>
                          context.read<AdminSettlementsCubit>().fetchSettlements(),
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
                        context.read<AdminSettlementsCubit>().fetchSettlements(),
                    color: const Color(0xFFFFC107),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: settlements.length,
                            itemBuilder: (context, index) {
                              final item = settlements[index];
                              return _buildSettlementCard(context, item);
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
                                              .read<AdminSettlementsCubit>()
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
                                              .read<AdminSettlementsCubit>()
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
      ),
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

  Widget _buildSettlementCard(BuildContext context, AdminSettlementEntity item) {
    final statusColor = _getStatusColor(item.status);
    final recipientColor = _getRecipientColor(item.recipientType);
    final isPending = item.status.toLowerCase() == 'pending' || item.paymentStatus.toLowerCase() == 'pending';

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
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.receipt, color: Color(0xFFFFC107), size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item.orderNumber.isNotEmpty
                            ? item.orderNumber
                            : 'تسوية رقم: #${item.id.substring(0, 8)}',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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

          // Row 2: Recipient Info & Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'المستلم: ',
                        style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: recipientColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _translateRecipientType(item.recipientType),
                          style: GoogleFonts.cairo(
                            color: recipientColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
                  if (item.recipientEmail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.recipientEmail,
                      style: GoogleFonts.cairo(color: Colors.white38, fontSize: 10),
                    ),
                  ],
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
                    const Icon(Icons.layers_outlined, color: Colors.white70, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _translateStage(item.stage),
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

          // Row 4: Confirm Payment Button (When Pending)
          if (isPending) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text(
                  'تأكيد دفع المستحق المالي',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                onPressed: () => _showPayDialog(context, item),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
