import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.onDeleted});
  final String label;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Chip(
      label: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurface)),
      deleteIcon: onDeleted != null ? const Icon(Icons.close, size: 16) : null,
      onDeleted: onDeleted,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: cs.outline.withValues(alpha: 0.2))),
      backgroundColor: cs.surface,
    );
  }
}
