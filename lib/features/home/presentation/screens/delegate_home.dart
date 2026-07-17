import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/routes_manager/routes.dart';
import '../../../orders/presentation/cubit/delegate_orders_cubit.dart';
import '../../../orders/presentation/cubit/delegate_orders_state.dart';

class DelegateHome extends StatelessWidget {
  const DelegateHome({super.key});

  Future<void> _logout(BuildContext context) async {
    await getIt<SecureStorageService>().clearAuth();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.loginRoute, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DelegateOrdersCubit>()..fetchDelegateOrders(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text(
            'شاشة المندوب',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFFFFC107)),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: FutureBuilder<String?>(
            future: getIt<SecureStorageService>().getUserName(),
            builder: (context, nameSnapshot) {
              final name = nameSnapshot.data ?? 'المندوب';
              return BlocBuilder<DelegateOrdersCubit, DelegateOrdersState>(
                builder: (context, state) {
                  int completedCount = 0;
                  double totalEarnings = 0.0;
                  bool isLoading = state is DelegateOrdersLoading;

                  if (state is DelegateOrdersLoaded) {
                    completedCount = state.completedOrdersCount;
                    totalEarnings = state.totalEarnings;
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<DelegateOrdersCubit>().fetchDelegateOrders(),
                    color: const Color(0xFFFFC107),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Section
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.local_shipping,
                                  size: 40,
                                  color: Color(0xFFFFC107),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'مرحباً بك يا كابتن $name',
                                      style: GoogleFonts.cairo(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'لوحة التحكم ومتابعة الطلبات المخصصة لك',
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Dashboard Stats Title
                          Text(
                            'إحصائيات الأداء والأرباح',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Stats Cards Grid
                          Row(
                            children: [
                              // Completed Orders Card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF141414),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.greenAccent.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.greenAccent.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.task_alt,
                                          color: Colors.greenAccent,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'الطلبات المنجزة',
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          color: Colors.white54,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.greenAccent,
                                              ),
                                            )
                                          : Text(
                                              '$completedCount أوردر',
                                              style: GoogleFonts.cairo(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Total Earnings Card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF141414),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.account_balance_wallet_outlined,
                                          color: Color(0xFFFFC107),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'إجمالي الأرباح',
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          color: Colors.white54,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFFFFC107),
                                              ),
                                            )
                                          : Text(
                                              '${totalEarnings.toStringAsFixed(0)} د.ع',
                                              style: GoogleFonts.cairo(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFFFFC107),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (state is DelegateOrdersError) ...[
                            const SizedBox(height: 12),
                            Text(
                              '⚠️ حدث خطأ أثناء تحديث الإحصائيات: ${state.message}',
                              style: GoogleFonts.cairo(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 40),

                          // Navigation Actions Title
                          Text(
                            'المهام والتوصيل',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Navigation Buttons
                          // Button 1: My Active Tasks
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFC107),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.assignment),
                              label: Text(
                                'مهامي النشطة (طلباتي المقبولة)',
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () async {
                                await Navigator.pushNamed(context, Routes.delegateTasksRoute);
                                if (context.mounted) {
                                  context.read<DelegateOrdersCubit>().fetchDelegateOrders();
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Button 2: Available Pickup Orders
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFFC107),
                                side: const BorderSide(color: Color(0xFFFFC107), width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.search),
                              label: Text(
                                'عرض الطلبات النشطة المتاحة للجميع',
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () async {
                                await Navigator.pushNamed(context, Routes.delegateAvailableOrdersRoute);
                                if (context.mounted) {
                                  context.read<DelegateOrdersCubit>().fetchDelegateOrders();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
