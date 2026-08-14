import 'package:flutter/material.dart';
import 'package:split/widgets/navigation/screen_header.dart';

class GroupDetailsScreen extends StatelessWidget {
  final String groupId;

  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScreenHeader(title: 'Group Details'),
        Center(child: Text('Group Details for ID: $groupId')),
      ],
    );
  }
}
