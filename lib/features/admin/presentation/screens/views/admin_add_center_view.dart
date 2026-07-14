import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../cubit/admin_create_center_cubit.dart';
import '../../cubit/admin_create_center_state.dart';

class AdminAddCenterView extends StatefulWidget {
  final VoidCallback onSuccess;

  const AdminAddCenterView({super.key, required this.onSuccess});

  @override
  State<AdminAddCenterView> createState() => _AdminAddCenterViewState();
}

class _AdminAddCenterViewState extends State<AdminAddCenterView> {
  final _formKey = GlobalKey<FormState>();

  // Owner Controllers
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerPasswordController = TextEditingController();

  // Center Controllers
  final _centerNameController = TextEditingController();
  final _centerAddressController = TextEditingController();
  final _centerCityController = TextEditingController(text: 'بغداد');

  String? _logoPath;
  bool _obscurePassword = true;

  // Selected Brands & Device Types
  final List<String> _allBrands = [
    'Samsung',
    'Apple',
    'Redmi',
    'Realme',
    'Vivo',
    'Huawei',
    'Oppo',
    'Infinix',
    'Xiaomi'
  ];
  final List<String> _selectedBrands = ['Samsung', 'Apple', 'Redmi', 'Realme', 'Vivo'];

  final List<String> _allDeviceTypes = ['phone', 'tablet', 'laptop'];
  final List<String> _selectedDeviceTypes = ['phone'];

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
    _ownerPasswordController.dispose();
    _centerNameController.dispose();
    _centerAddressController.dispose();
    _centerCityController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _logoPath = image.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل في اختيار الصورة: $e',
            style: GoogleFonts.cairo(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedBrands.isEmpty) {
        _showErrorSnackBar('يرجى اختيار علامة تجارية واحدة مدعومة على الأقل');
        return;
      }
      if (_selectedDeviceTypes.isEmpty) {
        _showErrorSnackBar('يرجى اختيار نوع جهاز مدعوم واحد على الأقل');
        return;
      }

      context.read<AdminCreateCenterCubit>().createCenter(
            ownerName: _ownerNameController.text.trim(),
            phone: _ownerPhoneController.text.trim(),
            email: _ownerEmailController.text.trim(),
            password: _ownerPasswordController.text.trim(),
            name: _centerNameController.text.trim(),
            address: _centerAddressController.text.trim(),
            city: _centerCityController.text.trim(),
            supportedBrands: _selectedBrands,
            supportedDeviceTypes: _selectedDeviceTypes,
            logoPath: _logoPath,
            coordinates: const {'lat': 30.0444, 'lng': 31.2357},
          );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminCreateCenterCubit, AdminCreateCenterState>(
      listener: (context, state) {
        if (state is AdminCreateCenterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.cairo(color: Colors.white),
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          widget.onSuccess();
        } else if (state is AdminCreateCenterError) {
          _showErrorSnackBar(state.message);
        }
      },
      child: BlocBuilder<AdminCreateCenterCubit, AdminCreateCenterState>(
        builder: (context, state) {
          final isLoading = state is AdminCreateCenterLoading;

          return Scaffold(
            backgroundColor: const Color(0xFF0F0F0F),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'إنشاء مركز صيانة جديد',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'قم بملء البيانات لإنشاء حساب مالك المركز وبيانات المركز معاً',
                        style: GoogleFonts.cairo(
                          color: Colors.white30,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 1: Owner Info
                      _buildSectionTitle('1. بيانات مالك المركز (المستخدم)'),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: _ownerNameController,
                        label: 'اسم مالك المركز كامل',
                        icon: Icons.person_outline_rounded,
                        enabled: !isLoading,
                        validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال اسم المالك' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _ownerPhoneController,
                        label: 'رقم هاتف المالك',
                        icon: Icons.phone_android_rounded,
                        enabled: !isLoading,
                        textInputType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _ownerEmailController,
                        label: 'البريد الإلكتروني للمالك (لتسجيل الدخول)',
                        icon: Icons.email_outlined,
                        enabled: !isLoading,
                        textInputType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'يرجى إدخال البريد الإلكتروني';
                          final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegExp.hasMatch(v.trim())) return 'يرجى إدخال بريد إلكتروني صحيح';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _ownerPasswordController,
                        label: 'كلمة المرور لحساب المالك',
                        icon: Icons.lock_outline_rounded,
                        enabled: !isLoading,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white30,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'يرجى إدخال كلمة المرور';
                          if (v.length < 6) return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Section 2: Center Info
                      _buildSectionTitle('2. بيانات مركز الصيانة'),
                      const SizedBox(height: 12),

                      // Center Logo Picker
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: isLoading ? null : _pickLogo,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF141414),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white10),
                                  image: _logoPath != null
                                      ? DecorationImage(
                                          image: FileImage(File(_logoPath!)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _logoPath == null
                                    ? const Icon(
                                        Icons.add_photo_alternate_outlined,
                                        color: Colors.white30,
                                        size: 40,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _logoPath == null ? 'اختر شعار المركز (اختياري)' : 'تغيير الشعار',
                              style: GoogleFonts.cairo(
                                color: Colors.white30,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        controller: _centerNameController,
                        label: 'اسم مركز الصيانة التجاري',
                        icon: Icons.business_outlined,
                        enabled: !isLoading,
                        validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال اسم المركز' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _centerAddressController,
                        label: 'العنوان بالتفصيل',
                        icon: Icons.location_on_outlined,
                        enabled: !isLoading,
                        validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال عنوان المركز بالتفصيل' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _centerCityController,
                        label: 'المدينة',
                        icon: Icons.location_city_outlined,
                        enabled: !isLoading,
                        validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال المدينة' : null,
                      ),
                      const SizedBox(height: 16),

                      // Supported Brands ChoiceChips
                      Text(
                        'العلامات التجارية المدعومة للتصليح',
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _allBrands.map((brand) {
                          final isSelected = _selectedBrands.contains(brand);
                          return FilterChip(
                            label: Text(
                              brand,
                              style: GoogleFonts.cairo(
                                color: isSelected ? Colors.black : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFFFFC107),
                            checkmarkColor: Colors.black,
                            backgroundColor: const Color(0xFF141414),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFFFFC107) : Colors.white10,
                              ),
                            ),
                            onSelected: isLoading
                                ? null
                                : (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedBrands.add(brand);
                                      } else {
                                        _selectedBrands.remove(brand);
                                      }
                                    });
                                  },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Supported Device Types
                      Text(
                        'أنواع الأجهزة المدعومة',
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _allDeviceTypes.map((type) {
                          final isSelected = _selectedDeviceTypes.contains(type);
                          return FilterChip(
                            label: Text(
                              type == 'phone'
                                  ? 'هواتف ذكية'
                                  : type == 'tablet'
                                      ? 'أجهزة لوحية'
                                      : 'حواسيب محمولة',
                              style: GoogleFonts.cairo(
                                color: isSelected ? Colors.black : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFFFFC107),
                            checkmarkColor: Colors.black,
                            backgroundColor: const Color(0xFF141414),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFFFFC107) : Colors.white10,
                              ),
                            ),
                            onSelected: isLoading
                                ? null
                                : (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedDeviceTypes.add(type);
                                      } else {
                                        _selectedDeviceTypes.remove(type);
                                      }
                                    });
                                  },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 36),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  'إنشاء مركز الصيانة',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        color: const Color(0xFFFFC107),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType textInputType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: textInputType,
      obscureText: obscureText,
      style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: Colors.white30, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white30, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF141414),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFFC107)),
        ),
        errorStyle: GoogleFonts.cairo(fontSize: 11),
      ),
      validator: validator,
    );
  }
}
