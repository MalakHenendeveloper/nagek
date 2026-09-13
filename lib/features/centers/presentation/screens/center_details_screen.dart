import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              if (state is CenterDetailsLoading ||
                  state is CenterDetailsInitial) {
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
                                _buildSectionTitle('خدمات الصيانة'),
                                const SizedBox(height: 16),
                                _buildServicesList(
                                  state.services,
                                  center.inspectionFee,
                                ),
                                if (center.supportedDeviceTypes.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  _buildSectionTitle('نوع الأجهزة المدعومة'),
                                  const SizedBox(height: 16),
                                  _buildSupportedDeviceTypes(
                                    center.supportedDeviceTypes,
                                  ),
                                ],
                                if (center.supportedBrands.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  _buildSectionTitle('الماركات المدعومة'),
                                  const SizedBox(height: 16),
                                  _buildSupportedBrands(center.supportedBrands),
                                ],
                                const SizedBox(
                                  height: 100,
                                ), // Space for bottom button
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildBottomButton(center),
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
      backgroundColor: const Color(0xFF141414),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
      ],
      title: Text(
        'تفاصيل المركز',
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Center Cover Image
            if (center.logo.isNotEmpty)
              Image.network(
                center.logo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF2C3E50),
                  child: const Center(
                    child: Icon(
                      Icons.home_repair_service,
                      color: Colors.white24,
                      size: 80,
                    ),
                  ),
                ),
              )
            else
              Container(
                color: const Color(0xFF2C3E50),
                child: const Center(
                  child: Icon(
                    Icons.home_repair_service,
                    color: Colors.white24,
                    size: 80,
                  ),
                ),
              ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.85),
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
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFC107),
                              size: 16,
                            ),
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
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
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
                            child: Icon(
                              Icons.handyman,
                              color: Color(0xFFFFC107),
                            ),
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
          child: OutlinedButton.icon(
            onPressed: () async {
              final Uri uri = Uri(scheme: 'tel', path: center.phone);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            icon: const Icon(Icons.call, color: Color(0xFF8B7500)),
            label: Text(
              'اتصال',
              style: GoogleFonts.cairo(
                color: const Color(0xFF8B7500),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF8B7500)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showLocationDialog(context, center),
            icon: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF8B7500),
            ),
            label: Text(
              'الموقع',
              style: GoogleFonts.cairo(
                color: const Color(0xFF8B7500),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF8B7500)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLocationDialog(BuildContext context, CenterEntity center) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF8B7500)),
                const SizedBox(width: 8),
                Text(
                  'موقع المركز',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCFAF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_city,
                            size: 18,
                            color: Color(0xFF8B7500),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'المدينة:',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              center.city.isNotEmpty ? center.city : 'غير محدد',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.pin_drop_outlined,
                            size: 18,
                            color: Color(0xFF8B7500),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'العنوان التفصيلي:',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  center.address.isNotEmpty
                                      ? center.address
                                      : 'غير متوفر',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    final fullAddress = '${center.city}، ${center.address}'
                        .trim();
                    Clipboard.setData(ClipboardData(text: fullAddress));
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم نسخ العنوان بنجاح',
                          style: GoogleFonts.cairo(color: Colors.white),
                        ),
                        backgroundColor: Colors.black87,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: Color(0xFF8B7500),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'نسخ العنوان',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: const Color(0xFF8B7500),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'إغلاق',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
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

  void _showServiceDetailsDialog(
    BuildContext context,
    ServiceEntity service,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Header with title and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF9E6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.build_outlined,
                              color: Color(0xFF8B7500),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              service.serviceName,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 16),

                // Price Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCFAF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تكلفة الخدمة:',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        '${service.price.toInt()} د.ع',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B7500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Details Row (Estimated Time & Warranty)
                if (service.estimatedTime.isNotEmpty ||
                    service.warranty.isNotEmpty) ...[
                  Row(
                    children: [
                      if (service.estimatedTime.isNotEmpty)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 20,
                                  color: Color(0xFF8B7500),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'الوقت المتوقع',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        service.estimatedTime.contains('ساع') ||
                                                service.estimatedTime.contains(
                                                  'يوم',
                                                )
                                            ? service.estimatedTime
                                            : '${service.estimatedTime} ساعات',
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (service.estimatedTime.isNotEmpty &&
                          service.warranty.isNotEmpty)
                        const SizedBox(width: 12),
                      if (service.warranty.isNotEmpty)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  size: 20,
                                  color: Color(0xFF8B7500),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'فترة الضمان',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        service.warranty,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Description Details
                if (service.description.isNotEmpty) ...[
                  Text(
                    'تفاصيل الخدمة',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      service.description,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إغلاق',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildServicesList(
    List<ServiceEntity> apiServices,
    double inspectionFee,
  ) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'رسوم التوصيل (ذهاب وعودة)',
        'subtitle':
            'توصيل الجهاز من العميل للمركز وإرجاعه (تُحسب وتُضاف لتكلفة الطلب النهائية | الفحص مجاني)',
        'price': inspectionFee > 0
            ? '${inspectionFee.toInt()} د.ع'
            : 'تُحسب بالطلب',
        'icon': Icons.local_shipping_outlined,
        'isDeliveryFee': true,
        'entity': null,
      },
    ];

    for (var service in apiServices) {
      if (!service.isAvailable) continue;

      IconData icon = Icons.build_outlined;
      final name = service.serviceName.toLowerCase();
      if (name.contains('شاشة') || name.contains('screen')) {
        icon = Icons.phone_iphone;
      } else if (name.contains('بطارية') || name.contains('battery')) {
        icon = Icons.battery_charging_full;
      } else if (name.contains('سماعة') ||
          name.contains('speaker') ||
          name.contains('headphone') ||
          name.contains('سماعه')) {
        icon = Icons.volume_up;
      } else if (name.contains('سوف') ||
          name.contains('برمجة') ||
          name.contains('software')) {
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
        'isDeliveryFee': false,
        'entity': service,
      });
    }

    return Column(
      children: items.map((service) {
        final isDeliveryFee = service['isDeliveryFee'] == true;
        final ServiceEntity? entity = service['entity'] as ServiceEntity?;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDeliveryFee || entity == null
                ? null
                : () => _showServiceDetailsDialog(context, entity),
            borderRadius: BorderRadius.circular(12),
            child: Container(
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
                    child: Icon(
                      service['icon'] as IconData,
                      color: const Color(0xFF8B7500),
                    ),
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
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        service['price'] as String,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B7500),
                        ),
                      ),
                      if (!isDeliveryFee)
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSupportedDeviceTypes(List<String> types) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: types.map((type) {
        final info = _getDeviceTypeInfo(type);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFC107).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(info.icon, size: 16, color: const Color(0xFF8B7500)),
              const SizedBox(width: 8),
              Text(
                info.name,
                style: GoogleFonts.cairo(
                  color: const Color(0xFF8B7500),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  ({String name, IconData icon}) _getDeviceTypeInfo(String type) {
    final lower = type.toLowerCase().trim();
    if (lower.contains('phone') ||
        lower.contains('هاتف') ||
        lower.contains('موبايل')) {
      return (name: 'هواتف ذكية (Phone)', icon: Icons.phone_iphone_rounded);
    } else if (lower.contains('tablet') ||
        lower.contains('تابلت') ||
        lower.contains('لوح')) {
      return (name: 'أجهزة لوحية (Tablet)', icon: Icons.tablet_mac_rounded);
    } else if (lower.contains('laptop') ||
        lower.contains('لابتوب') ||
        lower.contains('كمبيوتر') ||
        lower.contains('حاسوب')) {
      return (name: 'حواسيب ولابتوب (Laptop)', icon: Icons.laptop_mac_rounded);
    } else if (lower.contains('watch') || lower.contains('ساعة')) {
      return (name: 'ساعات ذكية (Watch)', icon: Icons.watch_rounded);
    }
    return (name: type, icon: Icons.devices_rounded);
  }

  Widget _buildSupportedBrands(List<String> brands) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: brands.map((brand) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
          ),
          child: Text(
            brand,
            style: GoogleFonts.cairo(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomButton(CenterEntity center) {
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
              arguments: {
                'centerId': widget.centerId,
                'supportedDeviceTypes': center.supportedDeviceTypes,
              },
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
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
