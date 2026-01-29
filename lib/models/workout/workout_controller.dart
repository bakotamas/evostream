import 'dart:async';

import 'package:collection/collection.dart';
import 'package:evostream/models/workout/workout.dart';
import 'package:evostream/services/sound_service.dart';
import 'package:evostream/utils/list_extension.dart';
import 'package:evostream/utils/value_notifier_utils.dart';

class WorkoutController {
  final Workout workout;

  WorkoutController({
    required this.workout,
  });

  late final Duration workoutDuration = _getTotalDuration();

  late SimpleWorkoutPart? current = _getCurrent();
  List<StackFrame> groupStack = [];
  int pointer = 0;

  Timer? timer;
  DateTime? lastTick;
  DateTime? start;

  Duration totalElapsed = Duration.zero;
  Duration currentElapsed = Duration.zero;

  final tickNotifier = TickNotifier();
  final stateNotifier = TickNotifier();

  bool running = false;

  void play() {
    if (running) return;

    running = true;
    lastTick = DateTime.now();

    start ??= DateTime.now();
    timer ??= Timer.periodic(Duration(milliseconds: 40), tick);

    stateNotifier.tick();
  }

  void pause() {
    running = false;

    stateNotifier.tick();
  }

  void stop() {
    running = false;
    timer?.cancel();
    timer = null;
    pointer = 0;
    groupStack.clear();
    current = _getCurrent();
    currentElapsed = Duration.zero;
    totalElapsed = Duration.zero;
    start = null;
    lastTick = null;

    stateNotifier.tick();
  }

  void dispose() {
    timer?.cancel();
    timer = null;
    tickNotifier.dispose();
    stateNotifier.dispose();
  }

  int? lastBeepSecond;
  void tick(_) {
    if (!running) return;

    final now = DateTime.now();
    if (lastTick != null) {
      final diff = now.difference(lastTick!);
      currentElapsed += diff;
      totalElapsed += diff;
    }
    lastTick = now;

    Duration? remaining;
    if (current?.duration != null) {
      remaining = current!.duration! - currentElapsed;
    }

    if (remaining != null) {
      if (remaining <= Duration.zero) {
        next();
      }

      final secondsLeft = remaining.inSeconds;
      if (secondsLeft <= 2 && secondsLeft >= 0) {
        if (lastBeepSecond != secondsLeft) {
          lastBeepSecond = secondsLeft;
          SoundService().beep();
        }
      }
    }

    tickNotifier.tick();
  }

  void next() {
    _moveNext();
    final current = _getCurrent();
    if (current == null) {
      stop();
      return;
    }
    this.current = current;
    currentElapsed = Duration.zero;

    stateNotifier.tick();

    lastBeepSecond = null;
    current.playSound();
  }

  void previous() {
    _movePrevious();
    final current = _getCurrent();
    if (current == null) {
      stop();
      return;
    }
    this.current = current;
    currentElapsed = Duration.zero;

    stateNotifier.tick();

    lastBeepSecond = null;
    current.playSound();
  }

  void move(SimpleWorkoutPart part) {
    final index = workout.parts.indexOf(part);
    if (index == -1) {
      stop();
      return;
    }
    groupStack.clear();
    for (var i = 0; i < index; i++) {
      final target = workout.parts[i];
      if (target is WorkoutPartGroup) {
        groupStack.add(StackFrame(target));
      }
      if (target is WorkoutPartGroupEnd) {
        if (groupStack.isEmpty) {
          stop();
          return;
        }
        groupStack.removeLast();
      }
    }

    pointer = index;
    current = part;
    currentElapsed = Duration.zero;

    stateNotifier.tick();

    lastBeepSecond = null;
    current?.playSound();
  }

  SimpleWorkoutPart? _getCurrent() {
    if (pointer >= workout.parts.length) {
      return null;
    }

    final part = workout.parts.tryGet(pointer);

    if (part is SimpleWorkoutPart) {
      return part;
    }

    return null;
  }

  void _moveNext() {
    int? maxAllowedPointer;
    pointer++;
    for (var i = pointer; i < workout.parts.length; i++) {
      if (maxAllowedPointer != null && i >= maxAllowedPointer) {
        stop();
        return;
      }

      final target = workout.parts.tryGet(i);

      if (target == null) {
        stop();
        return;
      }

      switch (target) {
        case SimpleWorkoutPart part:
          maxAllowedPointer = null;
          current = part;
          pointer = i;
          return;
        case WorkoutPartGroup group:
          groupStack.add(StackFrame(group));
        case WorkoutPartGroupEnd _:
          if (groupStack.isEmpty) {
            stop();
            return;
          }
          final frame = groupStack.last;
          if (frame.iterator >= frame.group.repeat - 1) {
            groupStack.removeLast();
          } else {
            maxAllowedPointer = i;
            groupStack.last.iterator++;
            i = workout.parts.indexOf(frame.group);
          }
      }
    }
  }

  void _movePrevious() {
    int? minAllowedPointer;
    pointer--;
    for (var i = pointer; i >= 0; i--) {
      if (minAllowedPointer != null && i <= minAllowedPointer) {
        stop();
        return;
      }

      final target = workout.parts.tryGet(i);

      if (target == null) {
        stop();
        return;
      }

      switch (target) {
        case SimpleWorkoutPart part:
          current = part;
          pointer = i;
          return;
        case WorkoutPartGroup _:
          if (groupStack.isEmpty) {
            stop();
            return;
          }
          final frame = groupStack.last;
          if (frame.iterator > 0) {
            minAllowedPointer = i;
            groupStack.last.iterator--;
            i = _findGroupEndIndex(i);
          } else {
            groupStack.removeLast();
          }
        case WorkoutPartGroupEnd _:
          final maybeGroup = workout.parts.tryGet(_findGroupIndex(i));
          if (maybeGroup case WorkoutPartGroup group) {
            groupStack.add(
              StackFrame(
                group,
                iterator: group.repeat - 1,
              ),
            );
          } else {
            stop();
            return;
          }
      }
    }
  }

  int _findGroupEndIndex(int index) {
    int counter = 0;
    for (var i = index + 1; i < workout.parts.length; i++) {
      final target = workout.parts.tryGet(i);

      if (target == null) {
        return -1;
      }

      if (target is WorkoutPartGroup) {
        counter++;
      }

      if (target is WorkoutPartGroupEnd) {
        if (counter > 0) {
          counter--;
        } else {
          return i;
        }
      }
    }

    return -1;
  }

  int _findGroupIndex(int index) {
    int counter = 0;
    for (var i = index - 1; i >= 0; i--) {
      final target = workout.parts.tryGet(i);

      if (target == null) {
        return -1;
      }

      if (target is WorkoutPartGroup) {
        if (counter > 0) {
          counter--;
        } else {
          return i;
        }
      }

      if (target is WorkoutPartGroupEnd) {
        counter++;
      }
    }

    return -1;
  }

  void nextRound(
    WorkoutPartGroup group, {
    bool reset = false,
  }) {
    _iterateNext(group, reset);
    if (reset) {
      pointer = workout.parts.indexOf(group);
      next();
    }

    stateNotifier.tick();
  }

  void previousRound(
    WorkoutPartGroup group, {
    bool reset = false,
  }) {
    _iteratePrevious(group, reset);
    if (reset) {
      pointer = workout.parts.indexOf(group);
      next();
    }

    stateNotifier.tick();
  }

  void _iterateNext(
    WorkoutPartGroup group,
    bool reset,
  ) {
    final frame = groupStack.firstWhereOrNull(
      (f) => f.group == group,
    );

    if (frame == null || frame.iterator >= group.repeat - 1) {
      return;
    }

    frame.iterator++;
    final stackIndex = groupStack.indexOf(frame);
    if (reset) {
      groupStack.removeRange(stackIndex + 1, groupStack.length);
    }
  }

  void _iteratePrevious(
    WorkoutPartGroup group,
    bool reset,
  ) {
    final frame = groupStack.firstWhereOrNull(
      (f) => f.group == group,
    );

    if (frame == null || frame.iterator <= 0) {
      return;
    }

    frame.iterator--;
    final stackIndex = groupStack.indexOf(frame);
    if (reset) {
      groupStack.removeRange(stackIndex + 1, groupStack.length);
    }
  }

  Duration _getTotalDuration() {
    Duration total = Duration.zero;
    List<int> multiplierStack = [];
    for (var i = 0; i < workout.parts.length; i++) {
      final target = workout.parts[i];

      switch (target) {
        case SimpleWorkoutPart part:
          int multiplier = multiplierStack.lastOrNull ?? 1;
          total += (part.duration ?? Duration.zero) * multiplier;
        case WorkoutPartGroup group:
          multiplierStack.add(group.repeat);
          total += (group.rest?.duration ?? Duration.zero) * (group.repeat - 1);
        case WorkoutPartGroupEnd _:
          multiplierStack.removeLast();
      }
    }
    return total;
  }

  double get progress {
    if (current?.duration == null || current!.duration!.inMilliseconds == 0) {
      return 0;
    }
    return currentElapsed.inMilliseconds / current!.duration!.inMilliseconds;
  }

  String get path {
    return groupStack
        .map((f) => "Set ${f.iterator + 1}/${f.group.repeat}")
        .join(" > ");
  }
}

class StackFrame {
  final WorkoutPartGroup group;
  int iterator;

  StackFrame(
    this.group, {
    this.iterator = 0,
  });
}
