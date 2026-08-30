import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/member.dart';
import '../../theme/app_colors.dart';
import '../shared/avatar.dart';

const _avatarOuterDiameter = 32.0;
const _avatarStep = 18.0;

class AvatarStack extends StatelessWidget {
  const AvatarStack({super.key, required this.members});

  final List<Member> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    final theme = ShadTheme.of(context);
    final width = _avatarOuterDiameter + _avatarStep * (members.length - 1);

    return SizedBox(
      width: width,
      height: _avatarOuterDiameter,
      child: Stack(
        children: [
          for (var i = 0; i < members.length; i++)
            Positioned(
              left: i * _avatarStep,
              child: Avatar(
                name: members[i].name,
                radius: _avatarOuterDiameter / 2 - 2,
                textStyle: theme.textTheme.small,
                ringColor: AppColors.background,
              ),
            ),
        ],
      ),
    );
  }
}
