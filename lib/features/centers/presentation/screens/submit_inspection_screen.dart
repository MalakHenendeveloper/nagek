import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/di.dart';
import '../cubit/submit_inspection_cubit.dart';
import '../cubit/submit_inspection_state.dart';

class SubmitInspectionScreen extends StatefulWidget {
  final String orderId;

  const SubmitInspectionScreen({super.key, required this.orderId});

  @override
  State<SubmitInspectionScreen> createState() => _SubmitInspectionScreenState();
}

class _SubmitInspectionScreenState extends State<SubmitInspectionScreen> {
  late SubmitInspectionCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  final _technicianController = TextEditingController();
  final _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> _findings = [];
  final List<XFile> _images = [];

  @override
  void initState() {
    super.initState();
    _cubit = getIt<SubmitInspectionCubit>();
    // Start with one empty finding
    _addFinding();
  }

  @override
  void dispose() {
    _technicianController.dispose();
    _notesController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _addFinding() {
    setState(() {
      _findings.add({'issue': '', 'severity': 'minor'});
    });
  }

  void _removeFinding(int index) {
    setState(() {
      _findings.removeAt(index);
    });
  }

  Future<void> _pickImages() async {
    final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_findings.isEmpty || _findings.every((f) => f['issue']!.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إضافة نتيجة فحص واحدة على الأقل', style: GoogleFonts.cairo()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Filter out empty findings
    final validFindings = _findings
        .where((f) => f['issue']!.trim().isNotEmpty)
        .map((f) => {'issue': f['issue']!.trim(), 'severity': f['severity']!})
        .toList();

    _cubit.submitInspection(
      orderId: widget.orderId,
      technician: _technicianController.text.trim(),
      notes: _notesController.text.trim(),
      findings: validFindings,
      imagePaths: _images.map((img) => img.path).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text('تقرير الفحص', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFF141414),
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFFFFC107)),
        ),
        body: BlocConsumer<SubmitInspectionCubit, SubmitInspectionState>(
          listener: (context, state) {
            if (state is SubmitInspectionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تسجيل نتيجة الفحص بنجاح ✅', style: GoogleFonts.cairo()),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true); // Return true to indicate success
            }
            if (state is SubmitInspectionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: GoogleFonts.cairo()),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is SubmitInspectionLoading;
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Technician Name ─────────────────────
                          _buildSectionTitle('اسم الفني', Icons.engineering_outlined),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _technicianController,
                            hint: 'أدخل اسم الفني المسؤول عن الفحص',
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'اسم الفني مطلوب';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // ─── Findings ────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle('نتائج الفحص', Icons.search_outlined),
                              TextButton.icon(
                                onPressed: _addFinding,
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFFC107), size: 20),
                                label: Text(
                                  'إضافة',
                                  style: GoogleFonts.cairo(color: const Color(0xFFFFC107), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ..._findings.asMap().entries.map((entry) {
                            final index = entry.key;
                            return _buildFindingCard(index);
                          }),
                          const SizedBox(height: 24),

                          // ─── Notes ───────────────────────────────
                          _buildSectionTitle('ملاحظات الفحص', Icons.notes_outlined),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _notesController,
                            hint: 'أدخل ملاحظات إضافية حول حالة الجهاز',
                            maxLines: 4,
                          ),
                          const SizedBox(height: 24),

                          // ─── Images ──────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle('صور الفحص', Icons.camera_alt_outlined),
                              TextButton.icon(
                                onPressed: _pickImages,
                                icon: const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFFFFC107), size: 20),
                                label: Text(
                                  'إضافة صور',
                                  style: GoogleFonts.cairo(color: const Color(0xFFFFC107), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_images.isEmpty)
                            Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFF141414),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image_outlined, color: Colors.white24, size: 40),
                                  const SizedBox(height: 8),
                                  Text(
                                    'لم يتم إضافة صور بعد',
                                    style: GoogleFonts.cairo(color: Colors.white30, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          else
                            SizedBox(
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _images.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: kIsWeb
                                            ? Image.network(
                                                _images[index].path,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(_images[index].path),
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: GestureDetector(
                                          onTap: () => _removeImage(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.redAccent,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 40),

                          // ─── Submit Button ───────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFC107),
                                foregroundColor: Colors.black87,
                                disabledBackgroundColor: const Color(0xFFFFC107).withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
                                    )
                                  : const Icon(Icons.send_rounded),
                              label: Text(
                                isLoading ? 'جاري التسجيل...' : 'تسجيل نتيجة الفحص',
                                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Helper Widgets ──────────────────────────────────────

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(color: Colors.white30, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF141414),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: GoogleFonts.cairo(color: Colors.redAccent, fontSize: 11),
      ),
    );
  }

  Widget _buildFindingCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المشكلة ${index + 1}',
                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white54),
              ),
              if (_findings.length > 1)
                GestureDetector(
                  onTap: () => _removeFinding(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Issue description
          TextFormField(
            initialValue: _findings[index]['issue'],
            onChanged: (val) => _findings[index]['issue'] = val,
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'وصف المشكلة (مثال: كسر الشاشة)',
              hintStyle: GoogleFonts.cairo(color: Colors.white30, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Severity selector
          Text(
            'مستوى الخطورة',
            style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSeverityChip(index, 'minor', 'بسيطة', Colors.green),
              const SizedBox(width: 8),
              _buildSeverityChip(index, 'critical', 'حرجة', Colors.orange),
              const SizedBox(width: 8),
              _buildSeverityChip(index, 'major', 'خطيرة', Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(int findingIndex, String value, String label, Color color) {
    final isSelected = _findings[findingIndex]['severity'] == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _findings[findingIndex]['severity'] = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color.withValues(alpha: 0.5) : Colors.white10,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
