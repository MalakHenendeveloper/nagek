import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../cubit/center_details_cubit.dart';
import '../cubit/center_details_state.dart';
import '../widgets/center_skeletons.dart';
import '../../domain/entities/center_entity.dart';
import '../../domain/entities/service_entity.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/routes_manager/routes.dart';





class CenterDetailsScreen extends StatefulWidget {
  final String centerId;

  const CenterDetailsScreen({super.key, required this.centerId});

  @override
  State<CenterDetailsScreen> createState() => _CenterDetailsScreenState();
}

class _CenterDetailsScreenState extends State<CenterDetailsScreen> {
  late CenterDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<CenterDetailsCubit>()..fetchCenterDetails(widget.centerId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFAF5),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<CenterDetailsCubit, CenterDetailsState>(
            builder: (context, state) {
              if (state is CenterDetailsLoading || state is CenterDetailsInitial) {
                return const CenterDetailsSkeleton();
              } else if (state is CenterDetailsError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.cairo(color: Colors.red),
                  ),
                );
              } else if (state is CenterDetailsLoaded) {
                final center = state.center;
                return Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        _buildSliverAppBar(center),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildActionButtons(center),
                                const SizedBox(height: 24),
                                _buildFeaturesBadges(),
                                const SizedBox(height: 24),
                                _buildSectionTitle('خدمات الصيانة', 'عرض الكل'),
                                const SizedBox(height: 16),
                                _buildServicesList(state.services, center.inspectionFee),
                                const SizedBox(height: 24),
                                _buildSectionTitle('الأجهزة المدعومة'),
                                const SizedBox(height: 16),
                                _buildSupportedBrands(center.supportedBrands),
                                const SizedBox(height: 100), // Space for bottom button
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildBottomButton(),
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

  Widget _buildSliverAppBar(CenterEntity center) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      backgroundColor: const Color(0xFFFCFAF5),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () {},
        ),
      ],
      title: Text(
        'تفاصيل المركز',
        style: GoogleFonts.cairo(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Dummy Cover Image
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2C3E50),
              ),
              child: const Center(
                child: Icon(Icons.home_repair_service, color: Colors.white24, size: 80),
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Center Info Overlay
            Positioned(
              bottom: 20,
              right: 20,
              left: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          center.name,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              center.rating.toString(),
                              style: GoogleFonts.cairo(
                                color: const Color(0xFFFFC107),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '|',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${center.city}، ${center.address}',
                                style: GoogleFonts.cairo(
                                  color: Colors.white.withValues(alpha: 0.8),
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
                  // Logo Box
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                      image: center.logo.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(center.logo),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: center.logo.isEmpty
                        ? const Center(
                            child: Icon(Icons.handyman, color: Color(0xFFFFC107)),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(CenterEntity center) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final Uri url = Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=${center.coordinates.lat},${center.coordinates.lng}');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              side: const BorderSide(color: Colors.black87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.location_on_outlined),
            label: Text(
              'الموقع',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final Uri tel = Uri.parse('tel:${center.phone}');
              if (await canLaunchUrl(tel)) {
                await launchUrl(tel);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF555555),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.phone),
            label: Text(
              'اتصال',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildBadge(Icons.verified_outlined, 'معتمد'),
        _buildBadge(Icons.timer_outlined, 'إصلاح سريع'),
        _buildBadge(Icons.shield_outlined, 'ضمان 6 أشهر'),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF8B7500)),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, [String? action]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (action != null)
          Text(
            action,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: const Color(0xFF8B7500),
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildServicesList(List<ServiceEntity> apiServices, double inspectionFee) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'رسوم الفحص والتوصيل',
        'subtitle': 'فحص وتحديد العطل وتسليم الجهاز',
        'price': '${inspectionFee.toInt()} د.ع',
        'icon': Icons.search,
      }
    ];

    for (var service in apiServices) {
      if (!service.isAvailable) continue;

      IconData icon = Icons.build_outlined;
      final name = service.serviceName.toLowerCase();
      if (name.contains('شاشة') || name.contains('screen')) {
        icon = Icons.phone_iphone;
      } else if (name.contains('بطارية') || name.contains('battery')) {
        icon = Icons.battery_charging_full;
      } else if (name.contains('سماعة') || name.contains('speaker') || name.contains('headphone') || name.contains('سماعه')) {
        icon = Icons.volume_up;
      } else if (name.contains('سوف') || name.contains('برمجة') || name.contains('software')) {
        icon = Icons.settings;
      }

      String subtitle = service.description;
      if (service.estimatedTime.isNotEmpty || service.warranty.isNotEmpty) {
        List<String> details = [];
        if (service.estimatedTime.isNotEmpty) {
          details.add('الوقت: ${service.estimatedTime}');
        }
        if (service.warranty.isNotEmpty) {
          details.add('الضمان: ${service.warranty}');
        }
        subtitle += ' (${details.join(' | ')})';
      }

      items.add({
        'title': service.serviceName,
        'subtitle': subtitle,
        'price': '${service.price.toInt()} د.ع',
        'icon': icon,
      });
    }

    return Column(
      children: items.map((service) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(service['icon'] as IconData, color: const Color(0xFF8B7500)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['title'] as String,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      service['subtitle'] as String,
                      style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    service['price'] as String,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF8B7500)),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSupportedBrands(List<String> brands) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: brands.map((brand) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: brand.toLowerCase() == 'iphone' || brand.toLowerCase() == 'apple' 
                ? Colors.black 
                : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            brand,
            style: GoogleFonts.cairo(
              color: brand.toLowerCase() == 'iphone' || brand.toLowerCase() == 'apple' 
                  ? Colors.white 
                  : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAF5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 8,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.createOrderRoute,
              arguments: widget.centerId,
            );
          },
          style: ElevatedButton.styleFrom(

            backgroundColor: const Color(0xFFFFC107),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'إنشاء طلب صيانة',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
