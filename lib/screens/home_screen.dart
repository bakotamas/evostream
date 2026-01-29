import 'package:evostream/components/def_button.dart';
import 'package:evostream/models/workout/workout.dart';
import 'package:evostream/models/workout/workout_editor_screen.dart';
import 'package:evostream/models/workout/workout_screen.dart';
import 'package:evostream/services/sound_service.dart';
import 'package:evostream/utils/integer_extension.dart';
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
