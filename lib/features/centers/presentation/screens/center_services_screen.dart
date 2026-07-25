import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routes_manager/routes.dart';
import '../../domain/entities/service_entity.dart';
import '../cubit/my_center_services_cubit.dart';
import '../cubit/my_center_services_state.dart';

class CenterServicesScreen extends StatelessWidget {
  const CenterServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MyCenterServicesCubit>()..fetchMyServices(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text(
            'خدمات مركز الصيانة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          foregroundColor: const Color(0xFFFFC107),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFFC107)),
                tooltip: 'إضافة خدمة جديدة',
                onPressed: () async {
                  final added = await Navigator.pushNamed(ctx, Routes.addCenterServiceRoute);
                  if (added == true) {
                    if (ctx.mounted) {
                      ctx.read<MyCenterServicesCubit>().fetchMyServices();
                    }
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton.extended(
            backgroundColor: const Color(0xFFFFC107),
            foregroundColor: Colors.black,
            icon: const Icon(Icons.add),
            label: Text(
              'إضافة خدمة',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              final added = await Navigator.pushNamed(ctx, Routes.addCenterServiceRoute);
              if (added == true) {
                if (ctx.mounted) {
                  ctx.read<MyCenterServicesCubit>().fetchMyServices();
                }
              }
            },
          ),
        ),
        body: const Directionality(
          textDirection: TextDirection.rtl,
          child: _CenterServicesBody(),
        ),
      ),
    );
  }
}

class _CenterServicesBody extends StatelessWidget {
  const _CenterServicesBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyCenterServicesCubit, MyCenterServicesState>(
      builder: (context, state) {
        if (state is MyCenterServicesLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          );
        }

        if (state is MyCenterServicesError) {
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
                      context.read<MyCenterServicesCubit>().fetchMyServices();
                    },
                  ),
                ],
              ),
            ),
          );
        }

        if (state is MyCenterServicesLoaded) {
          final services = state.services;

          if (services.isEmpty) {
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<MyCenterServicesCubit>().fetchMyServices(),
              color: const Color(0xFFFFC107),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.build_circle_outlined,
                          color: Colors.white24,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد خدمات مسجلة حالياً لمركز الصيانة',
                          style: GoogleFonts.cairo(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'اضغط زر "إضافة خدمة" للبدء بإتاحة خدمات جديدة للعملاء.',
                          style: GoogleFonts.cairo(
                            color: Colors.white38,
                            fontSize: 11,
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
                context.read<MyCenterServicesCubit>().fetchMyServices(),
            color: const Color(0xFFFFC107),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceCard(context, service);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceEntity service) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.centerServiceDetailsRoute,
          arguments: service.id,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: service.isAvailable
                ? const Color(0xFFFFC107).withValues(alpha: 0.2)
                : Colors.white10,
          ),
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
          // Row 1: Title & Availability Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.build,
                      color: Color(0xFFFFC107),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        service.serviceName,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 15,
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
                  color: service.isAvailable
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: service.isAvailable
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
                child: Text(
                  service.isAvailable ? 'متاحة' : 'غير متاحة',
                  style: GoogleFonts.cairo(
                    color: service.isAvailable ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (service.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              service.description,
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.white10, height: 1),
          ),

          // Row 2: Price & Estimated Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.monetization_on_outlined,
                      color: Color(0xFFFFC107), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'السعر: ',
                    style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                  ),
                  Text(
                    '${service.price.toStringAsFixed(0)} د.ع',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFFFC107),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (service.estimatedTime.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: Colors.white54, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'الوقت المقدر: ${service.estimatedTime}',
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
