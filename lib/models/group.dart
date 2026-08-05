import 'package:flutter/foundation.dart';

import 'member.dart';

/// A group of [Member]s who split expenses together.
@immutable
class Group {
  const Group({required this.id, required this.name, required this.members});

  final String id;
  final String name;
  final List<Member> members;
}
