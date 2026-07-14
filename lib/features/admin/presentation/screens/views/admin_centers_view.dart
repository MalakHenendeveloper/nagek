import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../cubit/admin_centers_cubit.dart';
import '../../cubit/admin_centers_state.dart';
import '../../../domain/entities/admin_center_entity.dart';
import 'admin_center_details_bottom_sheet.dart';

class AdminCentersView extends StatefulWidget {
  const AdminCentersView({super.key});

  @override
  State<AdminCentersView> createState() => _AdminCentersViewState();
}

class _AdminCentersViewState extends State<AdminCentersView> {
  final ScrollController _scrollController = ScrollController();
  late AdminCentersCubit _centersCubit;

  @override
  void initState() {
    super.initState();
    _centersCubit = context.read<AdminCentersCubit>();
    _scrollController.addListener(_onScroll);
    _centersCubit.fetchCenters(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _centersCubit.fetchCenters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCentersCubit, AdminCentersState>(
      builder: (context, state) {
        if (state is AdminCentersInitial || (state is AdminCentersLoading && state is! AdminCentersLoaded)) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (context, index) => const _CenterCardSkeleton(),
          );
        } else if (state is AdminCentersError && state is! AdminCentersLoaded) {
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
                    onPressed: () => _centersCubit.fetchCenters(isRefresh: true),
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
        } else if (state is AdminCentersLoaded) {
          final centers = state.centers;
          if (centers.isEmpty) {
            return Center(
              child: Text(
                'لا توجد مراكز صيانة مسجلة حالياً',
                style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFFFC107),
            onRefresh: () async {
              await _centersCubit.fetchCenters(isRefresh: true);
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.hasReachedMax ? centers.length : centers.length + 1,
              itemBuilder: (context, index) {
                if (index >= centers.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFFFC107)),
                    ),
                  );
                }

                final center = centers[index];
                return _buildCenterCard(center);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCenterCard(AdminCenterEntity center) {
    return GestureDetector(
      onTap: () async {
        final wasModified = await AdminCenterDetailsBottomSheet.show(context, center.id);
        if (wasModified == true && mounted) {
          _centersCubit.fetchCenters(isRefresh: true);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.white10,
                  child: center.logo.isNotEmpty
                      ? Image.network(
                          center.logo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.business,
                            color: Color(0xFFFFC107),
                            size: 26,
                          ),
                        )
                      : const Icon(
                          Icons.business,
                          color: Color(0xFFFFC107),
                          size: 26,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white38, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${center.city} - ${center.address}',
                            style: GoogleFonts.cairo(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Rating Badge
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    center.rating.toStringAsFixed(1),
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' (${center.totalRatings})',
                    style: GoogleFonts.cairo(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),

          // Owner Info
          if (center.owner != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, color: Color(0xFFFFC107), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'المالك: ${center.owner!.name}',
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone_android, color: Colors.white38, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        center.owner!.phone,
                        style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
                        textDirection: TextDirection.ltr,
                      ),
                      const Spacer(),
                      const Icon(Icons.email_outlined, color: Colors.white38, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        center.owner!.email,
                        style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Brands and Fee info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رسوم الفحص: ${center.inspectionFee} ر.س',
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: center.status == 'active'
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                      : Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: center.status == 'active'
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                        : Colors.redAccent.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  center.status == 'active' ? 'نشط' : 'غير نشط',
                  style: GoogleFonts.cairo(
                    color: center.status == 'active' ? const Color(0xFF4CAF50) : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Supported Brands
          if (center.supportedBrands.isNotEmpty) ...[
            Text(
              'البرندات المدعومة:',
              style: GoogleFonts.cairo(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: center.supportedBrands.map((brand) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    brand,
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
      ),
    );
  }
}

class _CenterCardSkeleton extends StatelessWidget {
  const _CenterCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E1E),
      highlightColor: const Color(0xFF2A2A2A),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
