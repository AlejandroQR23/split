import 'package:flutter/foundation.dart';

import 'member.dart';

/// One other member's net balance with the current user, aggregated across
/// every expense they share. Positive [netAmount] means they owe the
/// current user; negative means the current user owes them.
@immutable
class Settlement {
  const Settlement({
    required this.member,
    required this.netAmount,
    required this.summary,
  });

  final Member member;
  final double netAmount;
  final String summary;
}
