import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/utils/network_exception.dart';

/// Centered destructive-styled error message for a failed [AsyncValue].
class AsyncErrorText extends StatelessWidget {
  const AsyncErrorText({super.key, required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final errorMessage = error is NetworkException
        ? (error as NetworkException).error.message
        : error.toString();

    return Center(
      child: Text(
        'Error: $errorMessage',
        style: theme.textTheme.p.copyWith(color: theme.colorScheme.destructive),
      ),
    );
  }
}
