import 'package:collection/collection.dart';
import 'package:evostream/components/circle_box.dart';
import 'package:evostream/components/def_button.dart';
import 'package:evostream/models/workout/tree_line_part_painter.dart';
import 'package:evostream/models/workout/workout.dart';
import 'package:evostream/models/workout/workout_controller.dart';
import 'package:evostream/utils/duration_Extension.dart';
import 'package:evostream/utils/global_utils.dart';
import 'package:evostream/utils/text_style_extension.dart';
import 'package:flutter/material.dart';

abstract class WorkoutPartWidget extends StatefulWidget {
  final WorkoutPart part;
  final WorkoutController controller;
  final int indent;
  final TreeLineType treeLineType;

  const WorkoutPartWidget({
    required this.part,
    required this.controller,
    required this.indent,
    required this.treeLineType,
    super.key,
  });

  factory WorkoutPartWidget.from(
    WorkoutPart part, {
    required WorkoutController controller,
    required int indent,
    required TreeLineType treeLineType,
  }) {
    return switch (part) {
      SimpleWorkoutPart p => SimpleWorkoutPartWidget(
        part: p,
        controller: controller,
        indent: indent,
        treeLineType: treeLineType,
      ),
      WorkoutPartGroup g => WorkoutPartGroupWidget(
        part: g,
        controller: controller,
        indent: indent,
        treeLineType: treeLineType,
      ),
      WorkoutPartGroupEnd g => WorkoutPartGroupEndWidget(
        part: g,
        controller: controller,
        indent: indent,
        treeLineType: treeLineType,
      ),
    };
  }
}

class SimpleWorkoutPartWidget extends WorkoutPartWidget {
  const SimpleWorkoutPartWidget({
    required SimpleWorkoutPart super.part,
    required super.controller,
    required super.indent,
    required super.treeLineType,
    super.key,
  });

  @override
  State<SimpleWorkoutPartWidget> createState() =>
      _SimpleWorkoutPartWidgetState();
}

class _SimpleWorkoutPartWidgetState extends State<SimpleWorkoutPartWidget> {
  late bool isActive = false;

  @override
  initState() {
    super.initState();
    update();
    widget.controller.stateNotifier.addListener(update);
  }

  void update() {
    bool nowActive = widget.controller.current == widget.part;
    if (isActive != nowActive) {
      setState(() {
        isActive = nowActive;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.stateNotifier.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SimpleWorkoutPart part = widget.part as SimpleWorkoutPart;

    List<TreeLineType> treeLineTypes = List.generate(
      widget.indent,
      (_) => TreeLineType.line,
    )..add(widget.treeLineType);

    return InkWell(
      onTap: () {
        widget.controller.move(part);
      },
      child: Container(
        height: 48,
        color: isActive ? Colors.white12 : null,
        child: Row(
          crossAxisAlignment: .stretch,
          children: [
            ...treeLineTypes.map((e) {
              return AspectRatio(
                aspectRatio: 0.5,
                child: CustomPaint(
                  painter: TreeLinePainter(type: e),
                ),
              );
            }),
            Expanded(
              child: Row(
                spacing: 8,
                children: [
                  AspectRatio(
                    aspectRatio: 0.5,
                    child: Center(
                      child: CircleBox(
                        size: 16,
                        color: part.getColor(),
                      ),
                    ),
                  ),
                  Container(
                    padding: const .symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      part.duration?.formatSecondsOrMs() ?? '∞',
                      style: DefText.n.semiBold.c(Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      part.getName().toUpperCase(),
                      style: DefText.n.c(Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutPartGroupWidget extends WorkoutPartWidget {
  const WorkoutPartGroupWidget({
    required WorkoutPartGroup super.part,
    required super.controller,
    required super.indent,
    required super.treeLineType,
    super.key,
  });

  @override
  State<WorkoutPartGroupWidget> createState() => _WorkoutPartGroupWidgetState();
}

class _WorkoutPartGroupWidgetState extends State<WorkoutPartGroupWidget> {
  int? currentIteration;

  @override
  initState() {
    super.initState();
    update();
    widget.controller.stateNotifier.addListener(update);
  }

  void update() {
    StackFrame? frame = widget.controller.groupStack.firstWhereOrNull(
      (element) => element.group == widget.part,
    );
    int? nowIteration = frame?.iterator;
    if (currentIteration != nowIteration) {
      setState(() {
        currentIteration = nowIteration;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.stateNotifier.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WorkoutPartGroup group = widget.part as WorkoutPartGroup;

    List<TreeLineType> treeLineTypes = List.generate(
      widget.indent,
      (_) => TreeLineType.line,
    )..add(widget.treeLineType);

    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          ...treeLineTypes.map((e) {
            return AspectRatio(
              aspectRatio: 0.5,
              child: CustomPaint(
                painter: TreeLinePainter(type: e),
              ),
            );
          }),
          Expanded(
            child: Row(
              spacing: 8,
              children: [
                AspectRatio(
                  aspectRatio: 0.5,
                  child: Stack(
                    fit: .expand,
                    children: [
                      CustomPaint(
                        painter: TreeLinePainter(type: .groupNode),
                      ),
                      const Center(
                        child: CircleBox(
                          size: 16,
                          borderColor: Colors.white54,
                          borderWidth: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    '${group.repeat}x',
                    style: DefText.n.c(Colors.grey.shade300),
                  ),
                ),
                if (currentIteration != null)
                  Padding(
                    padding: const .symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        DefButton.icon(
                          icon: Icons.chevron_left,
                          size: .small,
                          color: Colors.white,
                          onPressed: () {
                            widget.controller.previousRound(group);
                          },
                          onLongPress: () {
                            widget.controller.previousRound(group, reset: true);
                          },
                        ),
                        Text(
                          '${currentIteration! + 1} / ${group.repeat}',
                          style: DefText.s.c(Colors.grey.shade300),
                        ),
                        DefButton.icon(
                          icon: Icons.chevron_right,
                          size: .small,
                          color: Colors.white,
                          onPressed: () {
                            widget.controller.nextRound(group);
                          },
                          onLongPress: () {
                            widget.controller.nextRound(group, reset: true);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutPartGroupEndWidget extends WorkoutPartWidget {
  const WorkoutPartGroupEndWidget({
    required WorkoutPartGroupEnd super.part,
    required super.controller,
    required super.indent,
    required super.treeLineType,
    super.key,
  });

  @override
  State<WorkoutPartGroupEndWidget> createState() =>
      _WorkoutPartGroupEndWidgetState();
}

class _WorkoutPartGroupEndWidgetState extends State<WorkoutPartGroupEndWidget> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
