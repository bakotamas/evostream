/// This file contains the tests that take screenshots of the app.
///
/// Run it with `flutter test --update-goldens` to generate the screenshots
/// or `flutter test` to compare the screenshots to the golden files.
library;

import 'package:evostream/models/workout/workout.dart';
import 'package:evostream/models/workout/workout_editor_screen.dart';
import 'package:evostream/models/workout/workout_screen.dart';
import 'package:evostream/screens/home_screen.dart';
import 'package:evostream/utils/integer_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

void main() {
  group('Screenshot:', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    _screenshot('1_home', home: const HomeScreen());

    _screenshot(
      '2_editor',
      home: const WorkoutEditorWidget(),
      beforeScreenshot: (tester) async {
        Future<void> add(String label) async {
          await tester.tap(find.byIcon(Icons.add).first);

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          await tester.tap(
            find.widgetWithText(ListTile, label),
          );

          await tester.pumpAndSettle();
        }

        await add('Work');
        await add('Group');
        await add('Work');
        await add('Rest');
        await add('Group');
        await add('Work');
      },
    );

    _screenshot(
      '3_workout_prepare',
      home: WorkoutScreen(
        workout: Workout(
          name: 'NewWorkout',
          parts: [
            Prepare(5.s),
          ],
        ),
      ),
      beforeScreenshot: (tester) async {
        await tester.pump(2.s);
      },
    );
    _screenshot(
      '4_workout_work',
      home: WorkoutScreen(
        workout: Workout(
          name: 'NewWorkout',
          parts: [
            Work(90.s),
          ],
        ),
      ),
      beforeScreenshot: (tester) async {
        await tester.pump(60.s);
      },
    );
    _screenshot(
      '5_workout_rest',
      home: WorkoutScreen(
        workout: Workout(
          name: 'NewWorkout',
          parts: [
            Rest(30.s),
          ],
        ),
      ),
      beforeScreenshot: (tester) async {
        await tester.pump(12.s);
      },
    );
    _screenshot(
      '6_workout_finish',
      home: const WorkoutScreen(
        workout: Workout(
          name: 'NewWorkout',
          parts: [
            Finish(),
          ],
        ),
      ),
      beforeScreenshot: (tester) async {
        await tester.pump(8.s);
      },
    );
  });
}

void _screenshot(
  String description, {
  required Widget home,
  Future<void> Function(WidgetTester tester)? beforeScreenshot,
}) {
  group(description, () {
    for (final goldenDevice in GoldenScreenshotDevices.values) {
      if (!goldenDevice.name.startsWith('android')) continue;

      testGoldens('for ${goldenDevice.name}', (tester) async {
        final device = goldenDevice.device;

        // 1️⃣ Pump the widget first
        await tester.pumpWidget(
          ScreenshotApp.withConditionalTitlebar(
            device: device,
            title: 'Talk',
            home: home,
          ),
        );

        // 2️⃣ Run any interactive steps (like tapping + bottom sheets)
        if (beforeScreenshot != null) {
          await beforeScreenshot(tester);
        }

        // 3️⃣ Preload images and fonts now
        await tester.loadAssets();

        // 4️⃣ Pump a final frame to render everything
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 5️⃣ Take the screenshot
        await tester.expectScreenshot(device, description);
      });
    }
  });
}
