import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routes_manager/routes.dart';
import '../../../centers/domain/entities/center_entity.dart';
import '../../../centers/presentation/cubit/centers_cubit.dart';
import '../../../centers/presentation/cubit/centers_state.dart';
import '../../../centers/presentation/widgets/center_skeletons.dart';
import '../../../orders/presentation/screens/my_orders_screen.dart';
import '../../../centers/presentation/screens/all_centers_screen.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import 'package:shimmer/shimmer.dart';                     
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../orders/presentation/cubit/available_coupons_cubit.dart';
import '../../../orders/presentation/cubit/available_coupons_state.dart';
import '../../../orders/presentation/widgets/available_coupons_bottom_sheet.dart';




class ClientHome extends StatefulWidget {
  const ClientHome({super.key});

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  late CentersCubit _centersCubit;
  late OrdersCubit _ordersCubit;
  late AvailableCouponsCubit _availableCouponsCubit;
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _centersCubit = getIt<CentersCubit>()..fetchCenters(limit: 4);
    _ordersCubit = getIt<OrdersCubit>()..fetchOrders(limit: 10);
    _availableCouponsCubit = getIt<AvailableCouponsCubit>()..fetchAvailableCoupons();
  }

  @override
  void dispose() {
    _centersCubit.close();
    _ordersCubit.close();
    _availableCouponsCubit.close();
    super.dispose();
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '';
    }
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 3:
        return _buildHomeBody();
      case 2:
        return const MyOrdersScreen();
      case 1:
        return const AllCentersScreen();
      case 0:
        return const ProfileScreen();
      default:
        return _buildHomeBody();
    }
  }

  Widget _buildHomeBody() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Bar Alternative
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'نجيك',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFC107),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.notifications_none, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Offers Card
                _buildOffersCard(),

                // Nearest Centers Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'أقرب مراكز الصيانة',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.allCentersRoute);
                      },
                      child: Text(
                        'رؤية الكل',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: const Color(0xFF8B7500),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Centers GridView
                BlocBuilder<CentersCubit, CentersState>(
                  builder: (context, state) {
                    if (state is CentersInitial || state is CentersLoading) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return const CenterCardSkeleton();
                        },
                      );
                    } else if (state is CentersError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: GoogleFonts.cairo(color: Colors.red),
                        ),
                      );
                    } else if (state is CentersLoaded) {
                      final centers = state.centers;
                      if (centers.isEmpty) {
                        return Center(
                          child: Text(
                            'لا توجد مراكز حالياً',
                            style: GoogleFonts.cairo(),
                          ),
                        );
                      }

                      // Take only the first 4 if API returned more
                      final displayCenters = centers.take(4).toList();

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75, // Matching AllCentersScreen
                        ),
                        itemCount: displayCenters.length,
                        itemBuilder: (context, index) {
                          return _buildCenterCard(displayCenters[index]);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 30),

                // Recent Orders
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الطلبات الأخيرة',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                      },
                      child: Text(
                        'رؤية الكل',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: const Color(0xFF8B7500),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                 BlocBuilder<OrdersCubit, OrdersState>(
                  builder: (context, state) {
                    if (state is OrdersInitial || state is OrdersLoading) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 2,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (state is OrdersError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: GoogleFonts.cairo(color: Colors.red),
                        ),
                      );
                    } else if (state is OrdersLoaded) {
                      final previousStatuses = [
                        'delivered',
                        'completed',
                        'done',
                        'cancelled',
                        'rejected',
                      ];

                      final completedOrders = state.orders
                          .where((order) =>
                              previousStatuses.contains(order.status.toLowerCase()))
                          .toList();

                      if (completedOrders.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'لا توجد طلبات سابقة أو تم تسليمها حالياً',
                              style: GoogleFonts.cairo(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: completedOrders.length > 5 ? 5 : completedOrders.length,
                        itemBuilder: (context, index) {
                          final order = completedOrders[index];
                          final badge = _getStatusBadgeData(order.status);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.orderTrackingRoute,
                                  arguments: order.id,
                                );
                              },
                              child: _buildRecentOrderCard(
                                title: '${order.device.brand} ${order.device.model}',
                                orderId: '#${order.orderNumber.split('-').last}',
                                status: badge.text,
                                time: _formatDate(order.createdAt),
                                statusColor: badge.backgroundColor,
                                statusTextColor: badge.textColor,
                                icon: order.device.type.toLowerCase() == 'phone'
                                    ? Icons.phone_iphone
                                    : Icons.build,
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _centersCubit),
        BlocProvider.value(value: _ordersCubit),
        BlocProvider.value(value: _availableCouponsCubit),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFAF5),
        body: _getBody(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFF3F4F6),
          selectedItemColor: Colors.black87,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'الملف الشخصي',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined),
              label: 'المراكز',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.build_outlined),
              label: 'طلباتي',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedIndex == 3 ? const Color(0xFFFFC107) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.home,
                  color: _selectedIndex == 3 ? Colors.black87 : Colors.grey,
                ),
              ),
              label: 'الرئيسية',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterCard(CenterEntity center) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.centerDetailsRoute,
          arguments: center.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                image: center.logo.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(center.logo),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: center.logo.isEmpty
                  ? const Center(
                      child: Icon(Icons.handyman_outlined, color: Colors.white54, size: 40),
                    )
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center.name,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined, color: Color(0xFF8B7500), size: 11),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'ضمان معتمد على الصيانة',
                          style: GoogleFonts.cairo(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8B7500),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.grey, size: 12),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '${center.city} • ${center.address}',
                        style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildRecentOrderCard({
    required String title,
    required String orderId,
    required String status,
    required String time,
    required Color statusColor,
    Color statusTextColor = Colors.black87,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF8B7500)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'رقم الطلب: $orderId',
                  style: GoogleFonts.cairo(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: GoogleFonts.cairo(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOffersCard() {
    return BlocBuilder<AvailableCouponsCubit, AvailableCouponsState>(
      builder: (context, state) {
        if (state is AvailableCouponsLoading) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          );
        }

        if (state is AvailableCouponsLoaded && state.coupons.isNotEmpty) {
          final couponsCount = state.coupons.length;
          final highestDiscount = state.coupons
              .map((c) => c.discountValue)
              .reduce((a, b) => a > b ? a : b);

          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: InkWell(
              onTap: () {
                AvailableCouponsBottomSheet.show(context, _availableCouponsCubit);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF231F14),
                      Color(0xFF141414),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.local_offer_rounded,
                        color: Color(0xFFFFC107),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'عروض وكوبونات حصرية',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC107),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$couponsCount متاح',
                                  style: GoogleFonts.cairo(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'وفّر حتى $highestDiscount د.ع على طلباتك القادمة!',
                            style: GoogleFonts.cairo(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Button
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'عرض',
                            style: GoogleFonts.cairo(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.black,
                            size: 11,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Empty coupons encouraging banner
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF231F14),
                  Color(0xFF141414),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: Color(0xFFFFC107),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'ترقّب أقوى العروض والخصومات!',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC107).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFFC107).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              'قريباً',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFFFFC107),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'تابعنا باستمرار للاستفادة من كوبونات الخصم الحصرية والعروض المميزة فور توفرها 🎁✨',
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _HomeStatusBadgeData _getStatusBadgeData(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const _HomeStatusBadgeData(
          text: 'تم التوصيل',
          backgroundColor: Color(0xFFE8F5E9),
          textColor: Color(0xFF2E7D32),
        );
      case 'completed':
      case 'done':
        return const _HomeStatusBadgeData(
          text: 'مكتمل',
          backgroundColor: Color(0xFFE8F5E9),
          textColor: Color(0xFF2E7D32),
        );
      case 'cancelled':
        return const _HomeStatusBadgeData(
          text: 'ملغي',
          backgroundColor: Color(0xFFFFEBEE),
          textColor: Color(0xFFC62828),
        );
      case 'rejected':
        return const _HomeStatusBadgeData(
          text: 'مرفوض',
          backgroundColor: Color(0xFFFFEBEE),
          textColor: Color(0xFFC62828),
        );
      default:
        return const _HomeStatusBadgeData(
          text: 'تم التسليم',
          backgroundColor: Color(0xFFE8F5E9),
          textColor: Color(0xFF2E7D32),
        );
    }
  }
}

class _HomeStatusBadgeData {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _HomeStatusBadgeData({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });
}

