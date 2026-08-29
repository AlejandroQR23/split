import 'package:flutter/foundation.dart';

import 'member.dart';

/// A group of [Member]s who split expenses together.
@immutable
class Group {
  const Group({required this.id, required this.name, required this.members});

  final String id;
  final String name;
  final List<Member> members;

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json['id'] as String,
    name: json['name'] as String,
    members: (json['members'] as List<dynamic>)
        .map(
          (memberJson) => Member.fromJson(memberJson as Map<String, dynamic>),
        )
        .toList(),
  );
}

class CreateGroupInput {
  const CreateGroupInput({required this.name, required this.memberIds});

  final String name;
  final List<String> memberIds;

  Map<String, dynamic> toJson() => {'name': name, 'memberIds': memberIds};
}
