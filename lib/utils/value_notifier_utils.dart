import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TickNotifier extends ValueNotifier<bool> {
  TickNotifier() : super(true);

  void tick() {
    value = !value;
  }
}

class BoolValueNotifier extends ValueNotifier<bool> {
  BoolValueNotifier(super.value);

  void toggle() {
    value = !value;
  }

  void setFalse() {
    value = false;
  }

  void setTrue() {
    value = true;
  }

  bool get isTrue => value;
  bool get isFalse => !value;
}

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  const ValueListenableBuilder2({
    required this.first,
    required this.second,
    required this.builder,
    this.child,
    super.key,
  });

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<A>(
    valueListenable: first,
    builder: (context, a, child) {
      return ValueListenableBuilder<B>(
        valueListenable: second,
        builder: (context, b, child) {
          return builder(context, a, b, child);
        },
        child: child,
      );
    },
    child: child,
  );
}
