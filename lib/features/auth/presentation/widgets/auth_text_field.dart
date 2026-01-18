import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? errorText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;
  final int? maxLength;
  final void Function(String)? onChanged;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppDimensions.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          enabled: enabled,
          maxLength: maxLength,
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefix,
            suffixIcon: suffix,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
