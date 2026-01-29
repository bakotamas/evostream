import 'package:evostream/components/circle_box.dart';
import 'package:evostream/components/def_button.dart';
import 'package:evostream/models/workout/tree_line_part_painter.dart';
import 'package:evostream/models/workout/workout.dart';
import 'package:evostream/models/workout/workout_controller.dart';
import 'package:evostream/models/workout/workout_part_widget.dart';
import 'package:evostream/utils/color_extension.dart';
import 'package:evostream/utils/duration_Extension.dart';
import 'package:evostream/utils/global_utils.dart';
import 'package:evostream/utils/integer_extension.dart';
import 'package:evostream/utils/list_extension.dart';
import 'package:evostream/utils/text_style_extension.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({
    required this.workout,
    super.key,
  });

  final Workout workout;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late final WorkoutController controller;
  bool collapsed = true;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    controller = WorkoutController(
      workout: widget.workout,
    );
  }

  @override
  dispose() {
    WakelockPlus.disable();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: WorkoutList(controller: controller),
      body: WorkoutDisplay(controller: controller),
    );
  }
}

class WorkoutDisplay extends StatefulWidget {
  const WorkoutDisplay({
    required this.controller,
    super.key,
  });

  final WorkoutController controller;

  @override
  State<WorkoutDisplay> createState() => _WorkoutDisplayState();
}

class _WorkoutDisplayState extends State<WorkoutDisplay> {
  Color? color;
  String? title;
  Duration? duration;

  @override
  void initState() {
    super.initState();
    update();
    widget.controller.stateNotifier.addListener(update);
  }

  void update() {
    Scaffold.of(context).closeDrawer();
    setState(() {
      color = widget.controller.current?.getColor();
      title = widget.controller.current?.getName();
      duration = widget.controller.current?.duration;
    });
  }

  @override
  void dispose() {
    widget.controller.stateNotifier.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<StackFrame> groupStack = widget.controller.groupStack;
    Color color = this.color ?? Colors.grey;
    Color dark5 = color.darken(5);
    Color dark25 = color.darken(25);
    Color dark50 = color.darken(50);

    return AnimatedContainer(
      duration: 300.ms,
      color: color,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                DefButton.icon(
                  icon: Icons.menu,
                  color: dark50,
                  type: .tonal,
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                DefButton.icon(
                  icon: Icons.close,
                  type: .tonal,
                  color: dark50,
                  onPressed: Navigator.of(context).pop,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: groupStack.isNotEmpty
                ? Wrap(
                    alignment: .center,
                    runAlignment: .center,
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      ...widget.controller.groupStack
                          .sublist(0, widget.controller.groupStack.length - 1)
                          .map((e) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: DefRadius.standard,
                                border: Border.all(width: 1, color: dark5),
                              ),
                              child: Text(
                                '${e.iterator + 1}/${e.group.repeat}',
                                style: DefText.s.semiBold.c(dark25),
                              ),
                            );
                          }),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: DefRadius.standard,
                          border: Border.all(width: 1, color: dark5),
                          color: dark5,
                        ),
                        child: Text(
                          '${groupStack.last.iterator + 1}/${groupStack.last.group.repeat}',
                          style: DefText.s.semiBold.c(dark50),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
          Expanded(
            child: Center(
              child: SizedBox.square(
                dimension: 240,
                child: Stack(
                  fit: .expand,
                  alignment: .center,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: widget.controller.tickNotifier,
                      builder: (context, value, child) {
                        return CircularProgressIndicator(
                          value: widget.controller.progress,
                          color: dark25,
                          backgroundColor: dark5,
                          strokeCap: .round,
                          strokeWidth: 4,
                          trackGap: 4,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        mainAxisAlignment: .center,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: widget.controller.tickNotifier,
                            builder: (context, value, child) {
                              return Text(
                                duration != null
                                    ? (duration! -
                                              widget.controller.currentElapsed)
                                          .format(.ms)
                                    : widget.controller.currentElapsed.format(
                                        .ms,
                                      ),
                                style: DefText.n
                                    .fs(56)
                                    .extraBold
                                    .tabular
                                    .c(duration == null ? dark5 : dark50),
                              );
                            },
                          ),
                          Material(
                            borderRadius: DefRadius.medium,
                            color: dark5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                duration != null
                                    ? duration!.formatSecondsOrMs()
                                    : 'Indeterminate',
                                style: DefText.n.extraBold.c(dark50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (duration == null)
                      Align(
                        alignment: .bottomCenter,
                        child: DefButton.surface(
                          label: widget.controller.current is Finish
                              ? 'Exit'
                              : 'Next',
                          size: .medium,
                          onPressed: widget.controller.current is Finish
                              ? () {
                                  Navigator.of(context).pop();
                                }
                              : widget.controller.next,
                          color: dark25,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            title?.toUpperCase() ?? '',
            style: DefText.n.fs(36).extraBold.c(dark50),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: dark5,
                borderRadius: DefRadius.medium,
              ),
              child: Row(
                spacing: 8,
                mainAxisAlignment: .center,
                children: [
                  DefButton.icon(
                    type: .surface,
                    onPressed: widget.controller.previous,
                    icon: Icons.skip_previous,
                    color: dark25,
                  ),
                  widget.controller.running
                      ? DefButton.icon(
                          type: .surface,
                          size: .fab,
                          onPressed: widget.controller.pause,
                          icon: Icons.pause,
                          color: dark25,
                        )
                      : DefButton.icon(
                          type: .surface,
                          size: .fab,
                          onPressed: widget.controller.play,
                          icon: Icons.play_arrow,
                          color: dark25,
                        ),
                  DefButton.icon(
                    type: .surface,
                    onPressed: widget.controller.next,
                    icon: Icons.skip_next,
                    color: dark25,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutList extends StatelessWidget {
  const WorkoutList({
    required this.controller,
    super.key,
  });

  final WorkoutController controller;

  @override
  Widget build(BuildContext context) {
    Color bg =
        controller.current?.getColor().withLightness(20) ??
        Colors.grey.shade900;
    List<Widget> children = [];
    int indent = 0;
    for (var i = 0; i < controller.workout.parts.length; i++) {
      final part = controller.workout.parts[i];
      final nextPart = controller.workout.parts.tryGet(i + 1);
      bool isLast = nextPart == null || nextPart is WorkoutPartGroupEnd;
      children.add(
        WorkoutPartWidget.from(
          part,
          indent: indent,
          controller: controller,
          treeLineType: isLast ? TreeLineType.endNode : TreeLineType.node,
        ),
      );
      if (part is WorkoutPartGroup) {
        indent++;
      }
      if (part is WorkoutPartGroupEnd) {
        indent--;
      }
    }
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      backgroundColor: bg,
      child: Column(
        children: [
          Container(
            height: 48,
            color: bg,
            child: Row(
              spacing: 8,
              children: [
                AspectRatio(
                  aspectRatio: 0.5,
                  child: Stack(
                    fit: .expand,
                    children: [
                      CustomPaint(
                        painter: TreeLinePainter(
                          type: .groupNode,
                        ),
                      ),
                      Center(
                        child: CircleBox(
                          size: 8,
                          borderColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    controller.workout.name,
                    style: DefText.l.bold.c(Colors.grey.shade300),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
