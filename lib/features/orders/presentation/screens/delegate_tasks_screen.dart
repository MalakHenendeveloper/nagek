import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routes_manager/routes.dart';
import '../../../map/data/datasources/map_remote_data_source.dart';
import '../../domain/entities/order_entity.dart';
import '../../../../core/services/image_picker_service.dart';
import '../cubit/delegate_orders_cubit.dart';
import '../cubit/delegate_orders_state.dart';

class DelegateTasksScreen extends StatefulWidget {
  const DelegateTasksScreen({super.key});

  @override
  State<DelegateTasksScreen> createState() => _DelegateTasksScreenState();
}

enum _TaskStage { awaitingPickup, headingToCenter, atCenter, readyForDelivery }

class _DelegateTasksScreenState extends State<DelegateTasksScreen> {
  late final DelegateOrdersCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<DelegateOrdersCubit>();
    _cubit.fetchDelegateOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Text(
          'مهامي النشطة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFFC107)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<DelegateOrdersCubit, DelegateOrdersState>(
          bloc: _cubit,
          listener: (context, state) {
            if (state is DelegateOrdersUploadLoading) {
              _showProgressDialog(context, 'جاري رفع صور الاستلام...');
            } else if (state is DelegateOrdersUploadSuccess) {
              // Dialog stays, confirm is next
            } else if (state is DelegateOrdersUploadError) {
              Navigator.of(context, rootNavigator: true).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    state.message,
                    style: GoogleFonts.cairo(color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            } else if (state is DelegateOrdersConfirmLoading) {
              // Update the dialog text (pop old, show new)
              Navigator.of(context, rootNavigator: true).pop();
              _showProgressDialog(
                context,
                'جاري تأكيد استلام الجهاز من العميل...',
              );
            } else if (state is DelegateOrdersConfirmSuccess) {
              Navigator.of(context, rootNavigator: true).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    'تم رفع الصور وتأكيد استلام الجهاز بنجاح ✅',
                    style: GoogleFonts.cairo(color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            } else if (state is DelegateOrdersConfirmError) {
              Navigator.of(context, rootNavigator: true).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    state.message,
                    style: GoogleFonts.cairo(color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            } else if (state is DelegateOrdersDropCenterLoading) {
              _showProgressDialog(
                context,
                'جاري رفع الصور وتأكيد تسليم الجهاز للمركز...',
              );
            } else if (state is DelegateOrdersDropCenterSuccess) {
              Navigator.of(context, rootNavigator: true).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    'تم رفع الصور وتأكيد تسليم الجهاز للمركز بنجاح ✅',
                    style: GoogleFonts.cairo(color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            } else if (state is DelegateOrdersDropCenterError) {
              Navigator.of(context, rootNavigator: true).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    state.message,
                    style: GoogleFonts.cairo(color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            } else if (state is DelegateOrdersPickupCenterLoading) {
              _showProgressDialog(
                context,
                'جاري رفع الصور وتأكيد استلام الجهاز من المركز...',
              );
            } else if (state is DelegateOrdersPickupCenterSuccess) {
              Navigator.of(context, rootNavigator: true).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    'تم تأكيد استلام الجهاز من المركز بنجاح ✅',
                    style: GoogleFonts.cairo(color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            } else if (state is DelegateOrdersPickupCenterError) {
              Navigator.of(context, rootNavigator: true).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    state.message,
                    style: GoogleFonts.cairo(color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            } else if (state is DelegateOrdersConfirmDeliveryLoading) {
              _showProgressDialog(
                context,
                'جاري رفع الصور وتأكيد تسليم الجهاز للعميل...',
              );
            } else if (state is DelegateOrdersConfirmDeliverySuccess) {
              Navigator.of(context, rootNavigator: true).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    'تم تسليم الجهاز للعميل بنجاح ✅',
                    style: GoogleFonts.cairo(color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            } else if (state is DelegateOrdersConfirmDeliveryError) {
              Navigator.of(context, rootNavigator: true).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    state.message,
                    style: GoogleFonts.cairo(color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            }
          },
          buildWhen: (previous, current) {
            return current is DelegateOrdersInitial ||
                current is DelegateOrdersLoading ||
                current is DelegateOrdersLoaded ||
                current is DelegateOrdersError;
          },
          builder: (context, state) {
            if (state is DelegateOrdersLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFC107)),
              );
            } else if (state is DelegateOrdersError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[300], size: 64),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _cubit.fetchDelegateOrders(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        'إعادة المحاولة',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is DelegateOrdersLoaded) {
              final activeTasks = state.orders.where(_isActiveTask).toList();

              if (activeTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt,
                        color: Colors.greenAccent.withValues(alpha: 0.6),
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مهام نشطة حالياً',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'يمكنك قبول مهام جديدة من شاشة الطلبات المتاحة',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _cubit.fetchDelegateOrders(),
                color: const Color(0xFFFFC107),
                child: DefaultTabController(
                  length: _TaskStage.values.length,
                  child: Column(
                    children: [
                      Container(
                        color: const Color(0xFF141414),
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          dividerColor: Colors.transparent,
                          indicatorColor: const Color(0xFFFFC107),
                          labelColor: const Color(0xFFFFC107),
                          unselectedLabelColor: Colors.white54,
                          labelStyle: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          tabs: _TaskStage.values
                              .map(
                                (stage) => Tab(
                                  text: '${_stageTitle(stage)} (${_tasksForStage(activeTasks, stage).length})',
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: _TaskStage.values
                              .map(
                                (stage) => _buildStageTasksList(
                                  context,
                                  _tasksForStage(activeTasks, stage),
                                  stage,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  bool _isActiveTask(OrderEntity order) {
    final status = order.status.toLowerCase();
    return status != 'delivered' && status != 'completed';
  }

  _TaskStage _taskStageFor(OrderEntity order) {
    switch (order.status.toLowerCase()) {
      case 'delegate_assigned':
      case 'picking_up':
        return _TaskStage.awaitingPickup;
      case 'picked_up':
        return _TaskStage.headingToCenter;
      case 'repaired':
      case 'ready':
      case 'delivering':
      case 'returning':
        return _TaskStage.readyForDelivery;
      default:
        return _TaskStage.atCenter;
    }
  }

  List<OrderEntity> _tasksForStage(
    List<OrderEntity> activeTasks,
    _TaskStage stage,
  ) => activeTasks.where((task) => _taskStageFor(task) == stage).toList();

  String _stageTitle(_TaskStage stage) => switch (stage) {
        _TaskStage.awaitingPickup => 'بانتظار الاستلام',
        _TaskStage.headingToCenter => 'في الطريق للمركز',
        _TaskStage.atCenter => 'لدى المركز',
        _TaskStage.readyForDelivery => 'جاهز للتوصيل',
      };

  Widget _buildStageTasksList(
    BuildContext context,
    List<OrderEntity> tasks,
    _TaskStage stage,
  ) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مهام في قسم ${_stageTitle(stage)}',
          style: GoogleFonts.cairo(color: Colors.white54, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _buildTaskCard(context, tasks[index]),
    );
  }

  Widget _buildTaskCard(BuildContext context, OrderEntity order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFC107).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment,
                    color: Color(0xFFFFC107),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'طلب #${order.id.length > 8 ? order.id.substring(order.id.length - 8) : order.id}',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device info
                _buildInfoRow(
                  Icons.phone_android,
                  'الجهاز',
                  '${order.device.brand} ${order.device.model}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.build_outlined,
                  'نوع المشكلة',
                  _translateProblemType(order.device.problemType),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'العنوان',
                  '${order.pickupAddress.address}، ${order.pickupAddress.city}',
                ),
                const SizedBox(height: 8),
                // Customer phone
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 16, color: Colors.white38),
                    const SizedBox(width: 8),
                    Text(
                      'هاتف العميل: ',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                    ),
                    GestureDetector(
                      onTap: order.client?.phone != null
                          ? () => launchUrl(
                              Uri.parse('tel:${order.client!.phone}'),
                            )
                          : null,
                      child: Text(
                        order.client?.phone ?? 'غير متوفر',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: const Color(0xFFFFC107),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                if (order.fees.delivery > 0) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.monetization_on_outlined,
                    'رسوم التوصيل',
                    '${order.fees.delivery.toStringAsFixed(0)} د.ع',
                  ),
                ],
                const SizedBox(height: 16),
                if (order.status.toLowerCase() == 'delegate_assigned' ||
                    order.status.toLowerCase() == 'picking_up') ...[
                  // Security warning banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تنبيه للحماية: قبل تحرك المندوب، تأكد من رفع الصور وأن الحالة أصبحت "تم تأكيد الاستلام"',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.orange[200],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Navigate to client location button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E88E5),
                        side: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.map_outlined),
                      label: Text(
                        'عرض المسار لموقع العميل على الخريطة',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        final addr = order.pickupAddress.address;
                        final city = order.pickupAddress.city;
                        final fullAddr = (city.isNotEmpty && !addr.contains(city))
                            ? '$addr، $city'
                            : addr;
                        _navigateToMapRoute(
                          context,
                          fullAddr,
                          'موقع العميل',
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Upload photos & confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(
                        'رفع صور الجهاز وتأكيد الاستلام',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        _showPickupPhotosBottomSheet(context, order.id);
                      },
                    ),
                  ),
                ] else if (order.status.toLowerCase() == 'picked_up') ...[
                  // Drop center warning banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'يرجى رفع صور الجهاز عند تسليمه لمركز الصيانة لتأكيد تسليم الطلب.',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.blue[200],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Navigate to center location button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E88E5),
                        side: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.map_outlined),
                      label: Text(
                        'عرض المسار لمركز الصيانة على الخريطة',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _navigateToMapRoute(
                        context,
                        order.repairCenter.address,
                        order.repairCenter.name,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Confirm Drop Center button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.business_outlined),
                      label: Text(
                        'تأكيد التسليم للمركز ورفع الصور',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        _showDropCenterPhotosBottomSheet(context, order.id);
                      },
                    ),
                  ),
                ] else if (order.status.toLowerCase() == 'repaired' ||
                    order.status.toLowerCase() == 'ready' ||
                    order.status.toLowerCase() == 'delivering' ||
                    order.status.toLowerCase() == 'returning') ...[
                  // ⚠️ Warning Banner: Call client to confirm delivery location
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orangeAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تنبيه: يرجى الاتصال بالعميل للتأكد من موقع التسليم الفعلي قبل التحرك بالجهاز.',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orangeAccent,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (order.client?.phone != null &&
                      order.client!.phone.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orangeAccent,
                          side: const BorderSide(color: Colors.orangeAccent),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.phone),
                        label: Text(
                          'اتصل بالعميل لتأكيد العنوان',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () =>
                            _showCustomerDetailsDialog(context, order),
                      ),
                    ),
                  ],
                  // Button: Confirm pickup from center with photos
                  if (order.delegatePhotos != null &&
                      order.delegatePhotos!.atCenterPickup.isEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BCD4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.download_done_outlined),
                        label: Text(
                          'تأكيد استلام الجهاز من المركز ورفع الصور',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          _showPickupCenterPhotosBottomSheet(context, order.id);
                        },
                      ),
                    ),
                  ],
                  // Button: Confirm delivery to client with photos
                  if (order.delegatePhotos != null &&
                      order.delegatePhotos!.atCenterPickup.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          'تأكيد تسليم الجهاز للعميل ورفع الصور',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          _showConfirmDeliveryPhotosBottomSheet(context, order.id);
                        },
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.white38),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.cairo(fontSize: 13, color: Colors.white54),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange;
        label = 'قيد الانتظار';
        break;
      case 'accepted':
        chipColor = Colors.blue;
        label = 'تم القبول';
        break;
      case 'delegate_assigned':
      case 'assigned':
        chipColor = const Color(0xFF4CAF50);
        label = 'تم تعيين المندوب';
        break;
      case 'picking_up':
        chipColor = const Color(0xFF9C27B0);
        label = 'جاري الاستلام';
        break;
      case 'picked_up':
        chipColor = Colors.teal;
        label = 'تم الاستلام';
        break;
      case 'at_center':
        chipColor = const Color(0xFF00BCD4);
        label = 'في المركز';
        break;
      case 'inspecting':
        chipColor = const Color(0xFFFF9800);
        label = 'جاري الفحص';
        break;
      case 'awaiting_approval':
        chipColor = const Color(0xFFFFC107);
        label = 'بانتظار الموافقة';
        break;
      case 'approved':
        chipColor = const Color(0xFF4CAF50);
        label = 'تم الموافقة';
        break;
      case 'rejected':
        chipColor = Colors.redAccent;
        label = 'مرفوض';
        break;
      case 'repairing':
      case 'in_repair':
        chipColor = Colors.purple;
        label = 'جاري الإصلاح';
        break;
      case 'repaired':
        chipColor = const Color(0xFF8BC34A);
        label = 'تم الإصلاح';
        break;
      case 'ready':
        chipColor = Colors.cyan;
        label = 'جاهز للتوصيل';
        break;
      case 'delivering':
      case 'returning':
        chipColor = const Color(0xFF3F51B5);
        label = 'جاري التوصيل';
        break;
      case 'delivered':
        chipColor = const Color(0xFF4CAF50);
        label = 'تم التوصيل';
        break;
      case 'completed':
        chipColor = const Color(0xFF4CAF50);
        label = 'مكتمل';
        break;
      case 'cancelled':
        chipColor = Colors.redAccent;
        label = 'ملغي';
        break;
      default:
        chipColor = Colors.grey;
        label = 'حالة غير معروفة';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
    );
  }

  void _showProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              const CircularProgressIndicator(color: Color(0xFFFFC107)),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomerDetailsDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF141414),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFFFFC107).withValues(alpha: 0.2),
            ),
          ),
          title: Center(
            child: Text(
              'بيانات العميل للتواصل والتسليم',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogInfoRow(
                Icons.person_outline,
                'اسم العميل',
                order.client?.name ?? 'غير متوفر',
              ),
              const SizedBox(height: 12),
              _buildDialogInfoRow(
                Icons.location_on_outlined,
                'منطقة التسليم',
                '${order.pickupAddress.city}، ${order.pickupAddress.address}',
              ),
              const SizedBox(height: 12),
              _buildDialogInfoRow(
                Icons.phone_outlined,
                'رقم الموبايل',
                order.client?.phone ?? 'غير متوفر',
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.phone),
                      label: Text(
                        'اتصال بالعميل',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (order.client?.phone != null) {
                          launchUrl(Uri.parse('tel:${order.client!.phone}'));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        'تأكيد العنوان وبدء التوصيل',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              'تم تأكيد العنوان وجاري الانتقال لمرحلة التوصيل ✅',
                              style: GoogleFonts.cairo(color: Colors.white),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'إلغاء',
                      style: GoogleFonts.cairo(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildDialogInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFFC107), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: Colors.white54,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPickupPhotosBottomSheet(BuildContext context, String orderId) {
    final List<String> selectedImages = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            Future<void> pickImage() async {
              if (selectedImages.length >= 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.orange,
                    content: Text(
                      'الحد الأقصى صورتين فقط',
                      style: GoogleFonts.cairo(color: Colors.white),
                      textAlign: TextAlign.right,
                    ),
                  ),
                );
                return;
              }
              try {
                final XFile? image = await ImagePickerService.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setModalState(() {
                    selectedImages.add(image.path);
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ أثناء اختيار الصورة: $e')),
                  );
                }
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF141414),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    'رفع صور الجهاز قبل الاستلام',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Warning text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تنبيه للحماية: قبل تحرك المندوب، تأكد من رفع الصور وأن الحالة أصبحت "تم تأكيد الاستلام"',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.orange[200],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Photo slots
                  Row(
                    children: List.generate(2, (index) {
                      final hasImage = index < selectedImages.length;
                      return Expanded(
                        child: GestureDetector(
                          onTap: hasImage ? null : pickImage,
                          child: Container(
                            height: 140,
                            margin: EdgeInsets.only(
                              left: index == 0 ? 0 : 6,
                              right: index == 1 ? 0 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasImage
                                    ? const Color(
                                        0xFFFFC107,
                                      ).withValues(alpha: 0.5)
                                    : Colors.white12,
                              ),
                            ),
                            child: hasImage
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: kIsWeb
                                            ? Image.network(
                                                selectedImages[index],
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(selectedImages[index]),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setModalState(() {
                                              selectedImages.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        color: Colors.white38,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'صورة ${index + 1}',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  // Status text
                  Text(
                    selectedImages.length == 2
                        ? '✅ تم اختيار الصورتين - يمكنك الآن تأكيد الاستلام'
                        : '📷 اختر ${2 - selectedImages.length} ${selectedImages.isEmpty ? "صورتين" : "صورة إضافية"} للجهاز',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: selectedImages.length == 2
                          ? Colors.greenAccent
                          : Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedImages.length == 2
                            ? const Color(0xFFFFC107)
                            : Colors.grey[700],
                        foregroundColor: selectedImages.length == 2
                            ? Colors.black
                            : Colors.white38,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: Text(
                        'رفع الصور وتأكيد الاستلام',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: selectedImages.length == 2
                          ? () {
                              Navigator.pop(bottomSheetContext);
                              _cubit.uploadPhotosAndConfirm(
                                orderId,
                                selectedImages,
                              );
                            }
                          : null,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom + 8,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDropCenterPhotosBottomSheet(BuildContext context, String orderId) {
    final List<String> selectedImages = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            Future<void> pickImage() async {
              if (selectedImages.length >= 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.orange,
                    content: Text(
                      'الحد الأقصى صورتين فقط',
                      style: GoogleFonts.cairo(color: Colors.white),
                      textAlign: TextAlign.right,
                    ),
                  ),
                );
                return;
              }
              try {
                final XFile? image = await ImagePickerService.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setModalState(() {
                    selectedImages.add(image.path);
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ أثناء اختيار الصورة: $e')),
                  );
                }
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF141414),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    'رفع صور الجهاز عند التسليم للمركز',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Warning text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تنبيه: يرجى رفع صور الجهاز عند تسليمه لمركز الصيانة لتأكيد تسليم الطلب بنجاح.',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.blue[200],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Photo slots
                  Row(
                    children: List.generate(2, (index) {
                      final hasImage = index < selectedImages.length;
                      return Expanded(
                        child: GestureDetector(
                          onTap: hasImage ? null : pickImage,
                          child: Container(
                            height: 140,
                            margin: EdgeInsets.only(
                              left: index == 0 ? 0 : 6,
                              right: index == 1 ? 0 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasImage
                                    ? const Color(
                                        0xFFFFC107,
                                      ).withValues(alpha: 0.5)
                                    : Colors.white12,
                              ),
                            ),
                            child: hasImage
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: kIsWeb
                                            ? Image.network(
                                                selectedImages[index],
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(selectedImages[index]),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setModalState(() {
                                              selectedImages.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        color: Colors.white38,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'صورة ${index + 1}',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  // Status text
                  Text(
                    selectedImages.length == 2
                        ? '✅ تم اختيار الصورتين - يمكنك الآن تأكيد التسليم للمركز'
                        : '📷 اختر ${2 - selectedImages.length} ${selectedImages.isEmpty ? "صورتين" : "صورة إضافية"} للجهاز',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: selectedImages.length == 2
                          ? Colors.greenAccent
                          : Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedImages.length == 2
                            ? const Color(0xFFFFC107)
                            : Colors.grey[700],
                        foregroundColor: selectedImages.length == 2
                            ? Colors.black
                            : Colors.white38,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: Text(
                        'رفع الصور وتأكيد التسليم للمركز',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: selectedImages.length == 2
                          ? () {
                              Navigator.pop(bottomSheetContext);
                              _cubit.confirmDropCenter(orderId, selectedImages);
                            }
                          : null,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom + 8,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPickupCenterPhotosBottomSheet(BuildContext context, String orderId) {
    final List<String> selectedImages = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            Future<void> pickImage() async {
              if (selectedImages.length >= 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.orange,
                    content: Text(
                      'الحد الأقصى صورتين فقط',
                      style: GoogleFonts.cairo(color: Colors.white),
                      textAlign: TextAlign.right,
                    ),
                  ),
                );
                return;
              }
              try {
                final XFile? image = await ImagePickerService.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setModalState(() {
                    selectedImages.add(image.path);
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ أثناء اختيار الصورة: $e')),
                  );
                }
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF141414),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    'رفع صور الجهاز عند الاستلام من المركز',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Warning text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00BCD4).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF00BCD4),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تنبيه: يرجى رفع صور الجهاز عند استلامه من مركز الصيانة بعد الإصلاح لتأكيد الاستلام.',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: const Color(0xFF80DEEA),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Photo slots
                  Row(
                    children: List.generate(2, (index) {
                      final hasImage = index < selectedImages.length;
                      return Expanded(
                        child: GestureDetector(
                          onTap: hasImage ? null : pickImage,
                          child: Container(
                            height: 140,
                            margin: EdgeInsets.only(
                              left: index == 0 ? 0 : 6,
                              right: index == 1 ? 0 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasImage
                                    ? const Color(0xFF00BCD4).withValues(alpha: 0.5)
                                    : Colors.white12,
                              ),
                            ),
                            child: hasImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: kIsWeb
                                        ? Image.network(
                                            selectedImages[index],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          )
                                        : Image.file(
                                            File(selectedImages[index]),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        color: Colors.white24,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'صورة ${index + 1}',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  // Status text
                  Text(
                    selectedImages.length == 2
                        ? '✅ تم اختيار الصورتين - يمكنك الآن تأكيد الاستلام من المركز'
                        : '📷 اختر ${2 - selectedImages.length} ${selectedImages.isEmpty ? "صورتين" : "صورة إضافية"} للجهاز',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: selectedImages.length == 2
                          ? Colors.greenAccent
                          : Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedImages.length == 2
                            ? const Color(0xFF00BCD4)
                            : Colors.grey[700],
                        foregroundColor: selectedImages.length == 2
                            ? Colors.white
                            : Colors.white38,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: Text(
                        'رفع الصور وتأكيد استلام الجهاز من المركز',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: selectedImages.length == 2
                          ? () {
                              Navigator.pop(bottomSheetContext);
                              _cubit.confirmPickupCenter(orderId, selectedImages);
                            }
                          : null,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom + 8,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmDeliveryPhotosBottomSheet(BuildContext context, String orderId) {
    final List<String> selectedImages = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            Future<void> pickImage() async {
              if (selectedImages.length >= 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.orange,
                    content: Text(
                      'الحد الأقصى صورتين فقط',
                      style: GoogleFonts.cairo(color: Colors.white),
                      textAlign: TextAlign.right,
                    ),
                  ),
                );
                return;
              }
              try {
                final XFile? image = await ImagePickerService.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setModalState(() {
                    selectedImages.add(image.path);
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ أثناء اختيار الصورة: $e')),
                  );
                }
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF141414),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    'رفع صور التسليم للعميل',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Warning text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.green,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تنبيه: يرجى رفع صور الجهاز عند تسليمه النهائي للعميل لتأكيد اكتمال الطلب بنجاح.',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.green[200],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Photo slots
                  Row(
                    children: List.generate(2, (index) {
                      final hasImage = index < selectedImages.length;
                      return Expanded(
                        child: GestureDetector(
                          onTap: hasImage ? null : pickImage,
                          child: Container(
                            height: 140,
                            margin: EdgeInsets.only(
                              left: index == 0 ? 0 : 6,
                              right: index == 1 ? 0 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasImage
                                    ? Colors.green.withValues(alpha: 0.5)
                                    : Colors.white12,
                              ),
                            ),
                            child: hasImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: kIsWeb
                                        ? Image.network(
                                            selectedImages[index],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          )
                                        : Image.file(
                                            File(selectedImages[index]),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        color: Colors.white24,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'صورة ${index + 1}',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  // Status text
                  Text(
                    selectedImages.length == 2
                        ? '✅ تم اختيار الصورتين - يمكنك الآن تأكيد تسليم الجهاز للعميل'
                        : '📷 اختر ${2 - selectedImages.length} ${selectedImages.isEmpty ? "صورتين" : "صورة إضافية"} للجهاز',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: selectedImages.length == 2
                          ? Colors.greenAccent
                          : Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedImages.length == 2
                            ? Colors.green
                            : Colors.grey[700],
                        foregroundColor: selectedImages.length == 2
                            ? Colors.white
                            : Colors.white38,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: Text(
                        'رفع الصور وتأكيد تسليم الجهاز للعميل',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: selectedImages.length == 2
                          ? () {
                              Navigator.pop(bottomSheetContext);
                              _cubit.confirmDelivery(orderId, selectedImages);
                            }
                          : null,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom + 8,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _translateProblemType(String type) {
    switch (type.toLowerCase()) {
      case 'screen':
        return 'كسر شاشة';
      case 'battery':
        return 'مشكلة بطارية';
      case 'camera':
        return 'كاميرا';
      case 'software':
        return 'نظام التشغيل / سوفتوير';
      case 'charging':
        return 'مشكلة شحن';
      case 'water_damage':
        return 'ضرر مياه';
      case 'speaker':
        return 'مشكلة سماعة';
      case 'other':
        return 'مشكلة أخرى';
      default:
        return type.isNotEmpty ? type : 'أخرى';
    }
  }

  Future<Position?> _getDelegateLocationWithPermission(BuildContext context) async {
    // 1. Check if location service (GPS) is enabled on the device
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.location_off_rounded, color: Color(0xFFFFC107)),
                const SizedBox(width: 8),
                Text(
                  'خدمة الموقع (GPS) مغلقة',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              'يرجى تفعيل خدمة تحديد الموقع (GPS) من إعدادات الهاتف لتتمكن من عرض المسار.',
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Geolocator.openLocationSettings();
                },
                child: Text(
                  'فتح إعدادات الموقع',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
      return null;
    }

    // 2. Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orange.shade800,
              content: Text(
                'تم رفض صلاحية تحديد الموقع. يرجى الموافقة لعرض المسار.',
                style: GoogleFonts.cairo(color: Colors.white),
                textAlign: TextAlign.right,
              ),
            ),
          );
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.gpp_maybe_rounded, color: Colors.redAccent),
                const SizedBox(width: 8),
                Text(
                  'صلاحية الموقع مرفوضة دائمًا',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              'تم رفض صلاحية الموقع بشكل دائم لهذا التطبيق. يرجى تفعيلها من إعدادات التطبيق.',
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Geolocator.openAppSettings();
                },
                child: Text(
                  'إعدادات التطبيق',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
      return null;
    }

    // 3. Obtain current position
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Geocode the destination address, get current delegate GPS, then open the route map
  Future<void> _navigateToMapRoute(
    BuildContext context,
    String destinationAddress,
    String destinationTitle,
  ) async {
    // 1. First verify GPS & permissions before showing loading dialog
    final position = await _getDelegateLocationWithPermission(context);
    if (position == null) return;

    if (!context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFFFFC107)),
              const SizedBox(height: 16),
              Text(
                'جاري تحديد الموقع وتحميل المسار...',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // 2. Geocode the destination address to get lat/lng
      final dataSource = getIt<MapRemoteDataSource>();
      final results = await dataSource.geocodeAddress(destinationAddress);

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange.shade800,
            content: Text(
              'تعذر العثور على الموقع من العنوان "$destinationAddress"',
              style: GoogleFonts.cairo(color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
        );
        return;
      }

      final dest = results.first;

      // 3. Open route view screen
      Navigator.pushNamed(
        context,
        Routes.delegateRouteViewRoute,
        arguments: {
          'originLat': position.latitude,
          'originLng': position.longitude,
          'destLat': dest.latitude,
          'destLng': dest.longitude,
          'destinationTitle': destinationTitle,
          'destinationAddress': destinationAddress,
        },
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text(
              'خطأ في تحديد الموقع: ${e.toString()}',
              style: GoogleFonts.cairo(color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
        );
      }
    }
  }
}
