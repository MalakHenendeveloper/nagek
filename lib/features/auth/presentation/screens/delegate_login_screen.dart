import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routes_manager/routes.dart';
import '../cubit/delegate_login_cubit.dart';
import '../cubit/delegate_login_state.dart';

class DelegateLoginScreen extends StatefulWidget {
  const DelegateLoginScreen({super.key});

  @override
  State<DelegateLoginScreen> createState() => _DelegateLoginScreenState();
}

class _DelegateLoginScreenState extends State<DelegateLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showPendingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              Text(
                'طلبك قيد المراجعة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'طلبك قيد المراجعة حالياً وبانتظار موافقة الإدارة.',
            style: GoogleFonts.cairo(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'موافق',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFC107),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectedDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.cancel_outlined, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              Text(
                'تم رفض الطلب',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تم رفض طلب انضمامك كمندوب للسبب التالي:',
                style: GoogleFonts.cairo(fontSize: 15),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                ),
                child: Text(
                  reason.isNotEmpty ? reason : 'لم يتم تحديد سبب الرفض.',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.red[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'إغلاق',
                style: GoogleFonts.cairo(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogCtx); // Close dialog
                Navigator.pushReplacementNamed(
                  context,
                  Routes.registerDelegateRoute,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'تقديم طلب جديد',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DelegateLoginCubit>(
      create: (_) => getIt<DelegateLoginCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFAF5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCFAF5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: BlocConsumer<DelegateLoginCubit, DelegateLoginState>(
                  listener: (context, state) {
                    if (state is DelegateLoginSuccessState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تسجيل الدخول بنجاح',
                            style: GoogleFonts.cairo(color: Colors.white),
                            textAlign: TextAlign.right,
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Routes.delegateHomeRoute,
                        (route) => false,
                      );
                    } else if (state is DelegateLoginPendingState) {
                      _showPendingDialog(context);
                    } else if (state is DelegateLoginRejectedState) {
                      _showRejectedDialog(context, state.rejectReason);
                    } else if (state is DelegateLoginError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: GoogleFonts.cairo(color: Colors.white),
                            textAlign: TextAlign.right,
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is DelegateLoginLoading;

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Logo / Icon
                          Center(
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D0D0D),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.local_shipping,
                                size: 50,
                                color: Color(0xFFFFC107),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'تسجيل دخول المندوب',
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'أهلاً بك يا كابتن، يرجى تسجيل الدخول لمتابعة عملك',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          // Phone Number
                          _buildLabel('رقم الهاتف'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _phoneController,
                            hintText: '05XXXXXXXX',
                            prefixIcon: Icons.phone_android_outlined,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.right,
                            enabled: !isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال رقم الهاتف';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password
                          _buildLabel('كلمة المرور'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            textDirection: TextDirection.ltr,
                            enabled: !isLoading,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF555555),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 35),

                          // Submit Button
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<DelegateLoginCubit>().login(
                                            phone: _phoneController.text.trim(),
                                            password: _passwordController.text.trim(),
                                          );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'تسجيل الدخول',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),

                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ليس لديك حساب؟ ',
                                style: GoogleFonts.cairo(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          Routes.registerDelegateRoute,
                                        );
                                      },
                                child: Text(
                                  'سجل كمندوب الآن',
                                  style: GoogleFonts.cairo(
                                    color: const Color(0xFFC59F00),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF333333),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.right,
    bool enabled = true,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textDirection: textDirection,
      textAlign: textAlign,
      enabled: enabled,
      style: GoogleFonts.cairo(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.cairo(color: Colors.black38, fontSize: 13),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF555555), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
}
