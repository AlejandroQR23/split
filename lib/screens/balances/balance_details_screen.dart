import 'package:flutter/material.dart';
import 'package:split/widgets/navigation/screen_header.dart';

class BalanceDetailsScreen extends StatelessWidget {
  final String balanceId;

  const BalanceDetailsScreen({super.key, required this.balanceId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScreenHeader(title: 'Balance Details'),
        Center(child: Text('Balance Details for ID: $balanceId')),
      ],
    );
  }
}
