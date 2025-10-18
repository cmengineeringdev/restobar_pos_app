import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

/// Campo de texto personalizado con diseño profesional
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          readOnly: readOnly,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w400,
          ),
          cursorColor: AppTheme.primaryColor,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textDisabled),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppTheme.textSecondary, size: 20)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppTheme.surfaceColor,
            // Bordes explícitos para sobrescribir cualquier comportamiento por defecto
            enabledBorder: const OutlineInputBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(AppTheme.radiusSmall)),
              borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(AppTheme.radiusSmall)),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(AppTheme.radiusSmall)),
              borderSide: BorderSide(color: AppTheme.errorColor, width: 1),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(AppTheme.radiusSmall)),
              borderSide: BorderSide(color: AppTheme.errorColor, width: 2),
            ),
            border: const OutlineInputBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(AppTheme.radiusSmall)),
              borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
