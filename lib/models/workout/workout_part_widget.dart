import 'package:collection/collection.dart';
import 'package:evostream/components/circle_box.dart';
import 'package:evostream/models/workout/workout.dart';
import 'package:evostream/models/workout/workout_controller.dart';
import 'package:flutter/material.dart';

abstract class WorkoutPartWidget extends StatelessWidget {
  final WorkoutPart part;
  final WorkoutController controller;

  const WorkoutPartWidget({
    required this.part,
    required this.controller,
    super.key,
  });

  factory WorkoutPartWidget.from(
    WorkoutPart part, {
    required WorkoutController controller,
  }) {
    return switch (part) {
      SimpleWorkoutPart p => SimpleWorkoutPartWidget(
        part: p,
        controller: controller,
      ),
      WorkoutPartGroup g => WorkoutPartGroupWidget(
        part: g,
        controller: controller,
      ),
    };
  }

  factory WorkoutPartWidget.fromWorkout(
    Workout workout, {
    required WorkoutController controller,
  }) {
    return WorkoutPartWidget.from(
      workout.parts,
      controller: controller,
    );
  }
}

class SimpleWorkoutPartWidget extends WorkoutPartWidget {
  const SimpleWorkoutPartWidget({
    required SimpleWorkoutPart super.part,
    required super.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    SimpleWorkoutPart part = this.part as SimpleWorkoutPart;

    final isActive = controller.current == part;

    return Padding(
      padding: EdgeInsets.all(4),
      child: Row(
        spacing: 8,
        children: [
          CircleBox(
            size: 40,
            color: Colors.blueGrey.shade200,
            child: Center(
              child: Text(part.duration?.inSeconds.toString() ?? 'x'),
            ),
          ),
          Expanded(
            child: Text(
              '${part.runtimeType} (${part.duration})',
              style: TextStyle(
                color: isActive ? Colors.blue : Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.skip_next),
            onPressed: () => controller.move(part),
          ),
        ],
      ),
    );
  }
}

class WorkoutPartGroupWidget extends WorkoutPartWidget {
  const WorkoutPartGroupWidget({
    required WorkoutPartGroup super.part,
    required super.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    WorkoutPartGroup group = part as WorkoutPartGroup;

    final frame = controller.stack.firstWhereOrNull(
      (f) => f.group == group,
    );

    final repeatLabel = frame != null
        ? 'Repeat ${frame.iterator + 1}/${group.repeat}'
        : '${group.repeat}x';

    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  repeatLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (frame != null) ...[
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () => controller.iteratePrevious(),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () => controller.iterateNext(),
                ),
              ],
            ],
          ),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                ...group.parts.map(
                  (p) => WorkoutPartWidget.from(
                    p,
                    controller: controller,
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
