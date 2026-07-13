import 'dart:async';

import 'package:flutter/material.dart';
import 'package:coffee_card/core/constants/app_colors.dart';
import 'package:coffee_card/core/network/places_datasource.dart';

/// A street field with Google Places autocomplete via the backend proxy. On
/// selecting a suggestion it resolves the full address and hands the structured
/// fields back through [onSelected] so the rest of the form can be filled in.
class AddressAutocompleteField extends StatefulWidget {
  const AddressAutocompleteField({
    required this.controller,
    required this.onSelected,
    this.decoration,
    super.key,
  });

  final TextEditingController controller;
  final void Function(PlaceAddress address) onSelected;
  final InputDecoration? decoration;

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  final _places = PlacesDatasource();
  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = const [];
  bool _loading = false;
  bool _suppressNext = false;

  void _onChanged(String value) {
    if (_suppressNext) {
      _suppressNext = false;
      return;
    }
    _debounce?.cancel();
    final q = value.trim();
    if (q.length < 3) {
      setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _loading = true);
      try {
        final res = await _places.autocomplete(q);
        if (mounted) {
          setState(() {
            _suggestions = res;
            _loading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _suggestions = const [];
            _loading = false;
          });
        }
      }
    });
  }

  Future<void> _select(PlaceSuggestion s) async {
    _debounce?.cancel();
    setState(() {
      _suggestions = const [];
      _loading = true;
    });
    try {
      final addr = await _places.details(s.placeId);
      _suppressNext = true;
      widget.controller.text = addr.street.isNotEmpty ? addr.street : s.mainText;
      widget.onSelected(addr);
    } catch (_) {
      _suppressNext = true;
      widget.controller.text = s.description;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          onChanged: _onChanged,
          textInputAction: TextInputAction.next,
          decoration: (widget.decoration ?? const InputDecoration()).copyWith(
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.place_outlined, size: 20),
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isDark
                      ? AppColors.amberBorderDark
                      : const Color(0x14000000)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final s in _suggestions.take(5))
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined, size: 18),
                    title: Text(s.mainText,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: s.secondaryText.isEmpty
                        ? null
                        : Text(s.secondaryText,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => _select(s),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
