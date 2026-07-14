import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routes_manager/routes.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (_) => getIt<LoginCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: BlocConsumer<LoginCubit, LoginState>(
                  listener: (context, state) {
                    if (state is LoginSuccess) {
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

                      final role = state.user.role.toLowerCase();
                      String routeName = Routes.clientHomeRoute;

                      switch (role) {
                        case 'admin':
                          routeName = Routes.adminHomeRoute;
                          break;
                        case 'delegate':
                          routeName = Routes.delegateHomeRoute;
                          break;
                        case 'center':
                          routeName = Routes.centerHomeRoute;
                          break;
                        case 'client':
                        default:
                          routeName = Routes.clientHomeRoute;
                          break;
                      }

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        routeName,
                        (route) => false,
                      );
                    } else if (state is LoginError) {
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
                    final isLoading = state is LoginLoading;

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          // 1. Logo
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D0D0D),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  'assets/images/logoAppIcon.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 2. Title & Subtitle
                          Text(
                            'تسجيل الدخول',
                            style: GoogleFonts.cairo(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'أهلاً بك مرة أخرى، دعنا نصلح هاتفك',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          // 3. Phone Input Field
                          Text(
                            'رقم الهاتف',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textAlign: TextAlign.left,
                            textDirection: TextDirection.ltr,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                              hintText: '05XXXXXXXX',
                              hintStyle: GoogleFonts.cairo(
                                color: Colors.black38,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              suffixIcon: const Icon(
                                Icons.phone_android_outlined,
                                color: Color(0xFF555555),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال رقم الهاتف';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // 4. Password Input Field
                          Text(
                            'كلمة المرور',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textAlign: TextAlign.left,
                            textDirection: TextDirection.ltr,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: const TextStyle(
                                color: Colors.black38,
                                letterSpacing: 2.0,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              suffixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF555555),
                              ),
                              prefixIcon: IconButton(
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
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // 5. Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'خدمة استعادة كلمة المرور غير متوفرة حالياً',
                                            style: GoogleFonts.cairo(),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      );
                                    },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'نسيت كلمة المرور؟',
                                style: GoogleFonts.cairo(
                                  color: const Color(0xFFC59F00),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // 6. Login Button
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      BlocProvider.of<LoginCubit>(
                                        context,
                                      ).login(
                                        phone: _phoneController.text.trim(),
                                        password: _passwordController.text
                                            .trim(),
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
                                    'تسجيل دخول',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),

                          // 7. OR Divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Colors.black12,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Text(
                                  'أو',
                                  style: GoogleFonts.cairo(
                                    color: Colors.black45,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Colors.black12,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 8. Sign Up Button
                          OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.registerRoute,
                                    );
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              side: const BorderSide(
                                color: Colors.black12,
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'إنشاء حساب جديد',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 9. Login as Delegate Button
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.delegateLoginRoute,
                                    );
                                  },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              'تسجيل الدخول كمندوب توصيل',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFFC59F00),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // 10. Register as Delegate Button
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.registerDelegateRoute,
                                    );
                                  },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              'التسجيل كمندوب توصيل جديد',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFFC59F00),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
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
}
