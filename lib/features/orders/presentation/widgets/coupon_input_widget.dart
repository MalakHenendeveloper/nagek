import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/validate_coupon_cubit.dart';
import '../cubit/validate_coupon_state.dart';
import '../../domain/entities/validate_coupon_entity.dart';

class CouponInputWidget extends StatefulWidget {
  final num amount;
  final Function(ValidateCouponEntity? couponResult)? onCouponApplied;

  const CouponInputWidget({
    super.key,
    required this.amount,
    this.onCouponApplied,
  });

  @override
  State<CouponInputWidget> createState() => _CouponInputWidgetState();
}

class _CouponInputWidgetState extends State<CouponInputWidget> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;
    context.read<ValidateCouponCubit>().validateCoupon(
          code: code,
          amount: widget.amount,
        );
  }

  void _removeCoupon() {
    _couponController.clear();
    context.read<ValidateCouponCubit>().reset();
    if (widget.onCouponApplied != null) {
      widget.onCouponApplied!(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ValidateCouponCubit, ValidateCouponState>(
      listener: (context, state) {
        if (state is ValidateCouponSuccess) {
          if (widget.onCouponApplied != null) {
            widget.onCouponApplied!(state.couponResult);
          }
        } else if (state is ValidateCouponError) {
          if (widget.onCouponApplied != null) {
            widget.onCouponApplied!(null);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is ValidateCouponLoading;
        final isApplied = state is ValidateCouponSuccess;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isApplied
                  ? Colors.green.withValues(alpha: 0.5)
                  : (state is ValidateCouponError
                      ? Colors.redAccent.withValues(alpha: 0.5)
                      : Colors.white10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_offer_outlined,
                    color: Color(0xFFFFC107),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'كوبون الخصم',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      enabled: !isApplied && !isLoading,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'أدخل كود الكوبون...',
                        hintStyle: GoogleFonts.cairo(
                          color: Colors.white30,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF141414),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : (isApplied ? _removeCoupon : _applyCoupon),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApplied
                          ? Colors.redAccent.withValues(alpha: 0.2)
                          : const Color(0xFFFFC107),
                      foregroundColor:
                          isApplied ? Colors.redAccent : Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: isApplied
                            ? const BorderSide(color: Colors.redAccent)
                            : BorderSide.none,
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            isApplied ? 'إلغاء' : 'تطبيق',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ],
              ),
              if (state is ValidateCouponSuccess) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'قيمة الخصم:',
                            style: GoogleFonts.cairo(
                              color: Colors.greenAccent,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '-${state.couponResult.discountAmount}',
                            style: GoogleFonts.cairo(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المبلغ بعد الخصم:',
                            style: GoogleFonts.cairo(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${state.couponResult.finalAmount}',
                            style: GoogleFonts.cairo(
                              color: const Color(0xFFFFC107),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (state.couponResult.remainingUses > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الاستخدامات المتبقية:',
                              style: GoogleFonts.cairo(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${state.couponResult.remainingUses}',
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'تاريخ انتهاء الكوبون:',
                            style: GoogleFonts.cairo(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${state.couponResult.expiresAt.year}/${state.couponResult.expiresAt.month.toString().padLeft(2, '0')}/${state.couponResult.expiresAt.day.toString().padLeft(2, '0')}',
                            style: GoogleFonts.cairo(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (state is ValidateCouponError) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        state.message,
                        style: GoogleFonts.cairo(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
