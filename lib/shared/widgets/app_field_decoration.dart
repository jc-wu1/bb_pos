import 'package:flutter/material.dart';

InputDecoration appFieldDecoration(
  BuildContext context, {
  required String label,
  String? hint,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: colorScheme.outlineVariant),
  );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    suffixIcon: suffixIcon,
    isDense: true,
    filled: true,
    fillColor: colorScheme.surfaceContainerLow,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
    ),
  );
}
