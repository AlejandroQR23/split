import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:split/models/member.dart';
import 'package:split/providers/invite_provider.dart';
import 'package:split/utils/network_exception.dart';

/// Generates a fresh invite link for [member] (a ghost) and hands it to the
/// native share sheet. The two entry points the design calls for — the
/// group member list's Invite button, and a pending-settlement card's
/// Invite action for a ghost counterparty — both funnel into this same
/// helper so there's one implementation, not two.
Future<void> generateAndShareInvite(
  BuildContext context,
  WidgetRef ref,
  Member member,
) async {
  try {
    final invite = await ref
        .read(inviteRepositoryProvider)
        .generateInvite(member.id);
    if (!context.mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Join ${member.name} on Split: splitapp://invite/${invite.inviteToken}',
      ),
    );
  } catch (error) {
    if (!context.mounted) return;
    final message = error is NetworkException
        ? error.error.message
        : error.toString();
    ShadToaster.of(context).show(
      ShadToast.destructive(
        title: const Text('Could not create invite'),
        description: Text(message),
      ),
    );
  }
}
