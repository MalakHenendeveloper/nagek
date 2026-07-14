import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/di/di.dart';
import '../../cubit/admin_user_details_cubit.dart';
import '../../cubit/admin_user_details_state.dart';
import '../../../domain/entities/admin_user_entity.dart';

class AdminUserDetailsBottomSheet extends StatefulWidget {
  final String userId;

  const AdminUserDetailsBottomSheet({super.key, required this.userId});

  /// Shows the bottom sheet and returns true if any modification occurred (deletion/status update).
  static Future<bool?> show(BuildContext context, String userId) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminUserDetailsBottomSheet(userId: userId),
    );
  }

  @override
  State<AdminUserDetailsBottomSheet> createState() => _AdminUserDetailsBottomSheetState();
}

class _AdminUserDetailsBottomSheetState extends State<AdminUserDetailsBottomSheet> {
  bool _wasModified = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminUserDetailsCubit>(
      create: (context) => getIt<AdminUserDetailsCubit>()..fetchUserDetails(widget.userId),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context).pop(_wasModified);
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF0F0F0F),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(color: Colors.white10, width: 1.5),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Notch
              Container(
                width: 50,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تفاصيل الحساب',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context, _wasModified),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),

              // Content
              Expanded(
                child: BlocConsumer<AdminUserDetailsCubit, AdminUserDetailsState>(
                  listener: (context, state) {
                    if (state is AdminUserDeleted) {
                      Navigator.of(context).pop(true); // Pop bottom sheet returning true (deleted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: GoogleFonts.cairo(color: Colors.white),
                          ),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    } else if (state is AdminUserDeleteError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: GoogleFonts.cairo(color: Colors.white),
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    } else if (state is AdminUserStatusUpdateSuccess) {
                      _wasModified = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: GoogleFonts.cairo(color: Colors.white),
                          ),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    } else if (state is AdminUserStatusUpdateError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: GoogleFonts.cairo(color: Colors.white),
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AdminUserDetailsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFFC107)),
                      );
                    } else if (state is AdminUserDetailsError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
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
                                style: GoogleFonts.cairo(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFC107),
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: () => context
                                    .read<AdminUserDetailsCubit>()
                                    .fetchUserDetails(widget.userId),
                                child: Text(
                                  'إعادة المحاولة',
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    AdminUserEntity? user;
                    bool isDeleting = false;
                    bool isUpdatingStatus = false;

                    if (state is AdminUserDetailsLoaded) {
                      user = state.user;
                    } else if (state is AdminUserDeleting) {
                      user = state.user;
                      isDeleting = true;
                    } else if (state is AdminUserDeleteError) {
                      user = state.user;
                    } else if (state is AdminUserStatusUpdating) {
                      user = state.user;
                      isUpdatingStatus = true;
                    } else if (state is AdminUserStatusUpdateSuccess) {
                      user = state.user;
                    } else if (state is AdminUserStatusUpdateError) {
                      user = state.user;
                    }

                    if (user == null) {
                      return const SizedBox.shrink();
                    }

                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Avatar and name
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFFC107).withValues(alpha: 0.2),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  _getRoleIcon(user.role),
                                  size: 50,
                                  color: const Color(0xFFFFC107),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user.name,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'معرف الحساب: ${user.id}',
                                style: GoogleFonts.cairo(
                                  color: Colors.white30,
                                  fontSize: 12,
                                ),
                                textDirection: TextDirection.ltr,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Section: Personal details
                        _buildSectionHeader('بيانات الحساب الأساسية'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141414),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(Icons.phone, 'رقم الهاتف', user.phone, isLtr: true),
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white10, height: 1),
                              const SizedBox(height: 12),
                              _buildDetailRow(Icons.email, 'البريد الإلكتروني', user.email, isLtr: true),
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white10, height: 1),
                              const SizedBox(height: 12),
                              _buildDetailRow(Icons.rule_folder, 'نوع الحساب (الدور)', _getRoleAr(user.role)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section: Account Status
                        _buildSectionHeader('حالة الحساب والتوثيق'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141414),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            children: [
                              _buildStatusRow(
                                'تفعيل الحساب',
                                user.isActive,
                                activeLabel: 'نشط ومفعّل',
                                inactiveLabel: 'غير نشط',
                                trailing: isUpdatingStatus
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFFFFC107),
                                        ),
                                      )
                                    : SizedBox(
                                        height: 30,
                                        child: Switch(
                                          value: user.isActive,
                                          activeThumbColor: const Color(0xFFFFC107),
                                          activeTrackColor: const Color(0xFFFFC107).withValues(alpha: 0.3),
                                          inactiveThumbColor: Colors.grey,
                                          inactiveTrackColor: Colors.white10,
                                          onChanged: isDeleting
                                              ? null
                                              : (val) {
                                                  context
                                                      .read<AdminUserDetailsCubit>()
                                                      .updateUserStatus(user!.id, val);
                                                },
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white10, height: 1),
                              const SizedBox(height: 12),
                              _buildStatusRow('توثيق الحساب', user.isVerified, activeLabel: 'موثق ومعتمد', inactiveLabel: 'غير موثق'),
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white10, height: 1),
                              const SizedBox(height: 12),
                              _buildStatusRow('حالة الحساب', !user.isDeleted, activeLabel: 'متاح وغير محذوف', inactiveLabel: 'تم حذفه', isDeletedCheck: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section: Addresses
                        _buildSectionHeader('العناوين المسجلة (${user.addresses.length})'),
                        if (user.addresses.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF141414),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Center(
                              child: Text(
                                'لا توجد عناوين مسجلة حالياً لهذا المستخدم',
                                style: GoogleFonts.cairo(color: Colors.white38, fontSize: 13),
                              ),
                            ),
                          )
                        else
                          ...user.addresses.map((addr) => _buildAddressCard(addr)),
                        const SizedBox(height: 24),

                        // Date Info
                        _buildDateInfo(user.createdAt, user.updatedAt),
                        const SizedBox(height: 28),

                        // Delete Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: isDeleting || isUpdatingStatus
                                ? null
                                : () => _showDeleteConfirmation(context, user!.id, user.name),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.shade700,
                              disabledBackgroundColor: Colors.redAccent.shade700.withValues(alpha: 0.5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            icon: isDeleting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.delete_forever_rounded, size: 22),
                            label: Text(
                              isDeleting ? 'جاري الحذف...' : 'حذف المستخدم',
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          color: const Color(0xFFFFC107),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isLtr = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.cairo(color: Colors.white60, fontSize: 14),
        ),
        const Spacer(),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(
    String label,
    bool isTrue, {
    required String activeLabel,
    required String inactiveLabel,
    bool isDeletedCheck = false,
    Widget? trailing,
  }) {
    final Color color = isTrue
        ? const Color(0xFF4CAF50)
        : (isDeletedCheck ? Colors.redAccent : Colors.grey);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(color: Colors.white60, fontSize: 14),
        ),
        Row(
          children: [
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: 8),
            ],
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              isTrue ? activeLabel : inactiveLabel,
              style: GoogleFonts.cairo(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressCard(AdminUserAddressEntity address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark_outline, color: Color(0xFFFFC107), size: 18),
              const SizedBox(width: 8),
              Text(
                address.label,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                address.city,
                style: GoogleFonts.cairo(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            address.address,
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
          ),
          if (address.lat != 0.0 || address.lng != 0.0) ...[
            const SizedBox(height: 6),
            Text(
              'الإحداثيات: ${address.lat.toStringAsFixed(4)}, ${address.lng.toStringAsFixed(4)}',
              style: GoogleFonts.cairo(color: Colors.white24, fontSize: 11),
              textDirection: TextDirection.ltr,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateInfo(String createdAt, String updatedAt) {
    final String createdStr = createdAt.isNotEmpty
        ? DateTime.tryParse(createdAt)?.toLocal().toString().split('.')[0] ?? ''
        : '';
    final String updatedStr = updatedAt.isNotEmpty
        ? DateTime.tryParse(updatedAt)?.toLocal().toString().split('.')[0] ?? ''
        : '';

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (createdStr.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تاريخ الإنشاء',
                  style: GoogleFonts.cairo(color: Colors.white24, fontSize: 12),
                ),
                Text(
                  createdStr,
                  style: GoogleFonts.cairo(color: Colors.white38, fontSize: 11),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          if (updatedStr.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تاريخ التحديث',
                  style: GoogleFonts.cairo(color: Colors.white24, fontSize: 12),
                ),
                Text(
                  updatedStr,
                  style: GoogleFonts.cairo(color: Colors.white38, fontSize: 11),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'center':
        return Icons.business;
      case 'delegate':
        return Icons.delivery_dining;
      case 'client':
      default:
        return Icons.person;
    }
  }

  String _getRoleAr(String role) {
    switch (role) {
      case 'admin':
        return 'مدير النظام';
      case 'center':
        return 'مركز صيانة';
      case 'delegate':
        return 'مندوب توصيل';
      case 'client':
      default:
        return 'عميل';
    }
  }

  void _showDeleteConfirmation(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141414),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white10),
          ),
          title: Text(
            'تأكيد الحذف',
            style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف حساب "$name"؟ لا يمكن التراجع عن هذه الخطوة.',
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(color: Colors.white38),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                context.read<AdminUserDetailsCubit>().deleteUser(id); // Dispatch delete
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'حذف الحساب',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
