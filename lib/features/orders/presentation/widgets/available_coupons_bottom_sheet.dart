import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/available_coupon_entity.dart';
import '../cubit/available_coupons_cubit.dart';
import '../cubit/available_coupons_state.dart';

class AvailableCouponsBottomSheet extends StatelessWidget {
  const AvailableCouponsBottomSheet({super.key});

  static void show(BuildContext context, AvailableCouponsCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: cubit,
          child: const AvailableCouponsBottomSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: Color(0xFFFFC107),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'العروض والكوبونات المتاحة',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'انسخ كود الكوبون واستخدمه عند سداد الفاتورة',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Coupons content
            BlocBuilder<AvailableCouponsCubit, AvailableCouponsState>(
              builder: (context, state) {
                if (state is AvailableCouponsLoading) {
                  return const SizedBox(
                    height: 220,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFC107),
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                } else if (state is AvailableCouponsError) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.redAccent, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: GoogleFonts.cairo(
                                color: Colors.redAccent, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is AvailableCouponsLoaded) {
                  final coupons = state.coupons;
                  if (coupons.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: 54,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد كوبونات متاحة حالياً',
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'تابع صفحة العروض في الصفحة الرئيسية باستمرار!\nنضيف كوبونات وخصومات حصرية بشكل دوري 🎁',
                              style: GoogleFonts.cairo(
                                color: Colors.white54,
                                fontSize: 13,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.home_rounded, color: Color(0xFFFFC107), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'راقب العروض من الصفحة الرئيسية',
                                    style: GoogleFonts.cairo(
                                      color: const Color(0xFFFFC107),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Horizontal scroll hint
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              'اسحب لليمين واليسار لرؤية جميع الكوبونات',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFFFFC107),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.swipe_left_rounded,
                              size: 14,
                              color: Color(0xFFFFC107),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Horizontal ListView
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: coupons.length,
                          itemBuilder: (context, index) {
                            return _CouponTicketCard(coupon: coupons[index]);
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _CouponTicketCard extends StatefulWidget {
  final AvailableCouponEntity coupon;

  const _CouponTicketCard({required this.coupon});

  @override
  State<_CouponTicketCard> createState() => _CouponTicketCardState();
}

class _CouponTicketCardState extends State<_CouponTicketCard> {
  bool _copied = false;

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.coupon.code));
    setState(() {
      _copied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'تم نسخ كود الكوبون: ${widget.coupon.code}',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final expDate = '${widget.coupon.expiresAt.year}/${widget.coupon.expiresAt.month.toString().padLeft(2, '0')}/${widget.coupon.expiresAt.day.toString().padLeft(2, '0')}';

    return Container(
      width: 290,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF222222),
            const Color(0xFF191919),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFC107).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: Value & Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خصم بقيمة',
                      style: GoogleFonts.cairo(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${widget.coupon.discountValue} د.ع',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFFFC107),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on,
                          color: Color(0xFFFFC107), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'عرض خاص',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFFFFC107),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Coupon Code container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white12,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tag, color: Colors.white38, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        widget.coupon.code,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'كود الكوبون',
                    style: GoogleFonts.cairo(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Details: Remaining & Expiry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.repeat_rounded,
                        color: Colors.white38, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'متبقي ${widget.coupon.remainingUses} استخدام',
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        color: Colors.white38, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'ينتهي: $expDate',
                      style: GoogleFonts.cairo(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Copy Button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: _copyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _copied
                      ? Colors.green[700]
                      : const Color(0xFFFFC107),
                  foregroundColor:
                      _copied ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                icon: Icon(
                  _copied ? Icons.check_circle : Icons.copy_rounded,
                  size: 16,
                ),
                label: Text(
                  _copied ? 'تم النسخ!' : 'نسخ كود الكوبون',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
