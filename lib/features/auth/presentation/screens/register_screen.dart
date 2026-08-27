import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routes_manager/routes.dart';
import '../cubit/register_cubit.dart';
import '../cubit/register_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterCubit>(
      create: (_) => getIt<RegisterCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFAF5), // Light warm background
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: BlocConsumer<RegisterCubit, RegisterState>(
                  listener: (context, state) {
                    if (state is RegisterSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم إنشاء الحساب بنجاح',
                            style: GoogleFonts.cairo(color: Colors.white),
                            textAlign: TextAlign.right,
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Routes.clientHomeRoute,
                        (route) => false,
                      );
                    } else if (state is RegisterError) {
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
                    final isLoading = state is RegisterLoading;

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title & Subtitle
                          Text(
                            'إنشاء حساب جديد',
                            style: GoogleFonts.cairo(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'انضم إلينا واحصل على أفضل خدمات الصيانة لهاتفك',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 40),

                          // Name Input Field
                          _buildLabel('الاسم الكامل'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            hintText: 'أدخل اسمك الكامل',
                            prefixIcon: Icons.person_outline,
                            enabled: !isLoading,
                            validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال الاسم' : null,
                          ),
                          const SizedBox(height: 16),

                          // Phone Input Field
                          _buildLabel('رقم الهاتف'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _phoneController,
                            hintText: '07XXXXXXXX',
                            prefixIcon: Icons.phone_android_outlined,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.right,
                            enabled: !isLoading,
                            validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
                          ),
                          const SizedBox(height: 16),

                          // Email Input Field
                          _buildLabel('البريد الإلكتروني'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'example@domain.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.right,
                            enabled: !isLoading,
                            validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال البريد الإلكتروني' : null,
                          ),
                          const SizedBox(height: 16),

                          // Password Input Field
                          _buildLabel('كلمة المرور'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.ltr,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                              hintText: '********',
                              hintStyle: const TextStyle(color: Colors.black38, letterSpacing: 2.0),
                              filled: true,
                              fillColor: const Color(0xFFF3F4F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF555555)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color(0xFF555555),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال كلمة المرور' : null,
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Input Field
                          _buildLabel('تأكيد كلمة المرور'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.ltr,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                              hintText: '********',
                              hintStyle: const TextStyle(color: Colors.black38, letterSpacing: 2.0),
                              filled: true,
                              fillColor: const Color(0xFFF3F4F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              prefixIcon: const Icon(Icons.lock_reset_outlined, color: Color(0xFF555555)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color(0xFF555555),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى تأكيد كلمة المرور';
                              }
                              if (value != _passwordController.text) {
                                return 'كلمة المرور غير متطابقة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),

                          // Register Button
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      BlocProvider.of<RegisterCubit>(context).register(
                                        name: _nameController.text.trim(),
                                        phone: _phoneController.text.trim(),
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text.trim(),
                                      );
                                    }
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
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : Text(
                                    'إنشاء حساب',
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 40),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'لديك حساب بالفعل؟ ',
                                style: GoogleFonts.cairo(color: Colors.black54, fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        Navigator.pop(context);
                                      },
                                child: Text(
                                  'تسجيل الدخول',
                                  style: GoogleFonts.cairo(
                                    color: const Color(0xFF8B7500),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF333333),
      ),
      textAlign: TextAlign.start,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: textAlign,
      textDirection: textDirection,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.cairo(color: Colors.black38, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF555555)),
      ),
      validator: validator,
    );
  }
}
