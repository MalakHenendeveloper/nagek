import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/admin_financial_settings_cubit.dart';
import '../../cubit/admin_financial_settings_state.dart';

class AdminFinancialSettingsView extends StatefulWidget {
  const AdminFinancialSettingsView({super.key});

  @override
  State<AdminFinancialSettingsView> createState() =>
      _AdminFinancialSettingsViewState();
}

class _AdminFinancialSettingsViewState
    extends State<AdminFinancialSettingsView> {
  final _formKey = GlobalKey<FormState>();

  final _commissionValueController = TextEditingController();
  final _delegateFeeValueController = TextEditingController();
  final _currencyController = TextEditingController();

  String _commissionType = 'percentage';
  String _delegateFeeType = 'fixed';
  bool _isActive = true;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    context.read<AdminFinancialSettingsCubit>().fetchFinancialSettings();
  }

  @override
  void dispose() {
    _commissionValueController.dispose();
    _delegateFeeValueController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _initFields(AdminFinancialSettingsLoaded state) {
    if (_initialized) return;
    _commissionType = state.settings.commissionType;
    _commissionValueController.text = state.settings.commissionValue.toString();
    _delegateFeeType = state.settings.delegateFeeType;
    _delegateFeeValueController.text = state.settings.delegateFeeValue.toString();
    _currencyController.text = state.settings.currency;
    _isActive = state.settings.isActive;
    _initialized = true;
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AdminFinancialSettingsCubit>().updateFinancialSettings(
            commissionType: _commissionType,
            commissionValue:
                double.tryParse(_commissionValueController.text.trim()) ?? 0.0,
            delegateFeeType: _delegateFeeType,
            delegateFeeValue:
                double.tryParse(_delegateFeeValueController.text.trim()) ?? 0.0,
            currency: _currencyController.text.trim().isEmpty
                ? 'IQD'
                : _currencyController.text.trim(),
            isActive: _isActive,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminFinancialSettingsCubit,
        AdminFinancialSettingsState>(
      listener: (context, state) {
        if (state is AdminFinancialSettingsLoaded) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.successMessage!,
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error!,
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is AdminFinancialSettingsLoading ||
            state is AdminFinancialSettingsInitial) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          );
        } else if (state is AdminFinancialSettingsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      context
                          .read<AdminFinancialSettingsCubit>()
                          .fetchFinancialSettings();
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'إعادة المحاولة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is AdminFinancialSettingsLoaded) {
          _initFields(state);
          final isUpdating = state.isUpdating;

          return Material(
            color: Colors.transparent,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('نسبة/عمولة الأدمن من الطلبات'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: _commissionType,
                              dropdownColor: const Color(0xFF141414),
                              style: GoogleFonts.cairo(
                                  color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'نوع العمولة',
                                labelStyle: GoogleFonts.cairo(
                                    color: Colors.white30, fontSize: 12),
                                filled: true,
                                fillColor: const Color(0xFF141414),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide:
                                      const BorderSide(color: Colors.white10),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'percentage',
                                    child: Text('نسبة مئوية (%)')),
                                DropdownMenuItem(
                                    value: 'fixed', child: Text('مبلغ ثابت')),
                              ],
                              onChanged: isUpdating
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        setState(() => _commissionType = val);
                                      }
                                    },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: _buildInputField(
                              controller: _commissionValueController,
                              label: 'قيمة العمولة',
                              icon: Icons.percent,
                              enabled: !isUpdating,
                              textInputType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('أجرة/عمولة المندوب عن التوصيل'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: _delegateFeeType,
                              dropdownColor: const Color(0xFF141414),
                              style: GoogleFonts.cairo(
                                  color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'نوع رسوم المندوب',
                                labelStyle: GoogleFonts.cairo(
                                    color: Colors.white30, fontSize: 12),
                                filled: true,
                                fillColor: const Color(0xFF141414),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide:
                                      const BorderSide(color: Colors.white10),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'fixed', child: Text('مبلغ ثابت')),
                                DropdownMenuItem(
                                    value: 'percentage',
                                    child: Text('نسبة مئوية (%)')),
                              ],
                              onChanged: isUpdating
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        setState(() => _delegateFeeType = val);
                                      }
                                    },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: _buildInputField(
                              controller: _delegateFeeValueController,
                              label: 'قيمة أجرة المندوب',
                              icon: Icons.attach_money,
                              enabled: !isUpdating,
                              textInputType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('إعدادات النظام العامة'),
                      const SizedBox(height: 10),
                      _buildInputField(
                        controller: _currencyController,
                        label: 'العملة',
                        icon: Icons.monetization_on_outlined,
                        enabled: !isUpdating,
                      ),
                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isUpdating ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: isUpdating
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  'حفظ الإعدادات المالية',
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
        }
        return const SizedBox.shrink();
      },
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
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: textInputType,
      maxLines: maxLines,
      style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: Colors.white30, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white30, size: 20),
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
