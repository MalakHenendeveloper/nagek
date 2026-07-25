import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routes_manager/routes.dart';
import '../../../../core/services/image_picker_service.dart';
import '../cubit/register_delegate_cubit.dart';
import '../cubit/register_delegate_state.dart';

class RegisterDelegateScreen extends StatefulWidget {
  const RegisterDelegateScreen({super.key});

  @override
  State<RegisterDelegateScreen> createState() => _RegisterDelegateScreenState();
}

class _RegisterDelegateScreenState extends State<RegisterDelegateScreen> {
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

  Future<void> _pickImage(BuildContext context, String docType) async {
    final cubit = context.read<RegisterDelegateCubit>();
    try {
      final XFile? pickedFile = await ImagePickerService.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final path = pickedFile.path;
        switch (docType) {
          case 'nationalIdFront':
            cubit.selectNationalIdFront(path);
            break;
          case 'nationalIdBack':
            cubit.selectNationalIdBack(path);
            break;
          case 'drivingLicense':
            cubit.selectDrivingLicense(path);
            break;
          case 'motorcycleLicense':
            cubit.selectMotorcycleLicense(path);
            break;
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل اختيار الصورة: $e',
            style: GoogleFonts.cairo(),
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterDelegateCubit>(
      create: (_) => getIt<RegisterDelegateCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFAF5), // Light warm background
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCFAF5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'تسجيل كمندوب توصيل',
            style: GoogleFonts.cairo(
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocConsumer<RegisterDelegateCubit, RegisterDelegateState>(
            listener: (context, state) {
              if (state is RegisterDelegateSuccess) {
                // Show a premium success dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogCtx) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تم تقديم الطلب',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        state
                            .message, // "تم تقديم طلبك بنجاح وبانتظار موافقة الإدارة"
                        style: GoogleFonts.cairo(fontSize: 15),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogCtx); // Pop dialog
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              Routes.loginRoute,
                              (route) => false,
                            );
                          },
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
              } else if (state is RegisterDelegateError) {
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
              String? nationalIdFrontPath;
              String? nationalIdBackPath;
              String? drivingLicensePath;
              String? motorcycleLicensePath;

              if (state is RegisterDelegateFilesSelected) {
                nationalIdFrontPath = state.nationalIdFrontPath;
                nationalIdBackPath = state.nationalIdBackPath;
                drivingLicensePath = state.drivingLicensePath;
                motorcycleLicensePath = state.motorcycleLicensePath;
              } else {
                final cubit = context.read<RegisterDelegateCubit>();
                nationalIdFrontPath = cubit.nationalIdFrontPath;
                nationalIdBackPath = cubit.nationalIdBackPath;
                drivingLicensePath = cubit.drivingLicensePath;
                motorcycleLicensePath = cubit.motorcycleLicensePath;
              }

              final isRunning =
                  state is RegisterDelegateUploadingImages ||
                  state is RegisterDelegateLoading;

              return Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'انضم لفريق مناديب نجيك',
                                style: GoogleFonts.cairo(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'يرجى ملء البيانات وإرفاق المستندات المطلوبة لمراجعة طلبك',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Name
                              _buildLabel('الاسم الكامل'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _nameController,
                                hintText: 'أدخل اسمك الكامل',
                                prefixIcon: Icons.person_outline,
                                enabled: !isRunning,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'يرجى إدخال الاسم'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              // Phone
                              _buildLabel('رقم الهاتف'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _phoneController,
                                hintText: '05XXXXXXXX',
                                prefixIcon: Icons.phone_android_outlined,
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.right,
                                enabled: !isRunning,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'يرجى إدخال رقم الهاتف'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              // Email
                              _buildLabel('البريد الإلكتروني'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _emailController,
                                hintText: 'example@domain.com',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.right,
                                enabled: !isRunning,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'يرجى إدخال البريد الإلكتروني'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              // Password
                              _buildLabel('كلمة المرور'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _passwordController,
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                textDirection: TextDirection.ltr,
                                enabled: !isRunning,
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
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'يرجى إدخال كلمة المرور'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              // Confirm Password
                              _buildLabel('تأكيد كلمة المرور'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _confirmPasswordController,
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscureConfirmPassword,
                                textDirection: TextDirection.ltr,
                                enabled: !isRunning,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF555555),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى تأكيد كلمة المرور';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'كلمات المرور غير متطابقة';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),

                              // Documents Section Header
                              Text(
                                'المستندات المطلوبة (صورة واضحة)',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Document Pickers
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDocPickerCard(
                                      title: 'الهوية الوطنية (الوجه)',
                                      filePath: nationalIdFrontPath,
                                      onTap: () => _pickImage(
                                        context,
                                        'nationalIdFront',
                                      ),
                                      enabled: !isRunning,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDocPickerCard(
                                      title: 'الهوية الوطنية (الظهر)',
                                      filePath: nationalIdBackPath,
                                      onTap: () =>
                                          _pickImage(context, 'nationalIdBack'),
                                      enabled: !isRunning,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDocPickerCard(
                                      title: 'رخصة القيادة',
                                      filePath: drivingLicensePath,
                                      onTap: () =>
                                          _pickImage(context, 'drivingLicense'),
                                      enabled: !isRunning,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDocPickerCard(
                                      title: 'رخصة الدراجة النارية',
                                      filePath: motorcycleLicensePath,
                                      onTap: () => _pickImage(
                                        context,
                                        'motorcycleLicense',
                                      ),
                                      enabled: !isRunning,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),

                              // Submit Button
                              ElevatedButton(
                                onPressed: isRunning
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context
                                              .read<RegisterDelegateCubit>()
                                              .registerDelegate(
                                                name: _nameController.text
                                                    .trim(),
                                                phone: _phoneController.text
                                                    .trim(),
                                                email: _emailController.text
                                                    .trim(),
                                                password: _passwordController
                                                    .text
                                                    .trim(),
                                              );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFC107),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'تقديم الطلب',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Overlay Loading / Uploading indicator
                  if (isRunning)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (state is RegisterDelegateUploadingImages) ...[
                                const SizedBox(
                                  height: 45,
                                  width: 45,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFFC107),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'جاري رفع المستندات إلى السحابة...',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'الملف الحالي: ${state.currentUploadingField}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: state.progress,
                                    backgroundColor: Colors.grey[200],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFFFFC107),
                                        ),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(state.progress * 100).toInt()}%',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ] else if (state is RegisterDelegateLoading) ...[
                                const SizedBox(
                                  height: 45,
                                  width: 45,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFFC107),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'جاري تسجيل البيانات وإرسال الطلب...',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDocPickerCard({
    required String title,
    required String? filePath,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    final hasFile = filePath != null;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: hasFile ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile
                ? Colors.green.withValues(alpha: 0.5)
                : Colors.black12,
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasFile) ...[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(
                            filePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Image.file(
                            File(filePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'تم الاختيار',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Colors.black45,
                  size: 32,
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
