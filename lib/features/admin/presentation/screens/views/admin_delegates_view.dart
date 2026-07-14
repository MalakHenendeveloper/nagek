import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../cubit/admin_delegates_cubit.dart';
import '../../cubit/admin_delegates_state.dart';
import '../../../domain/entities/admin_user_entity.dart';
import 'admin_user_details_bottom_sheet.dart';

class AdminDelegatesView extends StatefulWidget {
  const AdminDelegatesView({super.key});

  @override
  State<AdminDelegatesView> createState() => _AdminDelegatesViewState();
}

class _AdminDelegatesViewState extends State<AdminDelegatesView> {
  final ScrollController _scrollController = ScrollController();
  late AdminDelegatesCubit _delegatesCubit;

  @override
  void initState() {
    super.initState();
    _delegatesCubit = context.read<AdminDelegatesCubit>();
    _scrollController.addListener(_onScroll);
    _delegatesCubit.fetchDelegates(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _delegatesCubit.fetchDelegates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDelegatesCubit, AdminDelegatesState>(
      builder: (context, state) {
        if (state is AdminDelegatesInitial || (state is AdminDelegatesLoading && state is! AdminDelegatesLoaded)) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (context, index) => const _DelegateCardSkeleton(),
          );
        } else if (state is AdminDelegatesError && state is! AdminDelegatesLoaded) {
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
                    onPressed: () => _delegatesCubit.fetchDelegates(isRefresh: true),
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
        } else if (state is AdminDelegatesLoaded) {
          final delegates = state.delegates;
          if (delegates.isEmpty) {
            return Center(
              child: Text(
                'لا يوجد مناديب مسجلين حالياً',
                style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFFFC107),
            onRefresh: () async {
              await _delegatesCubit.fetchDelegates(isRefresh: true);
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.hasReachedMax ? delegates.length : delegates.length + 1,
              itemBuilder: (context, index) {
                if (index >= delegates.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFFFC107)),
                    ),
                  );
                }

                final delegate = delegates[index];
                return GestureDetector(
                  onTap: () async {
                    final deleted = await AdminUserDetailsBottomSheet.show(context, delegate.id);
                    if (deleted == true && context.mounted) {
                      context.read<AdminDelegatesCubit>().fetchDelegates(isRefresh: true);
                    }
                  },
                  child: _buildDelegateCard(delegate),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDelegateCard(AdminUserEntity delegate) {
    final String dateString = delegate.createdAt.isNotEmpty
        ? DateTime.tryParse(delegate.createdAt)?.toLocal().toString().split(' ')[0] ?? ''
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delivery_dining,
                      color: Color(0xFFFFC107),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    delegate.name,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildStatusChip(
                    isActive: delegate.isActive,
                    activeLabel: 'نشط',
                    inactiveLabel: 'غير نشط',
                  ),
                  const SizedBox(width: 6),
                  _buildStatusChip(
                    isActive: delegate.isVerified,
                    activeLabel: 'موثق',
                    inactiveLabel: 'غير موثق',
                    isVerification: true,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, delegate.phone),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.email_outlined, delegate.email),
          if (dateString.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'تاريخ الانضمام: $dateString',
                style: GoogleFonts.cairo(
                  color: Colors.white30,
                  fontSize: 11,
                ),
              ),
            ),
          ],
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

class _DelegateCardSkeleton extends StatelessWidget {
  const _DelegateCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E1E),
      highlightColor: const Color(0xFF2A2A2A),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
