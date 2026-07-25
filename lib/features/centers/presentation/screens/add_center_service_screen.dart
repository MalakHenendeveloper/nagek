import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../cubit/add_center_service_cubit.dart';
import '../cubit/add_center_service_state.dart';

class AddCenterServiceScreen extends StatelessWidget {
  const AddCenterServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AddCenterServiceCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text(
            'إضافة خدمة جديدة للمركز',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          foregroundColor: const Color(0xFFFFC107),
        ),
        body: const Directionality(
          textDirection: TextDirection.rtl,
          child: _AddCenterServiceForm(),
        ),
      ),
    );
  }
}

class _AddCenterServiceForm extends StatefulWidget {
  const _AddCenterServiceForm();

  @override
  State<_AddCenterServiceForm> createState() => _AddCenterServiceFormState();
}

class _AddCenterServiceFormState extends State<_AddCenterServiceForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _estimatedTimeController = TextEditingController();
  bool _isAvailable = true;

  @override
  void dispose() {
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _serviceNameController.text.trim();
      final desc = _descriptionController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final time = _estimatedTimeController.text.trim();

      context.read<AddCenterServiceCubit>().addService(
            serviceName: name,
            description: desc,
            price: price,
            estimatedTime: time,
            isAvailable: _isAvailable,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCenterServiceCubit, AddCenterServiceState>(
      listener: (context, state) {
        if (state is AddCenterServiceSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.cairo(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFFFFC107),
            ),
          );
          Navigator.pop(context, true);
        } else if (state is AddCenterServiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.cairo(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AddCenterServiceLoading;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.build_outlined,
                          color: Color(0xFFFFC107),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إضافة خدمة صيانة',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'قم بإدخال تفاصيل الخدمة والسعر والوقت المقدر للعملاء.',
                              style: GoogleFonts.cairo(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 1. Service Name Field
                Text(
                  'اسم الخدمة *',
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _serviceNameController,
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'مثال: تغيير سماعة، استبدال شاشة...',
                    hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF141414),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى إدخال اسم الخدمة';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 2. Description Field
                Text(
                  'وصف الخدمة *',
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'اكتب تفاصيل ومواصفات الخدمة...',
                    hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF141414),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى إدخال وصف الخدمة';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 3. Price & Estimated Time Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'السعر (د.ع) *',
                            style: GoogleFonts.cairo(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: '500',
                              hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 12),
                              filled: true,
                              fillColor: const Color(0xFF141414),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white24),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white24),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'مطلوب السعر';
                              }
                              if (double.tryParse(val.trim()) == null) {
                                return 'أدخل رقم صحيح';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الوقت المقدر *',
                            style: GoogleFonts.cairo(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _estimatedTimeController,
                            style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: '2 ساعات',
                              hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 12),
                              filled: true,
                              fillColor: const Color(0xFF141414),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white24),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white24),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'مطلوب الوقت';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 4. Availability Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الخدمة متاحة حالياً',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: _isAvailable,
                        activeTrackColor: const Color(0xFFFFC107),
                        onChanged: (val) {
                          setState(() {
                            _isAvailable = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading ? null : _submitForm,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'إضافة الخدمة الآن',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
