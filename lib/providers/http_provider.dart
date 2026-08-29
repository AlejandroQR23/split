import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:split/api/http_client.dart';
import 'package:split/providers/current_user_provider.dart';

final httpClientProvider = Provider<http.BaseClient>((ref) {
  final innerClient = http.Client();

  final userId = ref.watch(currentUserProvider).id;

  final httpClient = HttpClient(innerClient, userId);

  ref.onDispose(() {
    httpClient.close();
  });

  return httpClient;
});
