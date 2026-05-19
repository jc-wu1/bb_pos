import 'package:flutter/material.dart';

enum StatusPillStatus { open, completed, canceled }

extension StatusPillStatusValues on StatusPillStatus {
  String get label {
    return switch (this) {
      StatusPillStatus.open => 'Open',
      StatusPillStatus.completed => 'Completed',
      StatusPillStatus.canceled => 'Canceled',
    };
  }

  Color foregroundColor(ColorScheme colorScheme) {
    return switch (this) {
      StatusPillStatus.open => const Color(0xffd97706),
      StatusPillStatus.completed => const Color(0xff0f9f6e),
      StatusPillStatus.canceled => colorScheme.error,
    };
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final StatusPillStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = status.foregroundColor(theme.colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          status.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
