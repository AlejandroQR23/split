import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:split/widgets/navigation/screen_header.dart';

/// Placeholder for the balances tab. Will eventually show each person's net
/// balance (Phase 6) and let you drill into a specific balance's breakdown.
class BalanceListScreen extends StatelessWidget {
  const BalanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScreenHeader(title: 'Balances', isMainScreen: true),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () => context.go('/balances/placeholder'),
              child: const Text('Balances screen placeholder'),
            ),
          ),
        ),
      ],
    );
  }
}
