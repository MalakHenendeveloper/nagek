import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/di.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/delegate_orders_cubit.dart';
import '../cubit/delegate_orders_state.dart';

class DelegateTasksScreen extends StatefulWidget {
  const DelegateTasksScreen({super.key});

  @override
  State<DelegateTasksScreen> createState() => _DelegateTasksScreenState();
}

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
              _showProgressDialog(context, 'جاري تأكيد استلام الجهاز من العميل...');
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
              _showProgressDialog(context, 'جاري رفع الصور وتأكيد تسليم الجهاز للمركز...');
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
                      style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _cubit.fetchDelegateOrders(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                      ),
                      child: Text('إعادة المحاولة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            } else if (state is DelegateOrdersLoaded) {
              // Filter active tasks (not completed/delivered)
              final activeTasks = state.orders.where((o) {
                final status = o.status.toLowerCase();
                return status != 'delivered' && status != 'completed';
              }).toList();

              if (activeTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, color: Colors.greenAccent.withValues(alpha: 0.6), size: 80),
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeTasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(context, activeTasks[index]);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.assignment, color: Color(0xFFFFC107), size: 20),
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
                _buildInfoRow(Icons.phone_android, 'الجهاز', '${order.device.brand} ${order.device.model}'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.build_outlined, 'نوع المشكلة', _translateProblemType(order.device.problemType)),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_outlined, 'العنوان', '${order.pickupAddress.address}، ${order.pickupAddress.city}'),
                const SizedBox(height: 8),
                // Customer phone
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 16, color: Colors.white38),
                    const SizedBox(width: 8),
                    Text(
                      'هاتف العميل: ',
                      style: GoogleFonts.cairo(fontSize: 13, color: Colors.white54),
                    ),
                    GestureDetector(
                      onTap: order.client?.phone != null
                          ? () => launchUrl(Uri.parse('tel:${order.client!.phone}'))
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
                  _buildInfoRow(Icons.monetization_on_outlined, 'رسوم التوصيل', '${order.fees.delivery.toStringAsFixed(0)} د.ع'),
                ],
                const SizedBox(height: 16),
                if (order.status.toLowerCase() == 'delegate_assigned' || order.status.toLowerCase() == 'picking_up') ...[
                  // Security warning banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
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
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue, size: 22),
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
                ] else if (order.status.toLowerCase() == 'repaired' || order.status.toLowerCase() == 'ready' || order.status.toLowerCase() == 'delivering' || order.status.toLowerCase() == 'returning') ...[
                  // ⚠️ Warning Banner: Call client to confirm delivery location
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 22),
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
                  if (order.client?.phone != null && order.client!.phone.isNotEmpty) ...[
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
                        onPressed: () => launchUrl(Uri.parse('tel:${order.client!.phone}')),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  void _showPickupPhotosBottomSheet(BuildContext context, String orderId) {
    final List<String> selectedImages = [];
    final ImagePicker picker = ImagePicker();

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
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
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
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
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
                            margin: EdgeInsets.only(left: index == 0 ? 0 : 6, right: index == 1 ? 0 : 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasImage
                                    ? const Color(0xFFFFC107).withValues(alpha: 0.5)
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
                                            child: const Icon(Icons.close, color: Colors.white, size: 16),
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
                      color: selectedImages.length == 2 ? Colors.greenAccent : Colors.white54,
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
                              _cubit.uploadPhotosAndConfirm(orderId, selectedImages);
                            }
                          : null,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 8),
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
    final ImagePicker picker = ImagePicker();

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
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
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
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue, size: 22),
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
                            margin: EdgeInsets.only(left: index == 0 ? 0 : 6, right: index == 1 ? 0 : 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasImage
                                    ? const Color(0xFFFFC107).withValues(alpha: 0.5)
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
                                            child: const Icon(Icons.close, color: Colors.white, size: 16),
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
                      color: selectedImages.length == 2 ? Colors.greenAccent : Colors.white54,
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
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 8),
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
}
