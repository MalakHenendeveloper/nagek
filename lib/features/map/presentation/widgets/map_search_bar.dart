import 'package:flutter/material.dart';
import '../../domain/entities/map_location_entity.dart';

class MapSearchBar extends StatefulWidget {
  final void Function(String query) onChanged;
  final void Function(MapLocationEntity location) onLocationSelected;
  final List<MapLocationEntity> searchResults;

  const MapSearchBar({
    super.key,
    required this.onChanged,
    required this.onLocationSelected,
    this.searchResults = const [],
  });

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _showDropdown = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),

            ],
          ),
          child: TextField(
            controller: _controller,
            onChanged: (val) {
              setState(() {
                _showDropdown = val.trim().isNotEmpty;
              });
              widget.onChanged(val);
            },
            decoration: InputDecoration(
              hintText: 'ابحث عن اسم المنطقة أو الشارع...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _controller.clear();
                        widget.onChanged('');
                        setState(() {
                          _showDropdown = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (_showDropdown && widget.searchResults.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.searchResults.length,
              separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final location = widget.searchResults[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: Color(0xFF1E88E5)),
                  title: Text(
                    location.address ?? 'موقع على الخريطة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  subtitle: location.city != null ? Text(location.city!) : null,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _showDropdown = false;
                    });
                    widget.onLocationSelected(location);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
