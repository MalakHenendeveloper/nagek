import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/coupon_entity.dart';
import '../../cubit/admin_coupons_cubit.dart';

class AdminCouponsView extends StatefulWidget {
  const AdminCouponsView({super.key});

  @override
  State<AdminCouponsView> createState() => _AdminCouponsViewState();
}

class _AdminCouponsViewState extends State<AdminCouponsView> {
  @override
  void initState() {
    super.initState();
    context.read<AdminCouponsCubit>().fetchCoupons();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminCouponsCubit, AdminCouponsState>(
      listener: (context, state) {
        if (state is AdminCouponUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم تحديث الكوبون بنجاح',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh list after update
          context.read<AdminCouponsCubit>().fetchCoupons();
        } else if (state is AdminCouponUpdateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      buildWhen: (previous, current) {
        return current is AdminCouponsListLoading ||
            current is AdminCouponsListLoaded ||
            current is AdminCouponsListError;
      },
      builder: (context, state) {
        if (state is AdminCouponsListLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (context, index) => const _CouponCardSkeleton(),
          );
        } else if (state is AdminCouponsListError) {
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
                    onPressed: () => context.read<AdminCouponsCubit>().fetchCoupons(),
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
        } else if (state is AdminCouponsListLoaded) {
          final coupons = state.coupons;
          if (coupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد كوبونات حالياً',
                    style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFFFC107),
            onRefresh: () async {
              context.read<AdminCouponsCubit>().fetchCoupons();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                return _CouponCard(coupon: coupons[index]);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _CouponCard extends StatelessWidget {
  final CouponEntity coupon;

  const _CouponCard({required this.coupon});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm a', 'ar');
    final isExpired = coupon.expiresAt.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: coupon.isActive
              ? const Color(0xFFFFC107).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Code + Status
            Row(
              children: [
                // Coupon code badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_offer, color: Color(0xFFFFC107), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        coupon.code,
                        style: GoogleFonts.cairo(
                          color: const Color(0xFFFFC107),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Active/Inactive toggle
                _StatusBadge(isActive: coupon.isActive, isExpired: isExpired),
              ],
            ),
            const SizedBox(height: 16),

            // Info rows
            _InfoRow(
              icon: Icons.money_rounded,
              label: 'قيمة الخصم',
              value: '${coupon.discountValue} (${_discountTypeLabel(coupon.discountType)})',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.bar_chart_rounded,
              label: 'عدد الاستخدامات',
              value: '${coupon.usageCount}',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'تاريخ الإنشاء',
              value: dateFormat.format(coupon.createdAt),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.timer_outlined,
              label: 'تاريخ الانتهاء',
              value: dateFormat.format(coupon.expiresAt),
              valueColor: isExpired ? Colors.redAccent : null,
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: coupon.isActive ? 'تعطيل' : 'تفعيل',
                    icon: coupon.isActive ? Icons.block : Icons.check_circle_outline,
                    color: coupon.isActive ? Colors.redAccent : Colors.green,
                    onTap: () {
                      context.read<AdminCouponsCubit>().updateCoupon(
                        id: coupon.id,
                        isActive: !coupon.isActive,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _discountTypeLabel(String type) {
    switch (type) {
      case 'fixed':
        return 'ثابت';
      case 'percentage':
        return 'نسبة مئوية';
      default:
        return type;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final bool isExpired;

  const _StatusBadge({required this.isActive, required this.isExpired});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    if (isExpired) {
      label = 'منتهي';
      color = Colors.grey;
    } else if (isActive) {
      label = 'مفعّل';
      color = Colors.green;
    } else {
      label = 'معطّل';
      color = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white38),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.cairo(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              color: valueColor ?? Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponCardSkeleton extends StatelessWidget {
  const _CouponCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E1E),
      highlightColor: const Color(0xFF2A2A2A),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
