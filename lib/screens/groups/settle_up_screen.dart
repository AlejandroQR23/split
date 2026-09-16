import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/providers/current_member_provider.dart';

import '../../models/member.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/groups_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/network_exception.dart';
import '../../widgets/shared/async_error_text.dart';
import '../../widgets/shared/avatar.dart';

/// Records that [fromMemberId] paid [toMemberId] back, reached by tapping a
/// pending [Transfer] the current user is a party to. [suggestedAmount]
/// prefills the form with that transfer's amount, but it stays editable so a
/// partial payment can be recorded too. Presented as a bottom sheet via
/// [showShadSheet] — it's a single amount field, too small to earn a screen
/// of its own.
class SettleUpScreen extends ConsumerStatefulWidget {
  const SettleUpScreen({
    super.key,
    required this.groupId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.suggestedAmount,
  });

  final String groupId;
  final String fromMemberId;
  final String toMemberId;
  final double suggestedAmount;

  @override
  ConsumerState<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends ConsumerState<SettleUpScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    final formOk = _formKey.currentState?.saveAndValidate() ?? false;
    if (!formOk) return;

    final amount = double.parse(
      _formKey.currentState!.value['amount'] as String,
    );

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(expensesProvider(widget.groupId).notifier)
          .settleUp(
            fromMemberId: widget.fromMemberId,
            toMemberId: widget.toMemberId,
            amount: amount,
          );
    } catch (error) {
      if (!mounted) return;

      final errorMessage = error is NetworkException
          ? error.error.message
          : error.toString();

      setState(() => _isSubmitting = false);
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Could not record payment'),
          description: Text(errorMessage),
        ),
      );
      return;
    }

    if (!mounted) return;
    ShadToaster.of(
      context,
    ).show(const ShadToast(title: Text('Payment recorded')));
    context.pop();
  }

  Widget _skeletonSheet(BuildContext context, Widget child) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ShadSheet(
      useSafeArea: false,
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset),
      title: const Text('Settle up'),
      child: SizedBox(height: 160, child: Center(child: child)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsResponse = ref.watch(groupsProvider);
    final currentUser = ref.watch(currentMemberProvider).value;
    final theme = ShadTheme.of(context);

    if (currentUser == null) return const SizedBox.shrink();

    return groupsResponse.when(
      skipError: true,
      loading: () => _skeletonSheet(
        context,
        CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
      error: (error, stackTrace) =>
          _skeletonSheet(context, AsyncErrorText(error: error)),
      data: (groups) {
        final group = groups.where((g) => g.id == widget.groupId).firstOrNull;
        if (group == null) {
          return _skeletonSheet(
            context,
            const AsyncErrorText(error: 'Group not found'),
          );
        }

        final fromMember = group.members
            .where((m) => m.id == widget.fromMemberId)
            .firstOrNull;
        final toMember = group.members
            .where((m) => m.id == widget.toMemberId)
            .firstOrNull;
        if (fromMember == null || toMember == null) {
          return _skeletonSheet(
            context,
            const AsyncErrorText(error: 'Member not found'),
          );
        }

        return _SettleUpForm(
          formKey: _formKey,
          isSubmitting: _isSubmitting,
          currentUser: currentUser,
          fromMember: fromMember,
          toMember: toMember,
          suggestedAmount: widget.suggestedAmount,
          onSubmit: _handleSubmit,
        );
      },
    );
  }
}

class _SettleUpForm extends StatelessWidget {
  const _SettleUpForm({
    required this.formKey,
    required this.isSubmitting,
    required this.currentUser,
    required this.fromMember,
    required this.toMember,
    required this.suggestedAmount,
    required this.onSubmit,
  });

  final GlobalKey<ShadFormState> formKey;
  final bool isSubmitting;
  final Member currentUser;
  final Member fromMember;
  final Member toMember;
  final double suggestedAmount;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final fromLabel = fromMember.id == currentUser.id ? 'You' : fromMember.name;
    final toLabel = toMember.id == currentUser.id ? 'You' : toMember.name;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ShadSheet(
      useSafeArea: false,
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset),
      title: const Text('Settle up'),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ShadButton(
            onPressed: isSubmitting ? null : onSubmit,
            child: isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Record payment'),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShadCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Avatar(
                  name: fromLabel,
                  backgroundColor: AppColors.primaryTint,
                  foregroundColor: theme.colorScheme.primary,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 16,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                Avatar(
                  name: toLabel,
                  backgroundColor: AppColors.primaryTint,
                  foregroundColor: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Text('$fromLabel pays $toLabel', style: theme.textTheme.large),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ShadForm(
            key: formKey,
            child: ShadInputFormField(
              id: 'amount',
              label: const Text('Amount'),
              placeholder: const Text('0.00'),
              initialValue: suggestedAmount.toStringAsFixed(2),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                final parsed = double.tryParse(v);
                if (parsed == null || parsed <= 0) {
                  return 'Enter an amount greater than 0';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
