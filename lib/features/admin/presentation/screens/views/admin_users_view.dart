import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../cubit/admin_users_cubit.dart';
import '../../cubit/admin_users_state.dart';
import '../../../domain/entities/admin_user_entity.dart';
import 'admin_user_details_bottom_sheet.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  final ScrollController _scrollController = ScrollController();
  late AdminUsersCubit _usersCubit;

  @override
  void initState() {
    super.initState();
    _usersCubit = context.read<AdminUsersCubit>();
    _scrollController.addListener(_onScroll);
    _usersCubit.fetchUsers(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _usersCubit.fetchUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminUsersCubit, AdminUsersState>(
      builder: (context, state) {
        if (state is AdminUsersInitial || (state is AdminUsersLoading && state is! AdminUsersLoaded)) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (context, index) => const _UserCardSkeleton(),
          );
        } else if (state is AdminUsersError && state is! AdminUsersLoaded) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => _usersCubit.fetchUsers(isRefresh: true),
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
        } else if (state is AdminUsersLoaded) {
          final users = state.users;
          if (users.isEmpty) {
            return Center(
              child: Text(
                'لا يوجد مستخدمون مسجلون حالياً',
                style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFFFC107),
            onRefresh: () async {
              await _usersCubit.fetchUsers(isRefresh: true);
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.hasReachedMax ? users.length : users.length + 1,
              itemBuilder: (context, index) {
                if (index >= users.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFFFC107)),
                    ),
                  );
                }

                final user = users[index];
                return GestureDetector(
                  onTap: () async {
                    final deleted = await AdminUserDetailsBottomSheet.show(context, user.id);
                    if (deleted == true && context.mounted) {
                      context.read<AdminUsersCubit>().fetchUsers(isRefresh: true);
                    }
                  },
                  child: _buildUserCard(user),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUserCard(AdminUserEntity user) {
    // Determine Role Arabic translation & color
    String roleAr = 'عميل';
    Color roleColor = Colors.blueAccent;
    if (user.role == 'center') {
      roleAr = 'مركز صيانة';
      roleColor = const Color(0xFFFF9800);
    } else if (user.role == 'admin') {
      roleAr = 'مدير النظام';
      roleColor = Colors.redAccent;
    } else if (user.role == 'delegate') {
      roleAr = 'مندوب';
      roleColor = const Color(0xFF4CAF50);
    }

    final String dateString = user.createdAt.isNotEmpty
        ? DateTime.tryParse(user.createdAt)?.toLocal().toString().split(' ')[0] ?? ''
        : '';

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
              Text(
                user.name,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  roleAr,
                  style: GoogleFonts.cairo(
                    color: roleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.phone, user.phone),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.email_outlined, user.email),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildStatusChip(
                    isActive: user.isActive,
                    activeLabel: 'نشط',
                    inactiveLabel: 'غير نشط',
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    isActive: user.isVerified,
                    activeLabel: 'موثق',
                    inactiveLabel: 'غير موثق',
                    isVerification: true,
                  ),
                ],
              ),
              if (dateString.isNotEmpty)
                Text(
                  'انضم في: $dateString',
                  style: GoogleFonts.cairo(
                    color: Colors.white30,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 13,
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required bool isActive,
    required String activeLabel,
    required String inactiveLabel,
    bool isVerification = false,
  }) {
    final Color color = isActive
        ? const Color(0xFF4CAF50)
        : (isVerification ? Colors.grey : Colors.redAccent);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        isActive ? activeLabel : inactiveLabel,
        style: GoogleFonts.cairo(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _UserCardSkeleton extends StatelessWidget {
  const _UserCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E1E),
      highlightColor: const Color(0xFF2A2A2A),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
