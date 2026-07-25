import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di.dart';
import '../../domain/entities/service_entity.dart';
import '../cubit/update_center_service_cubit.dart';
import '../cubit/update_center_service_state.dart';

class EditCenterServiceScreen extends StatelessWidget {
  final ServiceEntity service;

  const EditCenterServiceScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<UpdateCenterServiceCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text(
            'تعديل الخدمة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          foregroundColor: const Color(0xFFFFC107),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: _EditCenterServiceForm(service: service),
        ),
      ),
    );
  }
}

class _EditCenterServiceForm extends StatefulWidget {
  final ServiceEntity service;

  const _EditCenterServiceForm({required this.service});

  @override
  State<_EditCenterServiceForm> createState() => _EditCenterServiceFormState();
}

class _EditCenterServiceFormState extends State<_EditCenterServiceForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _serviceNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _estimatedTimeController;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _serviceNameController = TextEditingController(text: widget.service.serviceName);
    _descriptionController = TextEditingController(text: widget.service.description);
    _priceController = TextEditingController(text: widget.service.price > 0 ? widget.service.price.toStringAsFixed(0) : '');
    _estimatedTimeController = TextEditingController(text: widget.service.estimatedTime);
    _isAvailable = widget.service.isAvailable;
  }

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

      context.read<UpdateCenterServiceCubit>().updateService(
            serviceId: widget.service.id,
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
    return BlocConsumer<UpdateCenterServiceCubit, UpdateCenterServiceState>(
      listener: (context, state) {
        if (state is UpdateCenterServiceSuccess) {
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
        } else if (state is UpdateCenterServiceError) {
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
        final isLoading = state is UpdateCenterServiceLoading;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحديث بيانات الخدمة',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'يرجى إدخال التعديلات المطلوبة للخدمة في مركز الصيانة',
                  style: GoogleFonts.cairo(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),

                // Service Name
                _buildLabel('اسم الخدمة *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _serviceNameController,
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hint: 'مثال: تغيير بطارية',
                    icon: Icons.build_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال اسم الخدمة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description
                _buildLabel('وصف الخدمة'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hint: 'أدخل تفاصيل ووصف الخدمة...',
                    icon: Icons.description_outlined,
                  ),
                ),
                const SizedBox(height: 20),

                // Price & Estimated Time Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('السعر (د.ع) *'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.cairo(color: Colors.white),
                            decoration: _buildInputDecoration(
                              hint: 'مثال: 900',
                              icon: Icons.monetization_on_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'مطلوب';
                              }
                              if (double.tryParse(value.trim()) == null) {
                                return 'رقم غير صحيح';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('الوقت المقدر *'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _estimatedTimeController,
                            style: GoogleFonts.cairo(color: Colors.white),
                            decoration: _buildInputDecoration(
                              hint: 'مثال: 45 دقيقة',
                              icon: Icons.timer_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'مطلوب';
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

                // Availability Switch Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isAvailable ? Icons.check_circle : Icons.cancel,
                            color: _isAvailable ? Colors.greenAccent : Colors.redAccent,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'حالة توفر الخدمة',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _isAvailable ? 'متاحة للطلب الآن' : 'غير متاحة حالياً',
                                style: GoogleFonts.cairo(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _isAvailable,
                        activeThumbColor: const Color(0xFFFFC107),
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
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
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
                            'حفظ التعديلات',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.cairo(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(color: Colors.white30, fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFFFFC107), size: 20),
      filled: true,
      fillColor: const Color(0xFF141414),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
