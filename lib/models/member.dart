import 'package:flutter/foundation.dart';

/// A person belonging to one or more [Group]s.
@immutable
class Member {
  const Member({required this.id, required this.name});

  final String id;
  final String name;

  /// The name the backend gives a freshly-provisioned account before the
  /// member has chosen one (see `GET /members/me` in docs/auth/backend.md).
  static const placeholderName = 'New member';

  factory Member.fromJson(Map<String, dynamic> json) =>
      Member(id: json['id'] as String, name: json['name'] as String);
}
