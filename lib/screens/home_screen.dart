import 'package:evostream/components/def_button.dart';
import 'package:evostream/models/workout/workout.dart';
import 'package:evostream/models/workout/workout_editor_screen.dart';
import 'package:evostream/utils/global_utils.dart';
import 'package:evostream/utils/integer_extension.dart';
import 'package:evostream/utils/text_style_extension.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const .symmetric(vertical: 16),
            child: Column(
              spacing: 8,
              children: [
                Container(
                  padding: const .symmetric(horizontal: 16),
                  alignment: .centerLeft,
                  child: Text(
                    'Quick start',
                    style: DefText.xl.black.c(scheme.primary),
                  ),
                ),
                Padding(
                  padding: const .all(8),
                  child: WorkoutEditorWidget(
                    slotsPreset: [
                      SimpleSlot(
                        slotKey: UniqueKey(),
                        freezed: true,
                        content: ValueNotifier(
                          Prepare(5.s),
                        ),
                      ),
                      GroupSlot(
                        slotKey: UniqueKey(),
                        freezed: true,
                        content: ValueNotifier(
                          const WorkoutPartGroup(repeat: 10),
                        ),
                        children: [
                          SimpleSlot(
                            slotKey: UniqueKey(),
                            freezed: true,
                            content: ValueNotifier(
                              Work(90.s),
                            ),
                          ),
                          SimpleSlot(
                            slotKey: UniqueKey(),
                            freezed: true,
                            content: ValueNotifier(
                              Rest(90.s),
                            ),
                          ),
                        ],
                      ),
                      SimpleSlot(
                        slotKey: UniqueKey(),
                        freezed: true,
                        content: ValueNotifier(
                          const Finish(),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const .symmetric(horizontal: 16),
                  alignment: .centerLeft,
                  child: Text(
                    'Custom workout',
                    style: DefText.xl.black.c(scheme.primary),
                  ),
                ),
                Container(
                  padding: const .symmetric(horizontal: 16),
                  alignment: .centerRight,
                  child: DefButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return const WorkoutEditorWidget();
                          },
                        ),
                      );
                    },
                    label: 'Create',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
