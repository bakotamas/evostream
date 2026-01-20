import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:evostream/models/workout/workout.dart';
import 'package:evostream/models/workout/workout_controller.dart';
import 'package:evostream/models/workout/workout_part_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WorkoutController controller;
  final Workout workout = Workout(
    name: 'Sample',
    parts: WorkoutPartGroup(
      parts: [
        ConstantTimeInterval(
          duration: Duration(seconds: 5),
          intensity: .energeticPace,
        ),
        Rest(),
        WorkoutPartGroup(
          repeat: 3,
          rest: Rest(duration: Duration(seconds: 5)),
          parts: [
            ConstantTimeInterval(
              duration: Duration(seconds: 3),
              intensity: .energeticPace,
            ),
            ConstantTimeInterval(
              duration: Duration(seconds: 2),
              intensity: .max,
            ),
          ],
        ),
        Work(duration: Duration(seconds: 10)),
      ],
    ),
  );

  @override
  void initState() {
    super.initState();
    controller = WorkoutController(workout: workout);

    Timer.periodic(Duration(milliseconds: 100), (_) {
      setState(() {});
    });
  }

  Widget buildPart(
    WorkoutPart part,
    SimpleWorkoutPart? current, {
    int indent = 0,
  }) {
    if (part is SimpleWorkoutPart) {
      final isActive = part == current;
      return Padding(
        padding: EdgeInsets.only(left: indent.toDouble() * 16),
        child: Row(
          children: [
            Text(isActive ? "➡ " : "   "),
            Text(
              "${part.runtimeType} - ${part.hashCode}",
              style: TextStyle(color: isActive ? Colors.blue : Colors.black),
            ),
          ],
        ),
      );
    } else if (part is WorkoutPartGroup) {
      final frame = controller.stack.firstWhereOrNull(
        (f) => f.group == part,
      );

      String repeatLabel = frame == null
          ? '${part.repeat}x'
          : frame.iterator + 1 <= part.repeat
          ? "Repeat ${frame.iterator + 1}/${part.repeat}x"
          : "Repeat 0/${part.repeat}x";

      return Padding(
        padding: EdgeInsets.only(left: indent.toDouble() * 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(repeatLabel, style: TextStyle(fontWeight: FontWeight.bold)),
            ...part.parts.map((p) => buildPart(p, current, indent: indent + 1)),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final current = controller.current;
    return Scaffold(
      appBar: AppBar(title: Text(workout.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${controller.path} - pointer: ${controller.stack.lastOrNull?.pointer.toString() ?? '-'}, iterator: ${controller.stack.lastOrNull?.iterator.toString() ?? '-'}, length: ${controller.stack.lastOrNull?.group.expandedPartsForIteration(controller.stack.lastOrNull?.iterator ?? 0).length.toString() ?? '-'}',
            ),
            Text(current.runtimeType.toString()),
            Text(current.hashCode.toString()),
            Text(
              controller.stack
                  .map(
                    (e) {
                      return e.group.hashCode.toString();
                    },
                  )
                  .join(', '),
            ),
            LinearProgressIndicator(
              value: controller.progress,
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: WorkoutPartWidget.fromWorkout(
                  workout,
                  controller: controller,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    inspect(controller);
                  },
                  child: Text("Inspect"),
                ),
                ElevatedButton(
                  onPressed: controller.previous,
                  child: Text("Previous"),
                ),
                ElevatedButton(
                  onPressed: controller.next,
                  child: Text("Next"),
                ),
              ],
            ),
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: controller.play,
                  child: Text("Play"),
                ),
                ElevatedButton(
                  onPressed: controller.pause,
                  child: Text("Pause"),
                ),
                ElevatedButton(
                  onPressed: controller.stop,
                  child: Text("Stop"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
