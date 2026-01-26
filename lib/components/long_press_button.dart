import 'dart:async';

import 'package:evostream/utils/color_extension.dart';
import 'package:evostream/utils/global_utils.dart';
import 'package:flutter/material.dart';

class LongPressButton extends StatefulWidget {
  const LongPressButton({
    required this.label,
    required this.icon,
    required this.onLongPress,
    this.color,
    this.duration = const Duration(seconds: 2),
    this.onCancel,
    super.key,
  });
  final Duration duration;
  final Color? color;
  final String label;
  final IconData icon;
  final void Function() onLongPress;
  final void Function()? onCancel;

  @override
  State<LongPressButton> createState() => _LongPressButtonState();
}

class _LongPressButtonState extends State<LongPressButton> {
  Timer? timer;
  double beginValue = 0;
  double endValue = 0;
  bool animate = false;
  int dummyCount = 0;
  bool duringTap = false;
  void cancelTap() {
    duringTap = false;
    if (timer != null) {
      widget.onCancel?.call();
    }
    timer?.cancel();
    timer = null;
    setState(() {
      dummyCount++;
      beginValue = 0;
      endValue = 0;
      animate = false;
    });
  }

  @override
  dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color color = widget.color ?? scheme.primary;
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          duringTap = true;
          beginValue = 0;
          endValue = 1;
          animate = true;
        });
        timer = Timer(
          widget.duration,
          () {
            widget.onLongPress();
            timer = null;
          },
        );
      },
      onTapCancel: cancelTap,
      onTapUp: (_) {
        cancelTap();
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.square(
                dimension: 100,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: beginValue, end: endValue),
                  duration: animate ? widget.duration : Duration.zero,
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      color: color,
                      backgroundColor: Colors.transparent,
                      strokeWidth: 2,
                      value: value,
                      strokeAlign: BorderSide.strokeAlignInside,
                    );
                  },
                ),
              ),
              AnimatedContainer(
                duration: DefDurations.short,
                width: animate ? 80 : 60,
                height: animate ? 80 : 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: animate
                      ? null
                      : Border.all(color: color.withO(.2), width: 2),
                  color: (animate ? color.withO(.2) : Colors.transparent),
                ),
                child: Icon(
                  widget.icon,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
