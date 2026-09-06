import 'package:flutter/widgets.dart';

/// Animates a numeric amount by counting up/down to its new value whenever
/// [amount] changes, instead of snapping straight to it.
class AnimatedAmountText extends StatelessWidget {
  const AnimatedAmountText({
    super.key,
    required this.amount,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 700),
  });

  final double amount;
  final String Function(double amount) formatter;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(formatter(value), style: style);
      },
    );
  }
}
