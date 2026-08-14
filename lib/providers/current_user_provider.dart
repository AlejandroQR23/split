import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/data/current_user.dart';
import 'package:split/models/member.dart';

final currentUserProvider = Provider<Member>((ref) => currentUser);
