import 'package:evostream/services/sound_service.dart';
import 'package:evostream/utils/duration_extension.dart';
import 'package:flutter/material.dart';

class Workout {
  final String name;
  final List<WorkoutPart> parts;

  const Workout({
    required this.name,
    required this.parts,
  });
}

sealed class WorkoutPart {
  const WorkoutPart();
  WorkoutPart copyWith();
  String getName();
}

sealed class SimpleWorkoutPart extends WorkoutPart {
  final Duration? duration;

  const SimpleWorkoutPart([this.duration]);

  Color getColor();

  void playSound() {
    SoundService().startBeep();
  }

  @override
  String toString() {
    return '$runtimeType - ${duration?.formatSecondsOrMs() ?? 'Indeterminate'}';
  }

  @override
  SimpleWorkoutPart copyWith({
    Duration? duration,
  });
}

class Rest extends SimpleWorkoutPart {
  const Rest([
    super.duration,
  ]) : onlyBetweenRounds = false;

  const Rest.onlyBetweenRounds([
    super.duration,
  ]) : onlyBetweenRounds = true;

  Rest._(
    super.duration,
    this.onlyBetweenRounds,
  );

  final bool onlyBetweenRounds;

  @override
  Color getColor() {
    return Colors.teal.shade300;
  }

  @override
  String getName() {
    return onlyBetweenRounds ? 'Rest (between rounds)' : 'Rest';
  }

  @override
  void playSound() {
    SoundService().endBeep();
  }

  @override
  Rest copyWith({
    Duration? duration,
    bool? onlyBetweenRounds,
  }) {
    return Rest._(
      duration ?? this.duration,
      onlyBetweenRounds ?? this.onlyBetweenRounds,
    );
  }
}

class Work extends SimpleWorkoutPart {
  const Work([super.duration]);

  @override
  Color getColor() {
    return Colors.red.shade300;
  }

  @override
  String getName() {
    return 'Work';
  }

  @override
  Work copyWith({
    Duration? duration,
  }) {
    return Work(duration ?? this.duration);
  }
}

class Prepare extends SimpleWorkoutPart {
  const Prepare([super.duration]);

  @override
  Color getColor() {
    return Colors.amber.shade300;
  }

  @override
  String getName() {
    return 'Prepare';
  }

  @override
  void playSound() {}

  @override
  Prepare copyWith({
    Duration? duration,
  }) {
    return Prepare(duration ?? this.duration);
  }
}

class Finish extends SimpleWorkoutPart {
  const Finish([super.duration]);

  @override
  Color getColor() {
    return Colors.blue.shade300;
  }

  @override
  String getName() {
    return 'Finish';
  }

  @override
  void playSound() {
    SoundService().finishBeep();
  }

  @override
  Finish copyWith({
    Duration? duration,
  }) {
    return Finish(duration ?? this.duration);
  }
}

class WorkoutPartGroup extends WorkoutPart {
  final int repeat;
  final Rest? rest;

  const WorkoutPartGroup({
    this.repeat = 1,
    this.rest,
  });

  @override
  String toString() {
    final restString = rest == null
        ? ''
        : ' - rest: ${rest?.duration?.formatSecondsOrMs() ?? 'Indeterminte'}';
    return '$runtimeType - ${repeat}x$restString';
  }

  @override
  String getName() {
    return 'Group';
  }

  @override
  WorkoutPartGroup copyWith({
    int? repeat,
    Rest? rest,
  }) {
    return WorkoutPartGroup(
      repeat: repeat ?? this.repeat,
      rest: rest ?? this.rest,
    );
  }
}

class WorkoutPartGroupEnd extends WorkoutPart {
  const WorkoutPartGroupEnd();

  @override
  String toString() {
    return runtimeType.toString();
  }

  @override
  String getName() {
    return 'Group end';
  }

  @override
  WorkoutPartGroupEnd copyWith() {
    return const WorkoutPartGroupEnd();
  }
}

// enum Intensity {
//   max,
//   hard,
//   strong,
//   strongPace,
//   energeticPace,
//   livelyPace,
//   consistentPace,
//   easyPace,
//   technicalPace,
//   custom,
//   recovery,
//   pace500,
//   pace1000,
//   pace2000,
//   pace5000,
//   pace10000,
//   pace20000,
//   ;

//   Color getColor() {
//     return Colors.black;
//   }
// }
// class ConstantTimeInterval extends SimpleWorkoutPart {
//   final Intensity intensity;

//   ConstantTimeInterval(
//     super.duration, {
//     required this.intensity,
//   });

//   @override
//   String getName() {
//     return intensity.name;
//   }

//   @override
//   Color getColor() {
//     return intensity.getColor();
//   }
// }

// class VariableTimeInterval extends SimpleWorkoutPart {
//   final List<ConstantTimeInterval> subIntervals;

//   VariableTimeInterval._(
//     Duration super.duration, {
//     required this.subIntervals,
//   });

//   factory VariableTimeInterval.proportional({
//     required Duration duration,
//     required List<(num, Intensity)> intensities,
//   }) {
//     final num totalProportion = intensities
//         .map((e) => e.$1)
//         .reduce((a, b) => a + b);

//     List<ConstantTimeInterval> subIntervals = [];
//     for (final part in intensities) {
//       final proportion = part.$1;
//       final intensity = part.$2;

//       final subInterval = ConstantTimeInterval(
//         duration * (proportion / totalProportion),
//         intensity: intensity,
//       );

//       subIntervals.add(subInterval);
//     }

//     return VariableTimeInterval._(
//       duration,
//       subIntervals: subIntervals,
//     );
//   }

//   factory VariableTimeInterval.even({
//     required Duration duration,
//     required List<Intensity> intensities,
//   }) {
//     final List<ConstantTimeInterval> subIntervals = intensities.map((i) {
//       return ConstantTimeInterval(
//         duration * (1 / intensities.length),
//         intensity: i,
//       );
//     }).toList();

//     return VariableTimeInterval._(
//       duration,
//       subIntervals: subIntervals,
//     );
//   }

//   @override
//   String getName() {
//     return subIntervals.map((e) => e.getName()).join(' + ');
//   }

//   @override
//   Color getColor() {
//     return subIntervals.first.getColor();
//   }
// }
