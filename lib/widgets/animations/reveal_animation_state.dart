import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

///
/// A base class for widgets that want to animate the reveal of a list of items when the widget is first built or when the list of items changes.
///
/// T is the type of the items in the list, and W is the type of the widget that extends this class.
///
/// T must implement equality (`==`) and `hashCode` for the animation to work correctly when the list of items changes.
///
abstract class RevealAnimationState<W extends StatefulWidget, T>
    extends State<W>
    with SingleTickerProviderStateMixin {
  RevealAnimationState({
    this.animationDuration = const Duration(milliseconds: 500),
  });

  final Duration animationDuration;

  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: animationDuration,
  );

  List<T> getItems(W widget);

  @override
  void initState() {
    super.initState();
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);

    final List<T> items = getItems(widget);
    final List<T> oldItems = getItems(oldWidget);

    if (!ListEquality<T>().equals(items, oldItems)) {
      animationController.reset();
      animationController.forward();
    }
  }
}
