import 'package:flutter/material.dart';

class Shimmer extends StatefulWidget {
  const Shimmer({
    required this.child,
    required this.loading,
    this.ignoreWhenLoading = false,
    super.key,
  });

  final Widget child;
  final bool loading;
  final bool ignoreWhenLoading;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (widget.loading) {
      start();
    }
  }

  void start() {
    controller
      ..forward()
      ..addListener(controllerListener);
  }

  void stop() {
    controller
      ..stop()
      ..removeListener(controllerListener);
  }

  void controllerListener() {
    if (controller.isCompleted) {
      controller.reverse().then((_) => controller.forward());
    }
  }

  @override
  void didUpdateWidget(covariant Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loading != widget.loading) {
      if (widget.loading) {
        start();
      } else {
        stop();
      }
    }
  }

  @override
  void dispose() {
    stop();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.ignoreWhenLoading && widget.loading,
      child: AnimatedBuilder(
        animation: controller,
        child: widget.child,
        builder: (context, child) {
          return Opacity(
            opacity: widget.loading ? (controller.value / 2).clamp(.1, .4) : 1,
            child: child,
          );
        },
      ),
    );
  }
}
