import 'package:evostream/components/circle_box.dart';
import 'package:evostream/components/def_button.dart';
import 'package:evostream/models/workout/tree_line_part_painter.dart';
import 'package:evostream/models/workout/workout.dart';
import 'package:evostream/models/workout/workout_controller.dart';
import 'package:evostream/models/workout/workout_editor_screen.dart';
import 'package:evostream/models/workout/workout_part_widget.dart';
import 'package:evostream/services/sound_service.dart';
import 'package:evostream/utils/color_extension.dart';
import 'package:evostream/utils/duration_Extension.dart';
import 'package:evostream/utils/global_utils.dart';
import 'package:evostream/utils/integer_extension.dart';
import 'package:evostream/utils/list_extension.dart';
import 'package:evostream/utils/text_style_extension.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Workout initialWorkout = Workout(
      name: 'Sample',
      parts: [
        Prepare(5.s),
        Work(5.s),
        Rest(),
        WorkoutPartGroup(
          repeat: 3,
          rest: Rest(5.s),
        ),
        Work(3.s),
        Rest(3.s),
        WorkoutPartGroup(
          repeat: 3,
          rest: Rest(5.s),
        ),
        Work(3.s),
        WorkoutPartGroup(
          repeat: 2,
          rest: Rest(5.s),
        ),
        Work(3.s),
        WorkoutPartGroupEnd(),
        Rest(),
        Work(3.s),
        WorkoutPartGroupEnd(),
        Rest(3.s),
        Work(3.s),
        WorkoutPartGroupEnd(),
        Rest(10.s),
        Work(5.s),
        Finish(),
      ],
    );

    return Scaffold(
      body: Center(
        child: Row(
          spacing: 8,
          children: [
            DefButton.flat(
              onPressed: () async {
                Workout? newWorkout = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return WorkoutEditorScreen();
                    },
                  ),
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return WorkoutScreen(
                        workout: newWorkout ?? initialWorkout,
                      );
                    },
                  ),
                );
              },
              label: 'Indítás',
            ),
            DefButton.tonal(
              onPressed: () async {
                SoundService().startBeep();
              },
              label: 'start',
            ),
            DefButton.tonal(
              onPressed: () async {
                SoundService().endBeep();
              },
              label: 'end',
            ),
            DefButton.tonal(
              onPressed: () async {
                SoundService().finishBeep();
              },
              label: 'finish',
            ),
            DefButton.tonal(
              onPressed: () async {
                SoundService().countDown();
              },
              label: 'cd beep',
            ),
          ],
        ),
      ),
    );
  }
}

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
    controller = WorkoutController(
      workout: widget.workout,
    );
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: WorkoutDisplay(controller: controller),
                    ),
                    SizedBox(
                      height: 64,
                    ),
                  ],
                ),
                Align(
                  alignment: .bottomCenter,
                  child: WorkoutList(
                    controller: controller,
                    maxHeight: constraints.maxHeight,
                    collapsible: true,
                  ),
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: WorkoutDisplay(controller: controller),
              ),
              SizedBox(
                width: 300,
                child: WorkoutList(
                  controller: controller,
                  maxHeight: constraints.maxHeight,
                  collapsible: false,
                ),
              ),
            ],
          );
        },
      ),
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

class WorkoutList extends StatefulWidget {
  const WorkoutList({
    required this.controller,
    required this.maxHeight,
    required this.collapsible,
    super.key,
  });

  final WorkoutController controller;
  final double maxHeight;
  final bool collapsible;

  @override
  State<WorkoutList> createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  bool collapsed = true;
  bool get sureCollapsed => widget.collapsible && collapsed;

  @override
  initState() {
    super.initState();
    widget.controller.stateNotifier.addListener(collapse);
  }

  void collapse() {
    if (widget.collapsible && !collapsed) {
      setState(() {
        collapsed = true;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.stateNotifier.removeListener(collapse);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    int indent = 0;
    for (var i = 0; i < widget.controller.workout.parts.length; i++) {
      final part = widget.controller.workout.parts[i];
      final nextPart = widget.controller.workout.parts.tryGet(i + 1);
      bool isLast = nextPart == null || nextPart is WorkoutPartGroupEnd;
      children.add(
        WorkoutPartWidget.from(
          part,
          indent: indent,
          controller: widget.controller,
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
    return AnimatedContainer(
      duration: 300.ms,
      height: sureCollapsed ? 64 : widget.maxHeight,
      child: Stack(
        fit: .expand,
        children: [
          ValueListenableBuilder(
            valueListenable: widget.controller.stateNotifier,
            builder: (context, value, child) {
              return AnimatedContainer(
                duration: 300.ms,
                color: widget.controller.current?.getColor(),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Material(
              clipBehavior: .antiAlias,
              borderRadius: DefRadius.medium,
              color: Colors.grey.shade900,
              child: Column(
                children: [
                  Container(
                    height: 48,
                    color: Colors.black,
                    child: Row(
                      spacing: 8,
                      children: [
                        AspectRatio(
                          aspectRatio: 0.5,
                          child: Stack(
                            fit: .expand,
                            children: [
                              if (!sureCollapsed)
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
                            widget.controller.workout.name,
                            style: DefText.l.bold.c(Colors.grey.shade300),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            spacing: 8,
                            children: [
                              if (widget.collapsible)
                                AnimatedRotation(
                                  duration: 300.ms,
                                  turns: sureCollapsed ? 0.5 : 0,
                                  child: DefButton.icon(
                                    icon: Icons.expand_more,
                                    color: Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        collapsed = !collapsed;
                                      });
                                    },
                                  ),
                                ),
                              DefButton.icon(
                                icon: Icons.close,
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
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
            ),
          ),
        ],
      ),
    );
  }
}
