import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../cubit/admin_delegate_applications_cubit.dart';
import '../../cubit/admin_delegate_applications_state.dart';
import '../../cubit/delegate_application_details_cubit.dart';
import '../../cubit/delegate_application_details_state.dart';
import '../../../../../core/di/di.dart';
import '../../../domain/entities/delegate_application_entity.dart';

class AdminDelegateApplicationsView extends StatefulWidget {
  const AdminDelegateApplicationsView({super.key});

  @override
  State<AdminDelegateApplicationsView> createState() =>
      _AdminDelegateApplicationsViewState();
}

class _AdminDelegateApplicationsViewState
    extends State<AdminDelegateApplicationsView> {
  final ScrollController _scrollController = ScrollController();
  late AdminDelegateApplicationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<AdminDelegateApplicationsCubit>();
    _scrollController.addListener(_onScroll);
    _cubit.fetchApplications(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _cubit.fetchApplications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      AdminDelegateApplicationsCubit,
      AdminDelegateApplicationsState
    >(
      builder: (context, state) {
        if (state is AdminDelegateApplicationsInitial ||
            state is AdminDelegateApplicationsLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (context, index) => const _ApplicationCardSkeleton(),
          );
        } else if (state is AdminDelegateApplicationsError) {
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
                    ),
                    onPressed: () => _cubit.fetchApplications(isRefresh: true),
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
        } else if (state is AdminDelegateApplicationsSuccess) {
          final applications = state.applications;
          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    color: Colors.white.withValues(alpha: 0.2),
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد طلبات تسجيل مندوبين حالياً',
                    style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final hasReachedMax = state.pagination.page >= state.pagination.pages;

          return RefreshIndicator(
            color: const Color(0xFFFFC107),
            onRefresh: () async {
              await _cubit.fetchApplications(isRefresh: true);
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: hasReachedMax
                  ? applications.length
                  : applications.length + 1,
              itemBuilder: (context, index) {
                if (index >= applications.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFC107),
                      ),
                    ),
                  );
                }

                final app = applications[index];
                return GestureDetector(
                  onTap: () => _showApplicationDetails(context, app),
                  child: _buildApplicationCard(app),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildApplicationCard(DelegateApplicationEntity app) {
    final String dateString = app.createdAt.isNotEmpty
        ? DateTime.tryParse(
                app.createdAt,
              )?.toLocal().toString().split(' ')[0] ??
              ''
        : '';

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (app.status) {
      case 'approved':
        statusColor = Colors.green;
        statusLabel = 'مقبول';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.redAccent;
        statusLabel = 'مرفوض';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusLabel = 'قيد المراجعة';
        statusIcon = Icons.hourglass_top_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Color(0xFFFFC107),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    app.name,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: GoogleFonts.cairo(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, app.phone),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.email_outlined, app.email),
          if (dateString.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تاريخ التقديم: $dateString',
                  style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: const Color(0xFFFFC107).withValues(alpha: 0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'عرض المستندات',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFFFC107).withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.cairo(color: Colors.white60, fontSize: 13),
        ),
      ],
    );
  }

  void _showApplicationDetails(
    BuildContext context,
    DelegateApplicationEntity app,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider<DelegateApplicationDetailsCubit>(
        create: (_) =>
            getIt<DelegateApplicationDetailsCubit>()..fetchDetails(app.id),
        child: _ApplicationDetailsSheet(
          onSuccess: () {
            _cubit.fetchApplications(isRefresh: true);
          },
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// Application Details Bottom Sheet
// -------------------------------------------------------------------
class _ApplicationDetailsSheet extends StatelessWidget {
  final VoidCallback onSuccess;

  const _ApplicationDetailsSheet({required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child:
              BlocConsumer<
                DelegateApplicationDetailsCubit,
                DelegateApplicationDetailsState
              >(
                listener: (context, state) {
                  if (state is DelegateApplicationApproveSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          style: GoogleFonts.cairo(color: Colors.white),
                          textAlign: TextAlign.right,
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context); // Close bottom sheet
                    onSuccess(); // Refresh applications list
                  } else if (state is DelegateApplicationRejectSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          style: GoogleFonts.cairo(color: Colors.white),
                          textAlign: TextAlign.right,
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    Navigator.pop(context); // Close bottom sheet
                    onSuccess(); // Refresh applications list
                  } else if (state is DelegateApplicationDetailsSuccess &&
                      state.actionError != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.actionError!,
                          style: GoogleFonts.cairo(color: Colors.white),
                          textAlign: TextAlign.right,
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is DelegateApplicationDetailsLoading ||
                      state is DelegateApplicationDetailsInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFC107),
                      ),
                    );
                  } else if (state is DelegateApplicationDetailsError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          state.message,
                          style: GoogleFonts.cairo(
                            color: Colors.redAccent,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else if (state is DelegateApplicationDetailsSuccess ||
                      state is DelegateApplicationApproveSuccess ||
                      state is DelegateApplicationRejectSuccess) {
                    // Determine the application entity to display
                    final application =
                        state is DelegateApplicationDetailsSuccess
                        ? state.application
                        : null;

                    if (application == null) {
                      return const SizedBox.shrink();
                    }

                    Color statusColor;
                    String statusLabel;
                    switch (application.status) {
                      case 'approved':
                        statusColor = Colors.green;
                        statusLabel = 'مقبول';
                        break;
                      case 'rejected':
                        statusColor = Colors.redAccent;
                        statusLabel = 'مرفوض';
                        break;
                      default:
                        statusColor = Colors.orange;
                        statusLabel = 'قيد المراجعة';
                    }

                    final isActionLoading =
                        state is DelegateApplicationDetailsSuccess
                        ? state.isActionLoading
                        : false;

                    return Column(
                      children: [
                        // Handle bar
                        Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Title
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'تفاصيل طلب الانضمام',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: GoogleFonts.cairo(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.white10),
                        // Content
                        Expanded(
                          child: ListView(
                            controller: controller,
                            padding: const EdgeInsets.all(20),
                            children: [
                              _buildDetailRow('الاسم', application.name),
                              _buildDetailRow('رقم الهاتف', application.phone),
                              _buildDetailRow(
                                'البريد الإلكتروني',
                                application.email,
                              ),
                              _buildDetailRow('الحالة', statusLabel),
                              if (application.rejectReason != null &&
                                  application.rejectReason!.isNotEmpty)
                                _buildDetailRow(
                                  'سبب الرفض',
                                  application.rejectReason!,
                                ),
                              if (application.createdAt.isNotEmpty)
                                _buildDetailRow(
                                  'تاريخ التقديم',
                                  DateTime.tryParse(
                                        application.createdAt,
                                      )?.toLocal().toString().split(' ')[0] ??
                                      application.createdAt,
                                ),
                              const SizedBox(height: 24),
                              Text(
                                'المستندات المرفقة',
                                style: GoogleFonts.cairo(
                                  color: const Color(0xFFFFC107),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildDocumentCard(
                                'الوجه الأمامي للبطاقة',
                                application.nationalIdFrontUrl,
                                Icons.credit_card,
                                context,
                              ),
                              _buildDocumentCard(
                                'الوجه الخلفي للبطاقة',
                                application.nationalIdBackUrl,
                                Icons.credit_card,
                                context,
                              ),
                              _buildDocumentCard(
                                'رخصة القيادة',
                                application.drivingLicenseUrl,
                                Icons.drive_eta,
                                context,
                              ),
                              _buildDocumentCard(
                                'رخصة الدراجة',
                                application.motorcycleLicenseUrl,
                                Icons.two_wheeler,
                                context,
                              ),
                            ],
                          ),
                        ),
                        // Action Buttons (only if pending)
                        if (application.status == 'pending') ...[
                          const Divider(color: Colors.white10),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                // Reject Button
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: isActionLoading
                                        ? null
                                        : () {
                                            _showRejectReasonDialog(
                                              context,
                                              application.id,
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'رفض الطلب',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Approve Button
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: isActionLoading
                                        ? null
                                        : () {
                                            context
                                                .read<
                                                  DelegateApplicationDetailsCubit
                                                >()
                                                .approveApplication(
                                                  application.id,
                                                );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: isActionLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            'قبول الطلب',
                                            style: GoogleFonts.cairo(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.cairo(
                color: Colors.white38,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    String title,
    String url,
    IconData icon,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        if (url.isNotEmpty) {
          _showFullScreenImage(context, url, title);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFFFC107), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    url.isNotEmpty ? 'اضغط لعرض الصورة' : 'لا يوجد مستند',
                    style: GoogleFonts.cairo(
                      color: url.isNotEmpty
                          ? const Color(0xFFFFC107).withValues(alpha: 0.7)
                          : Colors.white30,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (url.isNotEmpty)
              const Icon(
                Icons.open_in_new_rounded,
                color: Color(0xFFFFC107),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, color: Colors.white54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Image
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0F0F0F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: InteractiveViewer(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFFFFC107),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, error, stackTrace) => SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white30,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'تعذر تحميل الصورة',
                              style: GoogleFonts.cairo(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectReasonDialog(
    BuildContext sheetContext,
    String applicationId,
  ) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: sheetContext,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'رفض طلب الانضمام',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'يرجى كتابة سبب رفض الطلب للمندوب:',
                  style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller,
                  maxLines: 3,
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'مثال: صورة البطاقة غير واضحة',
                    hintStyle: GoogleFonts.cairo(
                      color: Colors.white30,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2B2B2B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال سبب الرفض';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogCtx);
                  sheetContext
                      .read<DelegateApplicationDetailsCubit>()
                      .rejectApplication(applicationId, controller.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'رفض',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// Skeleton Card
// -------------------------------------------------------------------
class _ApplicationCardSkeleton extends StatelessWidget {
  const _ApplicationCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E1E),
      highlightColor: const Color(0xFF2A2A2A),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 18, backgroundColor: Colors.white24),
                const SizedBox(width: 10),
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: 160,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
