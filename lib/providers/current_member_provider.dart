import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/models/member.dart';
import 'package:split/providers/auth_provider.dart';
import 'package:split/providers/member_provider.dart';

/// The signed-in user's backend `Member`, provisioned via `GET /members/me`
/// on first call after sign-in. Every other authenticated route 401s with
/// `member_not_linked` until this has resolved at least once, so this
/// provider is what the app gates on before showing any signed-in screen.
/// Resolves to null while signed out — there's no Member to fetch.
final currentMemberProvider = FutureProvider<Member?>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return null;

  return ref.watch(memberRepositoryProvider).fetchMe();
});
