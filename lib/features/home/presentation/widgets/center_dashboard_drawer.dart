import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routes_manager/routes.dart';
import '../../../../core/storage/secure_storage_service.dart';

class CenterDashboardDrawer extends StatelessWidget {
  const CenterDashboardDrawer({super.key});

  Future<void> _logout(BuildContext context) async {
    await getIt<SecureStorageService>().clearAuth();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.loginRoute,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.82,
      child: Drawer(
        backgroundColor: const Color(0xFF0F0F0F),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Drawer Header
              _buildHeader(context),

              // Drawer Body Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  children: [
                    // ----------------------------------------------------
                    // CATEGORY 1: الرئيسية واللوحة
                    // ----------------------------------------------------
                    _buildCategoryHeader('الرئيسية واللوحة'),
                    _buildNavItem(
                      context: context,
                      title: 'لوحة تحكم مركز الصيانة',
                      subtitle: 'عرض الإحصائيات والملخص العام',
                      icon: Icons.dashboard_outlined,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.centerHomeRoute);
                      },
                    ),
                    _buildNavItem(
                      context: context,
                      title: 'طلبات وأوردرات المركز',
                      subtitle: 'متابعة جميع طلبات الصيانة',
                      icon: Icons.assignment_outlined,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.centerHomeRoute);
                      },
                    ),

                    const SizedBox(height: 12),

                    // ----------------------------------------------------
                    // CATEGORY 2: إدارة الخدمات
                    // ----------------------------------------------------
                    _buildCategoryHeader('إدارة الخدمات'),
                    _buildNavItem(
                      context: context,
                      title: 'عرض قائمة خدمات المركز',
                      subtitle: 'جميع خدمات الصيانة المتاحة',
                      icon: Icons.build_outlined,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.centerServicesRoute);
                      },
                    ),
                    _buildNavItem(
                      context: context,
                      title: 'إضافة خدمة صيانة جديدة',
                      subtitle: 'تسجيل خدمة جديدة للمركز',
                      icon: Icons.add_circle_outline,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.addCenterServiceRoute);
                      },
                    ),

                    const SizedBox(height: 12),

                    // ----------------------------------------------------
                    // CATEGORY 3: الأمور المالية
                    // ----------------------------------------------------
                    _buildCategoryHeader('الإدارة المالية والتسويات'),
                    _buildNavItem(
                      context: context,
                      title: 'تسويات وأرباح مركز الصيانة',
                      subtitle: 'عرض التسويات المالية والأرباح',
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.centerSettlementsRoute);
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Drawer Footer (Logout)
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FutureBuilder<String?>(
        future: getIt<SecureStorageService>().getUserName(),
        builder: (context, snapshot) {
          final name = snapshot.data ?? 'مركز الصيانة';
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFC107), width: 2),
                ),
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF222222),
                  child: Icon(
                    Icons.build_circle_outlined,
                    color: Color(0xFFFFC107),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'لوحة مركز الصيانة والإيرادات',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFFFC107),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 12, bottom: 6, left: 8),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFFC107).withValues(alpha: 0.8),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFFFC107), size: 18),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.cairo(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
        trailing: const Icon(Icons.arrow_back_ios_new, color: Colors.white24, size: 12),
        onTap: () {
          Navigator.pop(context); // Close Drawer
          onTap();
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
            title: Text(
              'تسجيل الخروج',
              style: GoogleFonts.cairo(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _logout(context),
          ),
          Text(
            'نظام نجك للصيانة والإيرادات v1.0.0',
            style: GoogleFonts.cairo(
              color: Colors.white24,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
