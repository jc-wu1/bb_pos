import 'package:flutter/material.dart';

enum AppButtonVariant { primary, tonal, outline, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isExpanded = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isExpanded;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final button = switch (variant) {
      AppButtonVariant.primary =>
        icon == null
            ? FilledButton(
                onPressed: isLoading ? null : onPressed,
                style: _style,
                child: _child(context),
              )
            : FilledButton.icon(
                onPressed: isLoading ? null : onPressed,
                style: _style,
                icon: _icon(),
                label: _child(context),
              ),
      AppButtonVariant.tonal =>
        icon == null
            ? FilledButton.tonal(
                onPressed: isLoading ? null : onPressed,
                style: _style,
                child: _child(context),
              )
            : FilledButton.tonalIcon(
                onPressed: isLoading ? null : onPressed,
                style: _style,
                icon: _icon(),
                label: _child(context),
              ),
      AppButtonVariant.outline =>
        icon == null
            ? OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: _style,
                child: _child(context),
              )
            : OutlinedButton.icon(
                onPressed: isLoading ? null : onPressed,
                style: _style,
                icon: _icon(),
                label: _child(context),
              ),
      AppButtonVariant.text =>
        icon == null
            ? TextButton(
                onPressed: isLoading ? null : onPressed,
                style: _style,
                child: _child(context),
              )
            : TextButton.icon(
                onPressed: isLoading ? null : onPressed,
                style: _style,
                icon: _icon(),
                label: _child(context),
              ),
    };

    if (!isExpanded) return button;

    return SizedBox(width: double.infinity, child: button);
  }

  ButtonStyle get _style {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 42)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _child(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _progressColor(context),
        ),
      );
    }

    return Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  Widget _icon() {
    if (isLoading) return const SizedBox.shrink();
    return Icon(icon);
  }

  Color _progressColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return variant == AppButtonVariant.primary
        ? colorScheme.onPrimary
        : colorScheme.primary;
  }
}
