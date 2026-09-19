import 'package:flutter/material.dart';

import 'package:split/utils/formatting.dart';

/// A named, colored, optionally-iconed category a group defines once and
/// reuses across its expenses.
@immutable
class Label {
  const Label({
    required this.id,
    required this.groupId,
    required this.name,
    required this.color,
    this.icon,
  });

  final String id;
  final String groupId;
  final String name;
  final Color color;
  final String? icon;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Label && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory Label.fromJson(Map<String, dynamic> json) => Label(
    id: json['id'] as String,
    groupId: json['groupId'] as String,
    name: json['name'] as String,
    color: colorFromHex(json['color'] as String?) ?? defaultLabelColor,
    icon: json['icon'] as String?,
  );
}

class CreateLabelInput {
  const CreateLabelInput({required this.name, required this.color, this.icon});

  final String name;
  final Color color;
  final String? icon;

  Map<String, dynamic> toJson() => {
    'name': name,
    'color': hexFromColor(color),
    if (icon != null) 'icon': icon,
  };
}
