import 'dart:async';

import 'package:evostream/models/workout/workout.dart';

class WorkoutController {
  final Workout workout;

  WorkoutController({
    required this.workout,
  }) {
    stack.add(StackFrame(workout.parts));
    current = getCurrentLeaf();
  }

  final List<StackFrame> stack = [];
  SimpleWorkoutPart? current;

  /// Időzítés
  Timer? timer;
  DateTime? lastTick;
  DateTime? start;

  Duration totalElapsed = Duration.zero;
  Duration currentElapsed = Duration.zero;

  bool running = false;

  void play() {
    if (running) return;

    running = true;
    lastTick = DateTime.now();

    start ??= DateTime.now();
    timer ??= Timer.periodic(Duration(milliseconds: 100), tick);
  }

  void pause() {
    running = false;
  }

  void stop() {
    running = false;
    timer?.cancel();
    timer = null;
    stack.clear();
    stack.add(StackFrame(workout.parts));
    current = getCurrentLeaf();
    currentElapsed = Duration.zero;
    totalElapsed = Duration.zero;
    start = null;
    lastTick = null;
  }

  void tick(_) {
    if (!running) return;

    final now = DateTime.now();
    if (lastTick != null) {
      final diff = now.difference(lastTick!);
      currentElapsed += diff;
      totalElapsed += diff;
    }
    lastTick = now;

    if (current?.duration != null && currentElapsed >= current!.duration!) {
      next();
    }
  }

  void next() {
    current = _moveNextLeaf();
    currentElapsed = Duration.zero;
  }

  void previous() {
    current = _movePreviousLeaf();
    currentElapsed = Duration.zero;
  }

  void move(SimpleWorkoutPart leaf) {
    current = _moveToLeaf(leaf);
    currentElapsed = Duration.zero;
  }

  SimpleWorkoutPart? getCurrentLeaf() {
    if (stack.isEmpty) return null;

    final frame = stack.last;
    final iterationParts = frame.group.expandedPartsForIteration(
      frame.iterator,
    );

    WorkoutPart part = iterationParts[stack.last.pointer];

    while (part is WorkoutPartGroup) {
      stack.add(StackFrame(part));
      part = part.parts[0];
    }

    return part as SimpleWorkoutPart;
  }

  bool _stepPointerNext() {
    while (stack.isNotEmpty) {
      final frame = stack.last;
      final iterationParts = frame.group.expandedPartsForIteration(
        frame.iterator,
      );

      if (frame.pointer + 1 < iterationParts.length) {
        frame.pointer++;
        return true;
      }

      if (frame.iterator + 1 < frame.group.repeat) {
        frame.iterator++;
        frame.pointer = 0;
        return true;
      }

      stack.removeLast();
    }

    return false;
  }

  bool _stepPointerPrevious() {
    while (stack.isNotEmpty) {
      final frame = stack.last;

      if (frame.pointer > 0) {
        frame.pointer--;
        return true;
      }

      if (frame.iterator > 0) {
        final iterationParts = frame.group.expandedPartsForIteration(
          frame.iterator - 1,
        );
        frame.iterator--;
        frame.pointer = iterationParts.length - 1;
        return true;
      }

      stack.removeLast();
    }

    return false;
  }

  bool _descendToLeaf({required bool forward}) {
    while (stack.isNotEmpty) {
      final frame = stack.last;
      final iterationParts = frame.group.expandedPartsForIteration(
        frame.iterator,
      );

      final part = iterationParts[frame.pointer];

      if (part is SimpleWorkoutPart) {
        return true;
      }

      if (part is WorkoutPartGroup && part.parts.isNotEmpty) {
        final child = StackFrame(part);
        if (!forward) {
          child.iterator = part.repeat - 1;
          final lastIterationParts = part.expandedPartsForIteration(
            child.iterator,
          );
          child.pointer = lastIterationParts.length - 1;
        }
        stack.add(child);
        continue;
      }

      return false;
    }

    return false;
  }

  bool _descendToLeaf2() {
    while (stack.isNotEmpty) {
      final frame = stack.last;

      final iterationParts = frame.group.expandedPartsForIteration(
        frame.iterator,
      );

      // Pointer érvényesség ellenőrzés
      if (frame.pointer < 0 || frame.pointer >= iterationParts.length) {
        return false;
      }

      final part = iterationParts[frame.pointer];

      // ✅ Leaf – kész vagyunk
      if (part is SimpleWorkoutPart) {
        return true;
      }

      // ✅ Group – belépünk
      if (part is WorkoutPartGroup && part.parts.isNotEmpty) {
        stack.add(StackFrame(part));
        continue;
      }

      return false;
    }

    return false;
  }

  SimpleWorkoutPart? _moveNextLeaf() {
    while (true) {
      if (!_stepPointerNext()) {
        return null;
      }

      if (_descendToLeaf(forward: true)) {
        return getCurrentLeaf();
      }
    }
  }

  SimpleWorkoutPart? _movePreviousLeaf() {
    while (true) {
      if (!_stepPointerPrevious()) {
        return null;
      }

      if (_descendToLeaf(forward: false)) {
        return getCurrentLeaf();
      }
    }
  }

  int? _getCurrentIteration() {
    if (stack.isNotEmpty) {
      return stack.last.iterator;
    } else {
      return null;
    }
  }

  bool iterateNext() {
    if (stack.isEmpty) return false;

    final frame = stack.last;

    if (frame.iterator + 1 < frame.group.repeat) {
      frame.iterator++;
      return true;
    }

    return false;
  }

  bool iteratePrevious() {
    if (stack.isEmpty) return false;

    final frame = stack.last;

    if (frame.iterator > 0) {
      frame.iterator--;
      return true;
    }

    return false;
  }

  SimpleWorkoutPart? _moveToLeaf(SimpleWorkoutPart target) {
    print('_moveToLeaf');
    final dfsStack = <StackFrame>[];

    dfsStack.add(StackFrame(workout.parts));

    while (dfsStack.isNotEmpty) {
      print(
        '${dfsStack.length} - ${dfsStack.last.iterator}, ${dfsStack.last.pointer}',
      );
      final frame = dfsStack.last;
      final iterationParts = frame.group.expandedPartsForIteration(
        frame.iterator,
      );

      if (frame.pointer >= iterationParts.length) {
        dfsStack.removeLast();
        continue;
      }

      final part = iterationParts[frame.pointer];

      if (part is SimpleWorkoutPart) {
        if (part == target) {
          stack
            ..clear()
            ..addAll(dfsStack);
          return part;
        }

        frame.pointer++;
      } else if (part is WorkoutPartGroup) {
        dfsStack.add(StackFrame(part));
      }
    }

    return null;
  }

  /// ====================== UI HELPER ======================

  /// Path jelzése a stack alapján (Set / Repeat / Interval)
  double get progress {
    if (current?.duration == null || current!.duration!.inSeconds == 0) {
      return 0;
    }
    return currentElapsed.inSeconds / current!.duration!.inSeconds;
  }

  String get path {
    return stack
        .map((f) => "Set ${f.iterator + 1}/${f.group.repeat}")
        .join(" / ");
  }
}

class StackFrame {
  final WorkoutPartGroup group;
  int pointer;
  int iterator;

  StackFrame(
    this.group, {
    this.pointer = 0,
    this.iterator = 0,
  });
}


  // SimpleWorkoutPart? _getNextLeaf() {
  //   while (stack.isNotEmpty) {
  //     final frame = stack.last;

  //     if (frame.pointer >= frame.group.parts.length) {
  //       if (frame.iterator >= frame.group.repeat - 1) {
  //         stack.removeLast();
  //         continue;
  //       } else {
  //         frame.iterator++;
  //         frame.pointer = 0;
  //       }
  //     }

  //     final part = frame.group.parts[frame.pointer];
  //     frame.pointer++;

  //     switch (part) {
  //       case SimpleWorkoutPart():
  //         return part;
  //       case WorkoutPartGroup():
  //         stack.add(StackFrame(part));
  //         continue;
  //     }
  //   }
  //   return null;
  // }

  // SimpleWorkoutPart? _getPreviousLeaf() {
  //   while (stack.isNotEmpty) {
  //     final frame = stack.last;
  //     print(
  //       'pointer: ${frame.pointer}, iterator: ${frame.iterator}, stack: ${stack.length}, group: ${frame.group}',
  //     );

  //     if (frame.pointer <= 0) {
  //       if (frame.iterator <= 0) {
  //         stack.removeLast();
  //         continue;
  //       } else {
  //         frame.iterator--;
  //       }
  //       frame.pointer = frame.group.parts.length - 1;
  //     }

  //     final part = frame.group.parts[frame.pointer];
  //     frame.pointer--;

  //     switch (part) {
  //       case SimpleWorkoutPart():
  //         return part;
  //       case WorkoutPartGroup():
  //         stack.add(StackFrame(part));
  //         continue;
  //     }
  //   }
  //   return null;
  // }