import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/label.dart';
import '../../theme/app_spacing.dart';

/// A tappable row of label chips, mirroring [MemberSelector]'s controlled
/// shape: [selectedLabelId] holds the current selection and [onChanged] is
/// called with the next one. Single-select and optional — unlike a member
/// picker, tapping the already-selected chip clears it, since an expense is
/// allowed to have no label.
class LabelSelector extends StatelessWidget {
  const LabelSelector({
    super.key,
    required this.labels,
    required this.selectedLabelId,
    required this.onChanged,
    required this.onCreateNew,
  });

  final List<Label> labels;
  final String? selectedLabelId;
  final ValueChanged<String?> onChanged;
  final VoidCallback onCreateNew;

  void _handleTap(String labelId) {
    onChanged(selectedLabelId == labelId ? null : labelId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final label in labels)
          ShadBadge.raw(
            variant: ShadBadgeVariant.secondary,
            backgroundColor: label.color.withValues(alpha: 0.15),
            foregroundColor: label.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              side: BorderSide(
                color: selectedLabelId == label.id
                    ? label.color
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            onPressed: () => _handleTap(label.id),
            child: Text(
              [if (label.icon != null) label.icon!, label.name].join(' '),
            ),
          ),
        ShadBadge.outline(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            side: BorderSide(color: theme.colorScheme.border),
          ),
          onPressed: onCreateNew,
          child: const Text('+ Nueva'),
        ),
      ],
    );
  }
}
