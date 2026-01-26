import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:evostream/components/def_button.dart';
import 'package:evostream/models/workout/workout.dart';
import 'package:evostream/utils/integer_extension.dart';
import 'package:flutter/material.dart';

class WorkoutEditorScreen extends StatefulWidget {
  const WorkoutEditorScreen({super.key});

  @override
  State<WorkoutEditorScreen> createState() => _WorkoutEditorScreenState();
}

class _WorkoutEditorScreenState extends State<WorkoutEditorScreen> {
  final List<WorkoutPart> slots = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                spacing: 8,
                children: [
                  DefButton.flat(
                    onPressed: save,
                    label: 'Save',
                  ),
                  DefButton.flat(
                    onPressed: addNewSlot,
                    label: 'New',
                  ),
                  DefButton.flat(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    label: 'Cancel',
                  ),
                ],
              ),
              Expanded(
                child: ReorderableListView(
                  children: List.generate(
                    slots.length,
                    (index) {
                      return ListTile(
                        key: ValueKey(index),
                        title: Text(slots[index].toString()),
                      );
                    },
                  ),
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    slots.swap(oldIndex, newIndex);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addNewSlot() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add new element',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ListTile(
                title: const Text('Constant interval'),
                onTap: () {
                  Navigator.pop(context);
                  _addConstantInterval();
                },
              ),
              ListTile(
                title: const Text('Rest'),
                onTap: () {
                  Navigator.pop(context);
                  _addRest();
                },
              ),
              ListTile(
                title: const Text('Work'),
                onTap: () {
                  Navigator.pop(context);
                  _addWork();
                },
              ),
              ListTile(
                title: const Text('Group'),
                onTap: () {
                  Navigator.pop(context);
                  _addGroup();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addConstantInterval() {
    final durationController = TextEditingController(text: '10');
    Intensity selectedIntensity = Intensity.energeticPace;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New constant interval'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (seconds)',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Intensity>(
                initialValue: selectedIntensity,
                items: Intensity.values
                    .map(
                      (i) => DropdownMenuItem(
                        value: i,
                        child: Text(i.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedIntensity = value;
                },
                decoration: const InputDecoration(labelText: 'Intensity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            DefButton.flat(
              onPressed: () {
                final seconds = int.tryParse(durationController.text) ?? 0;

                setState(() {
                  slots.add(
                    ConstantTimeInterval(
                      Duration(seconds: seconds),
                      intensity: selectedIntensity,
                    ),
                  );
                });

                Navigator.pop(context);
              },
              label: 'Add',
            ),
          ],
        );
      },
    );
  }

  void _addRest() {
    final durationController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New rest'),
          content: TextField(
            controller: durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duration (seconds)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            DefButton.flat(
              onPressed: () {
                final seconds = int.tryParse(durationController.text) ?? 0;

                setState(() {
                  slots.add(
                    Rest(
                      Duration(seconds: seconds),
                    ),
                  );
                });

                Navigator.pop(context);
              },
              label: 'Add',
            ),
          ],
        );
      },
    );
  }

  void _addWork() {
    final durationController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New work'),
          content: TextField(
            controller: durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duration (seconds)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            DefButton.flat(
              onPressed: () {
                final seconds = int.tryParse(durationController.text) ?? 0;

                setState(() {
                  slots.add(
                    Work(
                      Duration(seconds: seconds),
                    ),
                  );
                });

                Navigator.pop(context);
              },
              label: 'Add',
            ),
          ],
        );
      },
    );
  }

  void _addGroup() {
    final repeatController = TextEditingController(text: '3');
    final restController = TextEditingController(text: '5');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: repeatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Repeat'),
              ),
              TextField(
                controller: restController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Rest between iterations (sec, optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            DefButton.flat(
              onPressed: () {
                final repeat = int.tryParse(repeatController.text) ?? 1;
                final restSeconds = int.tryParse(restController.text);

                setState(() {
                  slots.add(
                    WorkoutPartGroup(
                      repeat: repeat,
                      rest: restSeconds != null
                          ? Rest(Duration(seconds: restSeconds))
                          : null,
                    ),
                  );
                  slots.add(const WorkoutPartGroupEnd());
                });

                Navigator.pop(context);
              },
              label: 'Add',
            ),
          ],
        );
      },
    );
  }

  void save() {
    final workout = buildWorkoutFromSlots(
      name: 'New Workout',
      slots: slots,
    );

    inspect(workout);
    Navigator.of(context).pop(workout);
  }

  Workout? buildWorkoutFromSlots({
    required String name,
    required List<WorkoutPart> slots,
  }) {
    return Workout(
      name: name,
      parts: [
        Prepare(5.s),
        ...slots,
        Finish(),
      ],
    );
  }
}
