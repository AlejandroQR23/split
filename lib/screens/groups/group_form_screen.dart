import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/utils/network_exception.dart';

import '../../theme/app_colors.dart';
import '../../widgets/navigation/screen_header.dart';

/// Shared state/behavior for [CreateGroupScreen] and [EditGroupScreen]: the
/// form key, the dynamic member-name controllers, the submitting flag, and
/// the validate → extract → submit → error-toast flow. Subclasses only
/// supply the error toast title and the actual persistence call.
abstract class GroupFormScreenState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> {
  final formKey = GlobalKey<ShadFormState>();
  final List<TextEditingController> memberControllers = [];
  bool isSubmitting = false;

  /// Shown as the destructive toast title when [onSubmit] throws.
  String get errorToastTitle;

  /// Performs the actual mutation for the validated [name] and the trimmed,
  /// non-empty [newMemberNames]. Responsible for its own success behavior
  /// (toast/pop) — [handleSubmit] only reacts to a thrown error.
  Future<void> onSubmit(String name, List<String> newMemberNames);

  @override
  void dispose() {
    for (final controller in memberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void addMemberField() {
    setState(() => memberControllers.add(TextEditingController()));
  }

  void removeMemberField(int index) {
    setState(() => memberControllers.removeAt(index).dispose());
  }

  Future<void> handleSubmit() async {
    final formOk = formKey.currentState?.saveAndValidate() ?? false;
    if (!formOk) return;

    final name = formKey.currentState!.value['name'] as String;
    final newMemberNames = memberControllers
        .map((controller) => controller.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    setState(() => isSubmitting = true);
    try {
      await onSubmit(name, newMemberNames);
    } catch (error) {
      if (!mounted) return;

      final errorMessage = error is NetworkException
          ? error.error.message
          : error.toString();

      setState(() => isSubmitting = false);
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: Text(errorToastTitle),
          description: Text(errorMessage),
        ),
      );
    }
  }

  Widget buildScreen({required String title, required Widget body}) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: title),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
