import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/providers/http_provider.dart';
import 'package:split/repositories/member_repository.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  final client = ref.watch(httpClientProvider);

  return MemberRepositoryImpl(client);
});
