import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:split/models/invite.dart';
import 'package:split/models/member.dart';

abstract class InviteRepository {
  /// `GET /invites/{token}` — public, no auth required. Returns `200` for
  /// any token ever issued, even if it's since expired or been claimed.
  /// `404 not_found` only for a token that was never issued.
  Future<InvitePreview> fetchPreview(String token);

  /// `POST /invites/{token}/claim` — links the ghost identity behind
  /// [token] to the caller's Firebase account, merging it into the
  /// caller's existing Member if they already have one. Must be called
  /// through the normal authenticated `HttpClient` — this needs a Firebase
  /// bearer (pre-existing or freshly minted post-sign-up), never the
  /// invite token itself.
  Future<Member> claimInvite(String token);

  /// `POST /members/{memberId}/invite` — (re)generates an invite token for
  /// a ghost member the caller shares a group with. Overwrites any
  /// previously issued token for that member.
  Future<GeneratedInvite> generateInvite(String memberId);
}

class InviteRepositoryImpl implements InviteRepository {
  InviteRepositoryImpl(this._client);

  final http.Client _client;

  @override
  Future<InvitePreview> fetchPreview(String token) async {
    final response = await _client.get(Uri.parse('invites/$token'));

    return InvitePreview.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<Member> claimInvite(String token) async {
    final response = await _client.post(Uri.parse('invites/$token/claim'));

    return Member.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<GeneratedInvite> generateInvite(String memberId) async {
    final response = await _client.post(
      Uri.parse('members/$memberId/invite'),
    );

    return GeneratedInvite.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
