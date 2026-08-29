import 'package:flutter/foundation.dart';

@immutable
class Transfer {
  const Transfer({required this.from, required this.to, required this.amount});

  final String from;
  final String to;
  final double amount;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transfer &&
        other.from == from &&
        other.to == to &&
        other.amount == amount;
  }

  @override
  int get hashCode => Object.hash(from, to, amount);

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      from: json['from'] as String,
      to: json['to'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
