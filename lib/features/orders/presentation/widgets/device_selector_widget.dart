import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/device_selection_cubit.dart';
import '../cubit/device_selection_state.dart';
import '../../data/models/device_model.dart';

class DeviceSelectorWidget extends StatefulWidget {
  const DeviceSelectorWidget({super.key});

  @override
  State<DeviceSelectorWidget> createState() => _DeviceSelectorWidgetState();
}

class _DeviceSelectorWidgetState extends State<DeviceSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _manualController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceSelectionCubit, DeviceSelectionState>(
      builder: (context, state) {
        final cubit = context.read<DeviceSelectionCubit>();

        // Keep local manual controller in sync if manual entry is cleared
        if (state.manualDevice == null && _manualController.text.isNotEmpty) {
          _manualController.clear();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (val) {
                cubit.filterDevices(query: val);
              },
              decoration: InputDecoration(
                hintText: 'ابحث عن موديل جهازك (مثال: S24, iPhone 16)...',
                hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFFC107)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Brands Horizontal List
            Text(
              'اختر الشركة المصنعة:',
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 95,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.brands.length + 1, // +1 for "All"
                itemBuilder: (context, index) {
                  final isAllOption = index == 0;
                  final BrandModel? brand = isAllOption ? null : state.brands[index - 1];
                  final isSelected = isAllOption
                      ? state.selectedBrand == null
                      : state.selectedBrand?.name == brand?.name;

                  return Container(
                    margin: const EdgeInsets.only(left: 12),
                    child: InkWell(
                      onTap: () {
                        cubit.selectBrand(brand);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 85,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFFDE7) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFFC107) : Colors.black12,
                            width: 2,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isAllOption)
                              const Icon(Icons.devices, size: 28, color: Colors.grey)
                            else
                              Image.asset(
                                brand!.logo,
                                height: 28,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.phone_android, size: 28, color: Colors.grey),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              isAllOption ? 'الكل' : brand!.name,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.black87 : Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Devices List or Fallback
            Text(
              'اختر الموديل:',
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),

            if (state.filteredDevices.isNotEmpty) ...[
              Container(
                constraints: const BoxConstraints(maxHeight: 280),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: state.filteredDevices.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
                    itemBuilder: (context, index) {
                      final device = state.filteredDevices[index];
                      final isSelected = state.selectedDevice?.id == device.id;

                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          device.model,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFFE6A100) : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          '${device.brand} • ${device.series} • ${device.year}',
                          style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Color(0xFFFFC107), size: 20)
                            : const Icon(Icons.circle_outlined, color: Colors.grey, size: 20),
                        selected: isSelected,
                        selectedTileColor: const Color(0xFFFFFDE7).withValues(alpha: 0.5),
                        onTap: () {
                          cubit.selectDevice(device);
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildManualEntryFallback(context, state),
          ],
        );
      },
    );
  }

  Widget _buildManualEntryFallback(BuildContext context, DeviceSelectionState state) {
    final cubit = context.read<DeviceSelectionCubit>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFE6A100), size: 20),
              const SizedBox(width: 8),
              Text(
                'لم تجد جهازك؟',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFB37400),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (state.selectedBrand == null) ...[
            Text(
              'الرجاء اختيار الماركة أولاً من القائمة في الأعلى، ثم كتابة اسم الموديل يدوياً هنا.',
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.black54),
            ),
          ] else ...[
            Text(
              'اكتب اسم موديل جهازك لشركة (${state.selectedBrand!.name}) يدوياً:',
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _manualController,
              onChanged: (val) {
                cubit.setManualDevice(val);
              },
              decoration: InputDecoration(
                hintText: 'مثال: Galaxy Note 30, iPhone 18...',
                hintStyle: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1.5),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
