import 'package:flutter/foundation.dart';

/// A person belonging to one or more [Group]s.
@immutable
class Member {
  const Member({required this.id, required this.name});

  final String id;
  final String name;

  factory Member.fromJson(Map<String, dynamic> json) =>
      Member(id: json['id'] as String, name: json['name'] as String);
}
