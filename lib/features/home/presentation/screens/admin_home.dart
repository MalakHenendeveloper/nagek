import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/routes_manager/routes.dart';

// Import Admin Cubits & States
import '../../../admin/presentation/cubit/admin_dashboard_cubit.dart';
import '../../../admin/presentation/cubit/admin_users_cubit.dart';
import '../../../admin/presentation/cubit/admin_delegates_cubit.dart';
import '../../../admin/presentation/cubit/admin_centers_cubit.dart';
import '../../../admin/presentation/cubit/admin_create_center_cubit.dart';
import '../../../admin/presentation/cubit/admin_orders_cubit.dart';
import '../../../admin/presentation/cubit/admin_delegate_applications_cubit.dart';
import '../../../admin/presentation/cubit/admin_payments_cubit.dart';
import '../../../admin/presentation/cubit/admin_payment_settings_cubit.dart';
import '../../../admin/presentation/cubit/admin_financial_settings_cubit.dart';

// Import Admin Views
import '../../../admin/presentation/screens/views/admin_dashboard_view.dart';
import '../../../admin/presentation/screens/views/admin_users_view.dart';
import '../../../admin/presentation/screens/views/admin_delegates_view.dart';
import '../../../admin/presentation/screens/views/admin_centers_view.dart';
import '../../../admin/presentation/screens/views/admin_add_center_view.dart';
import '../../../admin/presentation/screens/views/admin_orders_view.dart';
import '../../../admin/presentation/screens/views/admin_delegate_applications_view.dart';
import '../../../admin/presentation/screens/views/admin_payments_view.dart';
import '../../../admin/presentation/screens/views/admin_payment_settings_view.dart';
import '../../../admin/presentation/screens/views/admin_financial_settings_view.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedMenuIndex = 0;
  String _adminName = 'المدير';

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  Future<void> _loadAdminInfo() async {
    final name = await getIt<SecureStorageService>().getUserName();
    if (name != null && mounted) {
      setState(() {
        _adminName = name;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await getIt<SecureStorageService>().clearAuth();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.loginRoute, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AdminDashboardCubit>(
          create: (context) => getIt<AdminDashboardCubit>()..fetchDashboardStats(),
        ),
        BlocProvider<AdminUsersCubit>(
          create: (context) => getIt<AdminUsersCubit>(),
        ),
        BlocProvider<AdminDelegatesCubit>(
          create: (context) => getIt<AdminDelegatesCubit>(),
        ),
        BlocProvider<AdminCentersCubit>(
          create: (context) => getIt<AdminCentersCubit>(),
        ),
        BlocProvider<AdminCreateCenterCubit>(
          create: (context) => getIt<AdminCreateCenterCubit>(),
        ),
        BlocProvider<AdminOrdersCubit>(
          create: (context) => getIt<AdminOrdersCubit>(),
        ),
        BlocProvider<AdminDelegateApplicationsCubit>(
          create: (context) => getIt<AdminDelegateApplicationsCubit>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F0F0F),
            appBar: AppBar(
              title: Text(
                _getPageTitle(),
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              backgroundColor: const Color(0xFF141414),
              elevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFFFFC107)),
               actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFFFFC107)),
                  tooltip: 'تسجيل الخروج',
                  onPressed: () => _logout(context),
                ),
              ],
            ),
            drawer: Drawer(
              backgroundColor: const Color(0xFF141414),
              child: Column(
                children: [
                  // Drawer Header
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      border: Border(
                        bottom: BorderSide(color: Colors.white10, width: 1),
                      ),
                    ),
                    accountName: Text(
                      _adminName,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    accountEmail: Text(
                      'مدير النظام',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFFFC107),
                        fontSize: 12,
                      ),
                    ),
                    currentAccountPicture: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 40,
                        color: Color(0xFFFFC107),
                      ),
                    ),
                  ),

                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildDrawerItem(
                          index: 0,
                          title: 'الرئيسية (الإحصائيات)',
                          icon: Icons.dashboard_rounded,
                        ),
                        
                        _buildDrawerCategory('إدارة المستخدمين'),
                        _buildDrawerSubItem(
                          index: 1,
                          title: 'قائمة المستخدمين',
                          icon: Icons.people_alt_rounded,
                        ),

                        _buildDrawerCategory('إدارة المندوبين'),
                        _buildDrawerSubItem(
                          index: 2,
                          title: 'قائمة المندوبين',
                          icon: Icons.delivery_dining_rounded,
                        ),
                        _buildDrawerSubItem(
                          index: 7,
                          title: 'طلبات تسجيل المندوبين',
                          icon: Icons.assignment_ind_rounded,
                        ),

                        _buildDrawerCategory('إدارة مراكز الصيانة'),
                        _buildDrawerSubItem(
                          index: 3,
                          title: 'قائمة مراكز الصيانة',
                          icon: Icons.build_circle_rounded,
                        ),
                        _buildDrawerSubItem(
                          index: 5,
                          title: 'إضافة مركز صيانة جديد',
                          icon: Icons.add_business_rounded,
                        ),

                        _buildDrawerCategory('إدارة الطلبات'),
                        _buildDrawerSubItem(
                          index: 6,
                          title: 'جميع الطلبات',
                          icon: Icons.assignment_rounded,
                        ),

                        _buildDrawerCategory('الإدارة المالية'),
                        _buildDrawerSubItem(
                          index: 8,
                          title: 'التحويلات والمدفوعات',
                          icon: Icons.account_balance_wallet_rounded,
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(right: 28, left: 16),
                          leading: const Icon(Icons.receipt_long_rounded, color: Color(0xFFFFC107), size: 20),
                          title: Text(
                            'قائمة تسويات النظام',
                            style: GoogleFonts.cairo(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, Routes.adminSettlementsRoute);
                          },
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(right: 28, left: 16),
                          leading: const Icon(Icons.pie_chart_rounded, color: Color(0xFFFFC107), size: 20),
                          title: Text(
                            'ملخص التسويات المجمع',
                            style: GoogleFonts.cairo(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, Routes.adminSettlementsSummaryRoute);
                          },
                        ),
                        _buildDrawerSubItem(
                          index: 9,
                          title: 'إعدادات المحافظ الإلكترونية',
                          icon: Icons.tune_rounded,
                        ),
                        _buildDrawerSubItem(
                          index: 10,
                          title: 'الإعدادات المالية والعمولات',
                          icon: Icons.monetization_on_outlined,
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white10, height: 1),

                  // App version or branding in drawer footer
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'نجيك للإدارة v1.0.0',
                      style: GoogleFonts.cairo(
                        color: Colors.white24,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: _getBody(context, _selectedMenuIndex),
          );
        },
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedMenuIndex) {
      case 0:
        return 'لوحة الإحصائيات';
      case 1:
        return 'إدارة المستخدمين';
      case 2:
        return 'إدارة المندوبين';
      case 3:
        return 'مراكز الصيانة';
      case 5:
        return 'إضافة مركز صيانة جديد';
      case 6:
        return 'إدارة الطلبات';
      case 7:
        return 'طلبات تسجيل المندوبين';
      case 8:
        return 'التحويلات والمدفوعات';
      case 9:
        return 'إعدادات المحافظ الإلكترونية';
      case 10:
        return 'الإعدادات المالية والعمولات';
      default:
        return 'مدير النظام';
    }
  }

  Widget _getBody(BuildContext context, int index) {
    switch (index) {
      case 0:
        return const AdminDashboardView();
      case 1:
        return const AdminUsersView();
      case 2:
      
        return const AdminDelegatesView();
      case 3:
        return const AdminCentersView();
      case 5:
        return AdminAddCenterView(
          onSuccess: () {
            setState(() {
              _selectedMenuIndex = 3; // Redirect to listing page
            });
            // Refresh list
            context.read<AdminCentersCubit>().fetchCenters(isRefresh: true);
          },
        );
      case 6:
        return const AdminOrdersView();
      case 7:
        return const AdminDelegateApplicationsView();
      case 8:
        return BlocProvider<AdminPaymentsCubit>(
          create: (context) => getIt<AdminPaymentsCubit>(),
          child: const AdminPaymentsView(),
        );
      case 9:
        return BlocProvider<AdminPaymentSettingsCubit>(
          create: (context) => getIt<AdminPaymentSettingsCubit>(),
          child: const AdminPaymentSettingsView(),
        );
      case 10:
        return BlocProvider<AdminFinancialSettingsCubit>(
          create: (context) => getIt<AdminFinancialSettingsCubit>(),
          child: const AdminFinancialSettingsView(),
        );
      default:
        return const AdminDashboardView();
    }
  }

  Widget _buildDrawerItem({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedMenuIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFC107).withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFFFFC107) : Colors.white60,
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFFFFC107) : Colors.white70,
            fontSize: 14,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedMenuIndex = index;
          });
          Navigator.pop(context); // Close Drawer
        },
      ),
    );
  }

  Widget _buildDrawerCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, top: 16, bottom: 6, left: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white24,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerSubItem({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedMenuIndex == index;
    return Container(
      margin: const EdgeInsets.only(right: 28, left: 16, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFC107).withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFFFFC107) : Colors.white54,
          size: 20,
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFFFFC107) : Colors.white60,
            fontSize: 13,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedMenuIndex = index;
          });
          Navigator.pop(context); // Close Drawer
        },
      ),
    );
  }
}
