import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/di/di.dart';
import '../../cubit/admin_center_details_cubit.dart';
import '../../cubit/admin_center_details_state.dart';
import '../../../domain/entities/admin_center_details_entity.dart';
import '../../../domain/entities/admin_center_entity.dart';
import '../../../../centers/domain/entities/service_entity.dart';

class AdminCenterDetailsBottomSheet extends StatefulWidget {
  final String centerId;

  const AdminCenterDetailsBottomSheet({super.key, required this.centerId});

  static Future<bool?> show(BuildContext context, String centerId) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminCenterDetailsBottomSheet(centerId: centerId),
    );
  }

  @override
  State<AdminCenterDetailsBottomSheet> createState() => _AdminCenterDetailsBottomSheetState();
}

class _AdminCenterDetailsBottomSheetState extends State<AdminCenterDetailsBottomSheet> {
  bool _wasModified = false;

  final Map<String, String> _statusMap = {
    'pending': 'بانتظار الموافقة',
    'active': 'نشط / مفعل',
    'suspended': 'موقوف مؤقتاً',
  };

  final Map<String, Color> _statusColors = {
    'pending': const Color(0xFFFFC107),
    'active': const Color(0xFF4CAF50),
    'suspended': Colors.redAccent,
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminCenterDetailsCubit>(
      create: (context) => getIt<AdminCenterDetailsCubit>()..fetchCenterDetails(widget.centerId),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context).pop(_wasModified);
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Color(0xFF0F0F0F),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(color: Colors.white10, width: 1.5),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Notch
              Container(
                width: 50,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تفاصيل مركز الصيانة',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context, _wasModified),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),

              // Content
              Expanded(
                child: BlocConsumer<AdminCenterDetailsCubit, AdminCenterDetailsState>(
                  listener: (context, state) {
                    if (state is AdminCenterDetailsLoaded && _wasModified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تحديث حالة مركز الصيانة بنجاح',
                            style: GoogleFonts.cairo(color: Colors.white),
                          ),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else if (state is AdminCenterStatusUpdateError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: GoogleFonts.cairo(color: Colors.white),
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AdminCenterDetailsLoading || state is AdminCenterDetailsInitial) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFFC107)),
                      );
                    } else if (state is AdminCenterDetailsError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
                              const SizedBox(height: 12),
                              Text(
                                state.message,
                                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFC107),
                                  foregroundColor: Colors.black,
                                ),
                                  onPressed: () {
                                    context.read<AdminCenterDetailsCubit>().fetchCenterDetails(widget.centerId);
                                  },
                                icon: const Icon(Icons.refresh, size: 18),
                                label: Text('إعادة المحاولة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // For Loaded, LoadingStatus and StatusUpdateError, we can show details
                    AdminCenterDetailsEntity? details;
                    bool isUpdating = false;

                    if (state is AdminCenterDetailsLoaded) {
                      details = state.details;
                    } else if (state is AdminCenterDetailsLoadingStatus) {
                      details = state.details;
                      isUpdating = true;
                    } else if (state is AdminCenterStatusUpdateError) {
                      details = state.details;
                    }

                    if (details != null) {
                      return _buildDetailsContent(context, details, isUpdating);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsContent(BuildContext context, AdminCenterDetailsEntity details, bool isUpdating) {
    final center = details.center;
    final stats = details.statistics;
    final services = details.services;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Center Header Card
          _buildCenterHeader(center),
          const SizedBox(height: 20),

          // Status Manager Section
          _buildSectionTitle('تحديث حالة الحساب'),
          const SizedBox(height: 10),
          _buildStatusSelector(context, center, isUpdating),
          const SizedBox(height: 20),

          // Statistics Cards
          _buildStatisticsRow(stats),
          const SizedBox(height: 20),

          // Owner Info
          if (center.owner != null) ...[
            _buildSectionTitle('بيانات مالك المركز'),
            const SizedBox(height: 10),
            _buildOwnerCard(center.owner!),
            const SizedBox(height: 20),
          ],

          // Supported Brands
          if (center.supportedBrands.isNotEmpty) ...[
            _buildSectionTitle('العلامات التجارية المدعومة'),
            const SizedBox(height: 10),
            _buildBrandsWrap(center.supportedBrands),
            const SizedBox(height: 20),
          ],

          // Supported Device Types
          if (center.supportedDeviceTypes.isNotEmpty) ...[
            _buildSectionTitle('أنواع الأجهزة المدعومة'),
            const SizedBox(height: 10),
            _buildDeviceTypesWrap(center.supportedDeviceTypes),
            const SizedBox(height: 20),
          ],

          // Services
          _buildSectionTitle('خدمات المركز (${services.length})'),
          const SizedBox(height: 10),
          if (services.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Center(
                child: Text(
                  'لا توجد خدمات مسجلة لهذا المركز حالياً',
                  style: GoogleFonts.cairo(color: Colors.white38, fontSize: 13),
                ),
              ),
            )
          else
            ...services.map((s) => _buildServiceCard(s)),

          const SizedBox(height: 20),

          // Center Info Footer
          _buildCenterInfoFooter(center),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCenterHeader(AdminCenterEntity center) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.white10,
              child: center.logo.isNotEmpty
                  ? Image.network(
                      center.logo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Color(0xFFFFC107), size: 30),
                    )
                  : const Icon(Icons.business, color: Color(0xFFFFC107), size: 30),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center.name,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white38, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${center.city} - ${center.address}',
                        style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (_statusColors[center.status] ?? Colors.grey).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _statusMap[center.status] ?? center.status,
                        style: GoogleFonts.cairo(
                          color: _statusColors[center.status] ?? Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${center.rating.toStringAsFixed(1)} (${center.totalRatings})',
                      style: GoogleFonts.cairo(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector(BuildContext context, AdminCenterEntity center, bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.white30, size: 20),
              const SizedBox(width: 10),
              Text(
                'تغيير حالة الحساب:',
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFC107)),
            )
          else
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: center.status,
                dropdownColor: const Color(0xFF1E1E1E),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFC107)),
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                onChanged: (newStatus) {
                  if (newStatus != null && newStatus != center.status) {
                    setState(() {
                      _wasModified = true;
                    });
                    context.read<AdminCenterDetailsCubit>().updateCenterStatus(center.id, newStatus);
                  }
                },
                items: _statusMap.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: GoogleFonts.cairo(
                        color: _statusColors[entry.key] ?? Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsRow(AdminCenterStatisticsEntity stats) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('إجمالي الطلبات', stats.ordersCount.toString(), Icons.assignment_outlined, const Color(0xFFFFC107))),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('طلبات نشطة', stats.activeOrders.toString(), Icons.pending_actions_outlined, Colors.blueAccent)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('مكتملة', stats.completedOrders.toString(), Icons.check_circle_outline, const Color(0xFF4CAF50))),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cairo(color: Colors.white38, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerCard(AdminCenterOwnerEntity owner) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, 'الاسم', owner.name.isNotEmpty ? owner.name : 'غير محدد'),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.phone_android, 'الهاتف', owner.phone.isNotEmpty ? owner.phone : 'غير محدد'),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.email_outlined, 'البريد', owner.email.isNotEmpty ? owner.email : 'غير محدد'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 18),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: GoogleFonts.cairo(color: Colors.white38, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
            textDirection: label == 'الهاتف' || label == 'البريد' ? TextDirection.ltr : null,
            textAlign: label == 'الهاتف' || label == 'البريد' ? TextAlign.left : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBrandsWrap(List<String> brands) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: brands.map((brand) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.2)),
          ),
          child: Text(
            brand,
            style: GoogleFonts.cairo(
              color: const Color(0xFFFFC107),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeviceTypesWrap(List<String> types) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        String label;
        IconData icon;
        switch (type) {
          case 'phone':
            label = 'هواتف ذكية';
            icon = Icons.phone_android;
            break;
          case 'tablet':
            label = 'أجهزة لوحية';
            icon = Icons.tablet_android;
            break;
          case 'laptop':
            label = 'حواسيب محمولة';
            icon = Icons.laptop;
            break;
          default:
            label = type;
            icon = Icons.devices;
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.blueAccent, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: Colors.blueAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServiceCard(ServiceEntity service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  service.serviceName,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: service.isAvailable
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                      : Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  service.isAvailable ? 'متوفرة' : 'غير متوفرة',
                  style: GoogleFonts.cairo(
                    color: service.isAvailable ? const Color(0xFF4CAF50) : Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (service.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              service.description,
              style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.monetization_on_outlined, color: Color(0xFFFFC107), size: 14),
              const SizedBox(width: 4),
              Text(
                '${service.price.toStringAsFixed(0)} ر.س',
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Icon(Icons.timer_outlined, color: Colors.white38, size: 14),
              const SizedBox(width: 4),
              Text(
                service.estimatedTime,
                style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
              ),
              if (service.warranty.isNotEmpty) ...[
                const SizedBox(width: 12),
                const Icon(Icons.verified_outlined, color: Colors.white38, size: 14),
                const SizedBox(width: 4),
                Text(
                  service.warranty,
                  style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenterInfoFooter(AdminCenterEntity center) {
    final String createdStr = center.createdAt.isNotEmpty
        ? DateTime.tryParse(center.createdAt)?.toLocal().toString().split('.')[0] ?? ''
        : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.white38, size: 16),
              const SizedBox(width: 8),
              Text('هاتف المركز: ', style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12)),
              Text(
                center.phone,
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.email_outlined, color: Colors.white38, size: 16),
              const SizedBox(width: 8),
              Text('بريد المركز: ', style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12)),
              Expanded(
                child: Text(
                  center.email,
                  style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.monetization_on_outlined, color: Colors.white38, size: 16),
              const SizedBox(width: 8),
              Text('رسوم الفحص: ', style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12)),
              Text(
                '${center.inspectionFee.toStringAsFixed(0)} ر.س',
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          if (createdStr.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Colors.white38, size: 16),
                const SizedBox(width: 8),
                Text('تاريخ الإنشاء: ', style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12)),
                Text(
                  createdStr,
                  style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        color: const Color(0xFFFFC107),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
