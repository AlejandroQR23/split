import 'package:flutter/material.dart';

class StaggeredRevealItems extends AnimatedWidget {
  const StaggeredRevealItems({
    super.key,
    required this.children,
    required Animation<double> animation,
    required this.spacing,
  }) : super(listenable: animation);

  final List<Widget> children;
  final double spacing;

  Widget _buildStaggeredItem(int index) {
    final interval = Interval(
      index / children.length,
      (index + 1) / children.length,
    );

    final animationValue = (listenable as Animation<double>).value;
    final intervalTransform = interval.transform(animationValue);

    return Opacity(
      opacity: intervalTransform,
      child: Transform.translate(
        offset: Offset(0, (1 - intervalTransform) * 20),
        child: children[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing,
      children: [
        for (var i = 0; i < children.length; i++) _buildStaggeredItem(i),
      ],
    );
  }
}
