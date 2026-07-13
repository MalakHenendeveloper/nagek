import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routes_manager/routes.dart';
import '../cubit/create_order_cubit.dart';
import '../cubit/create_order_state.dart';
import '../cubit/device_selection_cubit.dart';
import '../cubit/device_selection_state.dart';
import '../widgets/device_selector_widget.dart';

class CreateOrderScreen extends StatefulWidget {
  final String centerId;

  const CreateOrderScreen({super.key, required this.centerId});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  late CreateOrderCubit _cubit;
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0;

  // Form Fields
  String _selectedDeviceType = 'phone'; // phone, tablet, laptop
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  String _selectedProblemType = 'screen'; // screen, battery, software, other
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _imagePaths = [];
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep4 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<CreateOrderCubit>();
    _cityController.text = 'الرياض'; // default
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imagePaths.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء اختيار الصورة: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (!_formKeyStep2.currentState!.validate()) return;
    }
    if (_currentStep == 3) {
      if (!_formKeyStep4.currentState!.validate()) return;
    }

    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Submit order
      _cubit.createOrder(
        centerId: widget.centerId,
        deviceType: _selectedDeviceType,
        brand: _brandController.text,
        model: _modelController.text,
        problemType: _selectedProblemType,
        problemDescription: _descriptionController.text,
        imagePaths: _imagePaths,
        address: _addressController.text,
        city: _cityController.text,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  bool _isNextButtonEnabled() {
    if (_currentStep == 1) {
      if (_selectedDeviceType == 'phone') {
        return _brandController.text.trim().isNotEmpty &&
            _modelController.text.trim().isNotEmpty;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider(create: (_) => getIt<DeviceSelectionCubit>()..loadBrands()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFAF5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCFAF5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'إنشاء طلب صيانة',
            style: GoogleFonts.cairo(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocListener<DeviceSelectionCubit, DeviceSelectionState>(
            listener: (context, state) {
              if (_selectedDeviceType == 'phone') {
                setState(() {
                  if (state.selectedDevice != null) {
                    _brandController.text = state.selectedDevice!.brand;
                    _modelController.text = state.selectedDevice!.model;
                  } else if (state.manualDevice != null && state.selectedBrand != null) {
                    _brandController.text = state.selectedBrand!.name;
                    _modelController.text = state.manualDevice!;
                  } else {
                    _brandController.clear();
                    _modelController.clear();
                  }
                });
              }
            },
            child: BlocConsumer<CreateOrderCubit, CreateOrderState>(
              listener: (context, state) {
              if (state is CreateOrderSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إنشاء طلب الصيانة بنجاح!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Return to client home screen and pop all sheets
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.clientHomeRoute,
                  (route) => false,
                );
              } else if (state is CreateOrderError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is CreateOrderLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFC107),
                  ),
                );
              }

              return Column(
                children: [
                  _buildStepperProgress(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildCurrentStepContent(),
                    ),
                  ),
                  _buildBottomNavButtons(),
                ],
              );
            },
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildStepperProgress() {
    final titles = ['نوع الجهاز', 'الماركة والموديل', 'المشكلة والصور', 'العنوان', 'مراجعة'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Row(
        children: List.generate(titles.length, (index) {
          final isCompleted = index < _currentStep;
          final isActive = index == _currentStep;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == 0
                            ? Colors.transparent
                            : (isCompleted || isActive ? const Color(0xFFFFC107) : Colors.grey[300]),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? const Color(0xFFFFC107)
                            : (isCompleted ? const Color(0xFFFFC107) : Colors.white),
                        border: Border.all(
                          color: isCompleted || isActive ? const Color(0xFFFFC107) : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 14, color: Colors.black)
                            : Text(
                                '${index + 1}',
                                style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? Colors.black : Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == titles.length - 1
                            ? Colors.transparent
                            : (isCompleted ? const Color(0xFFFFC107) : Colors.grey[300]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  titles[index],
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Colors.black87 : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1DeviceType();
      case 1:
        return _buildStep2BrandModel();
      case 2:
        return _buildStep3ProblemDetails();
      case 3:
        return _buildStep4Address();
      case 4:
        return _buildStep5Review();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1DeviceType() {
    final types = [
      {'key': 'phone', 'title': 'هاتف ذكي', 'icon': Icons.phone_iphone},
      {'key': 'tablet', 'title': 'تابلت / آيباد', 'icon': Icons.tablet_mac},
      {'key': 'laptop', 'title': 'لابتوب', 'icon': Icons.laptop_mac},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ما هو نوع الجهاز الذي تود صيانته؟',
          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        ...types.map((type) {
          final isSelected = _selectedDeviceType == type['key'];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedDeviceType = type['key'] as String;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFFDE7) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFFC107) : Colors.black12,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(type['icon'] as IconData, size: 36, color: isSelected ? const Color(0xFFFFC107) : Colors.grey),
                    const SizedBox(width: 20),
                    Text(
                      type['title'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black87 : Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Color(0xFFFFC107))
                    else
                      const Icon(Icons.circle_outlined, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep2BrandModel() {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الشركة المصنعة والموديل',
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          if (_selectedDeviceType == 'phone')
            const DeviceSelectorWidget()
          else ...[
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: 'الشركة المصنعة (مثال: Apple, Samsung)',
                labelStyle: GoogleFonts.cairo(),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال اسم الشركة المصنعة';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: 'الموديل (مثال: iPhone 14 Pro Max, Galaxy S23)',
                labelStyle: GoogleFonts.cairo(),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال موديل الجهاز';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3ProblemDetails() {
    final problems = [
      {'key': 'screen', 'title': 'كسر في الشاشة'},
      {'key': 'battery', 'title': 'مشكلة بالبطارية'},
      {'key': 'software', 'title': 'أعطال السوفت وير'},
      {'key': 'other', 'title': 'مشكلة أخرى'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ما هي المشكلة التي تواجهها؟',
          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: problems.map((prob) {
            final isSelected = _selectedProblemType == prob['key'];
            return ChoiceChip(
              label: Text(
                prob['title'] as String,
                style: GoogleFonts.cairo(
                  color: isSelected ? Colors.black : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFFFFC107),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? const Color(0xFFFFC107) : Colors.black12),
              ),
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedProblemType = prob['key'] as String;
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'وصف المشكلة بالتفصيل',
          style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'اكتب هنا ما يشتكي منه الجهاز لمساعدة الفني في تحديد العطل بدقة...',
            hintStyle: GoogleFonts.cairo(fontSize: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'صور للجهاز (اختياري)',
          style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            InkWell(
              onTap: _pickImage,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFC107), style: BorderStyle.solid, width: 1.5),
                ),
                child: const Center(
                  child: Icon(Icons.add_photo_alternate_outlined, color: Color(0xFFFFC107), size: 32),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePaths.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(left: 12),
                      width: 80,
                      height: 80,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_imagePaths[index]),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildStep4Address() {
    return Form(
      key: _formKeyStep4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أين يمكننا استلام الجهاز منك؟',
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: 'المدينة',
              labelStyle: GoogleFonts.cairo(),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال المدينة';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'العنوان بالتفصيل (اسم الشارع، رقم المبنى)',
              labelStyle: GoogleFonts.cairo(),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال تفاصيل العنوان لسهولة الاستلام';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep5Review() {
    String devTypeAr = 'هاتف ذكي';
    if (_selectedDeviceType == 'tablet') devTypeAr = 'تابلت / آيباد';
    if (_selectedDeviceType == 'laptop') devTypeAr = 'لابتوب';

    String probTypeAr = 'كسر في الشاشة';
    if (_selectedProblemType == 'battery') probTypeAr = 'مشكلة بالبطارية';
    if (_selectedProblemType == 'software') probTypeAr = 'أعطال سوفت وير';
    if (_selectedProblemType == 'other') probTypeAr = 'مشكلة أخرى';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مراجعة طلب الصيانة الخاص بك',
          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          'يرجى مراجعة كافة البيانات والتأكيد لإرسال الطلب للفحص والاتفاق على التكلفة لاحقاً.',
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow('نوع الجهاز:', devTypeAr),
              const Divider(),
              _buildReviewRow('الماركة والموديل:', '${_brandController.text} ${_modelController.text}'),
              const Divider(),
              _buildReviewRow('نوع المشكلة:', probTypeAr),
              const Divider(),
              _buildReviewRow('وصف العطل:', _descriptionController.text.isNotEmpty ? _descriptionController.text : 'لا يوجد وصف إضافي'),
              const Divider(),
              _buildReviewRow('عنوان الاستلام:', '${_cityController.text}، ${_addressController.text}'),
              const Divider(),
              _buildReviewRow('عدد الصور المرفقة:', '${_imagePaths.length} صور'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black87),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'السابق',
                  style: GoogleFonts.cairo(color: Colors.black87, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isNextButtonEnabled() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _currentStep == 4 ? 'تأكيد وإرسال' : 'التالي',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
