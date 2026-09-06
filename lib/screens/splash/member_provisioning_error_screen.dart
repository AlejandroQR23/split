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
              'Could not set up your account. Check your connection and try again.',
              style: theme.textTheme.p,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ShadButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
