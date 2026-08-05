import 'package:flutter/foundation.dart';

/// A person belonging to one or more [Group]s.
@immutable
class Member {
  const Member({required this.id, required this.name});

  final String id;
  final String name;
}
