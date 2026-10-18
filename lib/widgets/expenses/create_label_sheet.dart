import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/label.dart';
import '../../providers/labels_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/network_exception.dart';
import '../shared/sheet_content_spacer.dart';

const _iconChoices = [
  '🍕',
  '🚕',
  '🏠',
  '🎬',
  '🛒',
  '☕',
  '🎉',
  '✈️',
  '💊',
  '🎁',
  '🐾',
  '📚',
  '💡',
  '🚗',
  '🎮',
  '🧾',
];

/// Opens the inline label-creation sheet for [groupId] and returns the
/// created [Label], or null if the sheet was dismissed without creating one.
Future<Label?> showCreateLabelSheet(BuildContext context, String groupId) {
  return showShadSheet<Label>(
    context: context,
    useRootNavigator: true,
    builder: (context) => CreateLabelSheet(groupId: groupId),
  );
}

class CreateLabelSheet extends ConsumerStatefulWidget {
  const CreateLabelSheet({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<CreateLabelSheet> createState() => _CreateLabelSheetState();
}

class _CreateLabelSheetState extends ConsumerState<CreateLabelSheet> {
  final _formKey = GlobalKey<ShadFormState>();
  Color _color = AppColors.labelPalette.first;
  String? _icon = _iconChoices.first;
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    final formOk = _formKey.currentState?.saveAndValidate() ?? false;
    if (!formOk) return;

    final name = _formKey.currentState!.value['name'] as String;

    setState(() => _isSubmitting = true);
    try {
      final label = await ref
          .read(groupLabelsProvider(widget.groupId).notifier)
          .createLabel(
            CreateLabelInput(name: name, color: _color, icon: _icon),
          );
      if (!mounted) return;
      Navigator.of(context).pop(label);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final message = error is NetworkException
          ? error.error.message
          : error.toString();
      ShadToaster.of(
        context,
      ).show(
        ShadToast.destructive(
          title: const Text('No se pudo crear la etiqueta'),
          description: Text(message),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ShadSheet(
      useSafeArea: false,
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset),
      title: const Text('Nueva etiqueta'),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ShadButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primaryForeground,
                  ),
                )
              : const Text('Crear'),
        ),
      ],
      child: ShadForm(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadInputFormField(
              id: 'name',
              label: const Text('Nombre'),
              placeholder: const Text('Comida, Renta, Transporte…'),
              validator: (v) {
                if (v.trim().isEmpty) return 'Ingresa un nombre';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Color', style: theme.textTheme.muted),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final color in AppColors.labelPalette)
                  GestureDetector(
                    onTap: () => setState(() => _color = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == color
                              ? theme.colorScheme.foreground
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Ícono', style: theme.textTheme.muted),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final icon in _iconChoices)
                  GestureDetector(
                    onTap: () => setState(() => _icon = icon),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _icon == icon
                            ? theme.colorScheme.accent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
              ],
            ),
            sheetContentSpacer,
          ],
        ),
      ),
    );
  }
}
