import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/member.dart';
import '../../theme/app_spacing.dart';
import 'avatar.dart';

/// A tappable row of member avatars used to pick who paid or who an
/// expense is split between.
///
/// Controlled widget: [selectedIds] holds the current selection and
/// [onChanged] is called with the next selection on tap — this widget owns
/// no state itself. When [multiSelect] is false, tapping a member replaces
/// the selection with just that member; tapping the already-selected
/// member is a no-op, since callers relying on single-select (e.g. "Paid
/// by") require exactly one member selected at all times.
class MemberSelector extends StatelessWidget {
  const MemberSelector({
    super.key,
    required this.members,
    required this.multiSelect,
    required this.selectedIds,
    required this.onChanged,
  });

  final List<Member> members;
  final bool multiSelect;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;

  static const _avatarRadius = 18.0;
  static const _slotDiameter = (_avatarRadius + 2) * 2;

  void _handleTap(String memberId) {
    if (multiSelect) {
      final next = Set<String>.from(selectedIds);
      if (!next.remove(memberId)) next.add(memberId);
      onChanged(next);
    } else {
      if (selectedIds.contains(memberId)) return;
      onChanged({memberId});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        for (final member in members)
          GestureDetector(
            onTap: () => _handleTap(member.id),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: _slotDiameter,
                  height: _slotDiameter,
                  child: Center(
                    child: Avatar(
                      name: member.name,
                      radius: _avatarRadius,
                      ringColor: selectedIds.contains(member.id)
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(member.name, style: theme.textTheme.muted),
              ],
            ),
          ),
      ],
    );
  }
}
