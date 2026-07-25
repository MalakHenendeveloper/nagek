import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/admin_payment_settings_cubit.dart';
import '../../cubit/admin_payment_settings_state.dart';

class AdminPaymentSettingsView extends StatefulWidget {
  const AdminPaymentSettingsView({super.key});

  @override
  State<AdminPaymentSettingsView> createState() =>
      _AdminPaymentSettingsViewState();
}

class _AdminPaymentSettingsViewState extends State<AdminPaymentSettingsView> {
  final _formKey = GlobalKey<FormState>();

  final _ownerNameController = TextEditingController();
  final _zainCashController = TextEditingController();
  final _westernUnionController = TextEditingController();
  final _visaController = TextEditingController();
  final _mastercardController = TextEditingController();
  final _instructionsController = TextEditingController();

  final List<String> _allPaymentMethods = [
    'zain_cash',
    'western_union',
    'visa',
    'mastercard',
  ];
  final List<String> _activeMethods = [];

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    context.read<AdminPaymentSettingsCubit>().fetchPaymentSettings();
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _zainCashController.dispose();
    _westernUnionController.dispose();
    _visaController.dispose();
    _mastercardController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _initFields(AdminPaymentSettingsLoaded state) {
    if (_initialized) return;
    _ownerNameController.text = state.settings.walletOwnerName;
    _zainCashController.text = state.settings.walletNumbers.zainCash;
    _westernUnionController.text = state.settings.walletNumbers.westernUnion;
    _visaController.text = state.settings.walletNumbers.visa;
    _mastercardController.text = state.settings.walletNumbers.mastercard;
    _instructionsController.text = state.settings.paymentInstructions;
    _activeMethods.clear();
    _activeMethods.addAll(state.settings.activePaymentMethods);
    _initialized = true;
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AdminPaymentSettingsCubit>().updatePaymentSettings(
        walletOwnerName: _ownerNameController.text.trim(),
        walletNumbers: {
          'zain_cash': _zainCashController.text.trim(),
          'western_union': _westernUnionController.text.trim(),
          'visa': _visaController.text.trim(),
          'mastercard': _mastercardController.text.trim(),
        },
        activePaymentMethods: _activeMethods,
        paymentInstructions: _instructionsController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminPaymentSettingsCubit, AdminPaymentSettingsState>(
      listener: (context, state) {
        if (state is AdminPaymentSettingsLoaded) {
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
        if (state is AdminPaymentSettingsLoading ||
            state is AdminPaymentSettingsInitial) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          );
        } else if (state is AdminPaymentSettingsError) {
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
                          .read<AdminPaymentSettingsCubit>()
                          .fetchPaymentSettings();
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
        } else if (state is AdminPaymentSettingsLoaded) {
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
                      _buildSectionTitle('صاحب الحساب/المحفظة'),
                      const SizedBox(height: 10),
                      _buildInputField(
                        controller: _ownerNameController,
                        label: 'اسم صاحب المحفظة (الشركة/المالك)',
                        icon: Icons.person_outline,
                        enabled: !isUpdating,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم صاحب المحفظة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('طرق الدفع النشطة في التطبيق'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _allPaymentMethods.map((method) {
                          final isSelected = _activeMethods.contains(method);
                          String labelAr = method;
                          if (method == 'zain_cash') {
                            labelAr = 'زين كاش';
                          } else if (method == 'western_union') {
                            labelAr = 'ويسترن يونيون';
                          } else if (method == 'visa') {
                            labelAr = 'فيزا كارد';
                          } else if (method == 'mastercard') {
                            labelAr = 'ماستركارد';
                          }

                          return FilterChip(
                            label: Text(
                              labelAr,
                              style: GoogleFonts.cairo(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFFFFC107),
                            checkmarkColor: Colors.black,
                            backgroundColor: const Color(0xFF141414),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFFFFC107)
                                    : Colors.white10,
                              ),
                            ),
                            onSelected: isUpdating
                                ? null
                                : (selected) {
                                    setState(() {
                                      if (selected) {
                                        _activeMethods.add(method);
                                      } else {
                                        _activeMethods.remove(method);
                                      }
                                    });
                                  },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      if (_activeMethods.isNotEmpty) ...[
                        _buildSectionTitle('أرقام وحسابات المحافظ النشطة'),
                        const SizedBox(height: 10),
                        if (_activeMethods.contains('zain_cash')) ...[
                          _buildInputField(
                            controller: _zainCashController,
                            label: 'رقم محفظة زين كاش (Zain Cash)',
                            icon: Icons.phone_android_outlined,
                            enabled: !isUpdating,
                            textInputType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (_activeMethods.contains('western_union')) ...[
                          _buildInputField(
                            controller: _westernUnionController,
                            label: 'بيانات ويسترن يونيون (Western Union)',
                            icon: Icons.account_balance_outlined,
                            enabled: !isUpdating,
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (_activeMethods.contains('visa')) ...[
                          _buildInputField(
                            controller: _visaController,
                            label: 'رقم بطاقة فيزا (Visa)',
                            icon: Icons.credit_card_outlined,
                            enabled: !isUpdating,
                            textInputType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (_activeMethods.contains('mastercard')) ...[
                          _buildInputField(
                            controller: _mastercardController,
                            label: 'رقم بطاقة ماستركارد (Mastercard)',
                            icon: Icons.credit_card_outlined,
                            enabled: !isUpdating,
                            textInputType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),
                        ],
                        const SizedBox(height: 10),
                      ],

                      _buildSectionTitle('تعليمات وطريقة الدفع للعملاء'),
                      const SizedBox(height: 10),
                      _buildInputField(
                        controller: _instructionsController,
                        label:
                            'اكتب تفاصيل وإرشادات الدفع للعميل عند اختيار الدفع الإلكتروني...',
                        icon: Icons.info_outline,
                        enabled: !isUpdating,
                        maxLines: 4,
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
                                  'حفظ الإعدادات',
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
