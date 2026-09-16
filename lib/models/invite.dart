import 'package:flutter/foundation.dart';

@immutable
class InvitePreview {
  const InvitePreview({
    required this.memberName,
    required this.expired,
    required this.claimed,
  });

  final String memberName;
  final bool expired;
  final bool claimed;

  bool get isValid => !expired && !claimed;

  factory InvitePreview.fromJson(Map<String, dynamic> json) => InvitePreview(
    memberName: json['memberName'] as String,
    expired: json['expired'] as bool,
    claimed: json['claimed'] as bool,
  );
}

@immutable
class GeneratedInvite {
  const GeneratedInvite({required this.inviteToken, required this.expiresAt});

  final String inviteToken;
  final DateTime expiresAt;

  factory GeneratedInvite.fromJson(Map<String, dynamic> json) =>
      GeneratedInvite(
        inviteToken: json['inviteToken'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );
}
