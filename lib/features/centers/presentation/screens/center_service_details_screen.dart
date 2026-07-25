import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routes_manager/routes.dart';
import '../../domain/entities/service_entity.dart';
import '../cubit/center_service_details_cubit.dart';
import '../cubit/center_service_details_state.dart';

class CenterServiceDetailsScreen extends StatelessWidget {
  final String serviceId;

  const CenterServiceDetailsScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<CenterServiceDetailsCubit>()..fetchServiceDetails(serviceId),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text(
            'تفاصيل الخدمة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          foregroundColor: const Color(0xFFFFC107),
          actions: [
            BlocBuilder<CenterServiceDetailsCubit, CenterServiceDetailsState>(
              builder: (context, state) {
                if (state is CenterServiceDetailsLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFFFC107)),
                    tooltip: 'تعديل الخدمة',
                    onPressed: () async {
                      final updated = await Navigator.pushNamed(
                        context,
                        Routes.editCenterServiceRoute,
                        arguments: state.service,
                      );
                      if (updated == true && context.mounted) {
                        context
                            .read<CenterServiceDetailsCubit>()
                            .fetchServiceDetails(serviceId);
                      }
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<CenterServiceDetailsCubit, CenterServiceDetailsState>(
            builder: (context, state) {
              if (state is CenterServiceDetailsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFC107)),
                );
              }

              if (state is CenterServiceDetailsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(color: Colors.redAccent, fontSize: 13),
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
                          context.read<CenterServiceDetailsCubit>().fetchServiceDetails(serviceId);
                        },
                      ),
                    ],
                  ),
                );
              }

              if (state is CenterServiceDetailsLoaded) {
                return _buildServiceDetails(state.service);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDetails(ServiceEntity service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E2400), Color(0xFF1A1500)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFC107).withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.08),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.build,
                        color: Color(0xFFFFC107),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        service.serviceName,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: service.isAvailable
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: service.isAvailable
                          ? Colors.greenAccent.withValues(alpha: 0.5)
                          : Colors.redAccent.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        service.isAvailable ? Icons.check_circle : Icons.cancel,
                        color: service.isAvailable ? Colors.greenAccent : Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        service.isAvailable ? 'الخدمة متاحة حالياً' : 'الخدمة غير متاحة حالياً',
                        style: GoogleFonts.cairo(
                          color: service.isAvailable ? Colors.greenAccent : Colors.redAccent,
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

          const SizedBox(height: 20),

          // Description Card
          if (service.description.isNotEmpty)
            _buildInfoCard(
              icon: Icons.description_outlined,
              title: 'وصف الخدمة',
              child: Text(
                service.description,
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),

          const SizedBox(height: 14),

          // Price Card
          _buildInfoCard(
            icon: Icons.monetization_on_outlined,
            title: 'سعر الخدمة',
            child: Text(
              '${service.price.toStringAsFixed(0)} د.ع',
              style: GoogleFonts.cairo(
                color: const Color(0xFFFFC107),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Estimated Time Card
          if (service.estimatedTime.isNotEmpty)
            _buildInfoCard(
              icon: Icons.timer_outlined,
              title: 'الوقت المقدر',
              child: Text(
                service.estimatedTime,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 14),

          // Warranty Card
          if (service.warranty.isNotEmpty)
            _buildInfoCard(
              icon: Icons.verified_outlined,
              title: 'الكفالة / الضمان',
              child: Text(
                service.warranty,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFFC107), size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cairo(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
