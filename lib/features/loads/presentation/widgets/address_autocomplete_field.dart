import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/places_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class AddressAutocompleteField extends StatefulWidget {
  final String label;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(PlaceSuggestion suggestion)? onSelected;

  const AddressAutocompleteField({
    super.key,
    required this.label,
    required this.addressController,
    required this.cityController,
    required this.stateController,
    this.hint,
    this.validator,
    this.onSelected,
  });

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  final PlacesService _places = NominatimPlacesService();
  Timer? _debounce;

  bool _isLoading = false;
  List<PlaceSuggestion> _suggestions = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.addressController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.addressController.removeListener(_onTextChanged);
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final q = widget.addressController.text.trim();
      if (q.length < 3) {
        if (!mounted) return;
        setState(() {
          _suggestions = const [];
          _error = null;
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });
      try {
        final results = await _places.search(q);
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _suggestions = results;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _suggestions = const [];
          _error = 'Failed to fetch suggestions';
        });
      }
    });
  }

  void _selectSuggestion(PlaceSuggestion s) {
    widget.addressController.text = s.displayName;
    if (s.city != null && s.city!.trim().isNotEmpty) {
      widget.cityController.text = s.city!.trim();
    }
    if (s.state != null && s.state!.trim().isNotEmpty) {
      widget.stateController.text = s.state!.trim();
    }

    setState(() => _suggestions = const []);
    widget.onSelected?.call(s);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppDimensions.xs),
          Text(
            _error!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.danger),
          ),
        ],
        const SizedBox(height: AppDimensions.xs),
        TextFormField(
          controller: widget.addressController,
          validator: widget.validator,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search),
          ),
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.xs),
          Container(
            decoration: BoxDecoration(
              color: AppColors.glassSurfaceStrong,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.glassBorder),
            ),
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final s = _suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    s.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                  subtitle: (s.city != null || s.state != null)
                      ? Text(
                          [s.city, s.state]
                              .where((e) => e?.trim().isNotEmpty ?? false)
                              .map((e) => e!.trim())
                              .join(', '),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        )
                      : null,
                  onTap: () => _selectSuggestion(s),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
