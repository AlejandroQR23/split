import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:split/api/http_client.dart';
import 'package:split/providers/auth_provider.dart';

final httpClientProvider = Provider<http.BaseClient>((ref) {
  final innerClient = http.Client();

  final authRepository = ref.watch(authRepositoryProvider);

  final httpClient = HttpClient(innerClient, authRepository);

  ref.onDispose(() {
    httpClient.close();
  });

  return httpClient;
});
