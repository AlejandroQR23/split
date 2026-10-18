import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MemberProvisioningErrorScreen extends StatelessWidget {
  const MemberProvisioningErrorScreen({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ColoredBox(
      color: theme.colorScheme.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No se pudo configurar tu cuenta. Revisa tu conexión e intenta de nuevo.',
              style: theme.textTheme.p,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ShadButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
