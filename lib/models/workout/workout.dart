class Workout {
  final String name;
  final WorkoutPartGroup parts;

  const Workout({
    required this.name,
    required this.parts,
  });
}

sealed class WorkoutPart {
  const WorkoutPart();
}

sealed class SimpleWorkoutPart extends WorkoutPart {
  final Duration? duration;

  const SimpleWorkoutPart({
    required this.duration,
  });
}

class ConstantTimeInterval extends SimpleWorkoutPart {
  final Intensity intensity;

  ConstantTimeInterval({
    required this.intensity,
    required super.duration,
  });
}

class VariableTimeInterval extends SimpleWorkoutPart {
  final List<ConstantTimeInterval> subIntervals;

  VariableTimeInterval._({
    required this.subIntervals,
    required super.duration,
  });

  factory VariableTimeInterval.proportional({
    required Duration duration,
    required List<(num, Intensity)> intensities,
  }) {
    final num totalProportion = intensities
        .map((e) => e.$1)
        .reduce((a, b) => a + b);

    List<ConstantTimeInterval> subIntervals = [];
    for (final part in intensities) {
      final proportion = part.$1;
      final intensity = part.$2;

      final subInterval = ConstantTimeInterval(
        intensity: intensity,
        duration: duration * (proportion / totalProportion),
      );

      subIntervals.add(subInterval);
    }

    return VariableTimeInterval._(
      subIntervals: subIntervals,
      duration: duration,
    );
  }

  factory VariableTimeInterval.even({
    required Duration duration,
    required List<Intensity> intensities,
  }) {
    final List<ConstantTimeInterval> subIntervals = intensities.map((i) {
      return ConstantTimeInterval(
        intensity: i,
        duration: duration * (1 / intensities.length),
      );
    }).toList();

    return VariableTimeInterval._(
      subIntervals: subIntervals,
      duration: duration,
    );
  }
}

class Rest extends SimpleWorkoutPart {
  const Rest({
    super.duration,
  });
}

class Work extends SimpleWorkoutPart {
  const Work({
    super.duration,
  });
}

class WorkoutPartGroup extends WorkoutPart {
  final List<WorkoutPart> parts;
  final int repeat;
  final Rest? rest;

  const WorkoutPartGroup({
    required this.parts,
    this.repeat = 1,
    this.rest,
  });

  List<WorkoutPart> expandedPartsForIteration(int iteration) {
    if (rest == null || iteration >= repeat - 1) {
      return parts;
    }

    return [
      ...parts,
      rest!,
    ];
  }
}

enum Intensity {
  max,
  hard,
  strong,
  strongPace,
  energeticPace,
  livelyPace,
  consistentPace,
  easyPace,
  technicalPace,
  custom,
  recovery,
  pace500,
  pace1000,
  pace2000,
  pace5000,
  pace10000,
  pace20000,
}
