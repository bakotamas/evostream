import 'dart:developer';

import 'package:evostream/components/def_button.dart';
import 'package:evostream/components/fade_hide.dart';
import 'package:evostream/models/workout/workout.dart';
import 'package:evostream/utils/color_extension.dart';
import 'package:evostream/utils/global_utils.dart';
import 'package:evostream/utils/integer_extension.dart';
import 'package:evostream/utils/text_style_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

sealed class _Slot extends StatelessWidget {
  final Key slotKey;
  final ValueNotifier<WorkoutPart> content;

  const _Slot({
    required this.slotKey,
    required this.content,
  });

  List<WorkoutPart> reportChildren();

  factory _Slot.fromWorkoutPart(WorkoutPart part) {
    if (part is SimpleWorkoutPart) {
      return _SimpleSlot(
        slotKey: UniqueKey(),
        content: ValueNotifier(part),
      );
    }
    if (part is WorkoutPartGroup) {
      return _GroupSlot(
        slotKey: UniqueKey(),
        content: ValueNotifier(part),
        children: [],
      );
    }
    throw Exception('Wrong part type: ${part.runtimeType}');
  }
}

class _SimpleSlot extends _Slot {
  const _SimpleSlot({
    required super.slotKey,
    required super.content,
  });

  @override
  Widget build(BuildContext context) {
    final part = content.value as SimpleWorkoutPart;
    return SizedBox(
      height: 70,
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                borderRadius: DefRadius.circular,
                color: part.getColor(),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: Align(
                    alignment: .centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        part.getName().toUpperCase(),
                        style: DefText.n.black.c(
                          part.getColor().withLightness(30),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: DurationPicker(
                    initialDuration: part.duration,
                    onChanged: (duration) {
                      content.value = part.copyWith(
                        duration: duration,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  List<WorkoutPart> reportChildren() {
    return [content.value];
  }
}

class _GroupSlot extends _Slot {
  const _GroupSlot({
    required super.slotKey,
    required super.content,
    this.children = const [],
  });

  final List<_Slot> children;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade400,
              width: 2,
            ),
            borderRadius: DefRadius.standard,
          ),
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Container(
                alignment: .centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Group'.toUpperCase(),
                  style: DefText.n.extraBold.c(Colors.grey.shade700),
                ),
              ),
              ReorderableSlotList(
                children: children,
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: DefButton.tonal(
                  size: .small,
                  label: 'Add',
                  icon: Icons.add,
                  onPressed: () async {
                    WorkoutPart? part = await addNewSlot(context);
                    if (part == null) {
                      return;
                    }
                    setState(() {
                      children.add(
                        _Slot.fromWorkoutPart(part),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  List<WorkoutPart> reportChildren() {
    return [
      content.value,
      ...children.expand((element) => element.reportChildren()),
      WorkoutPartGroupEnd(),
    ];
  }
}

class ReorderableSlotList extends StatefulWidget {
  const ReorderableSlotList({
    super.key,
    required this.children,
  });
  final List<_Slot> children;

  @override
  State<ReorderableSlotList> createState() => _ReorderableSlotListState();
}

class _ReorderableSlotListState extends State<ReorderableSlotList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final child = widget.children[index];
        return Container(
          // decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          key: child.slotKey,
          child: Row(
            crossAxisAlignment: .start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: ReorderableDragStartListener(
                  key: ValueKey(child.slotKey),
                  index: index,
                  child: Icon(
                    Icons.drag_indicator,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: child,
              ),
            ],
          ),
        );
      },
      itemCount: widget.children.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final child = widget.children.removeAt(oldIndex);
          widget.children.insert(newIndex, child);
        });
      },
    );
  }
}

class WorkoutEditorScreen extends StatefulWidget {
  const WorkoutEditorScreen({super.key});

  @override
  State<WorkoutEditorScreen> createState() => _WorkoutEditorScreenState();
}

class _WorkoutEditorScreenState extends State<WorkoutEditorScreen> {
  final List<_Slot> slots = [];

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
                    onPressed: () async {
                      WorkoutPart? part = await addNewSlot(context);
                      if (part == null) {
                        return;
                      }
                      setState(() {
                        slots.add(
                          _Slot.fromWorkoutPart(part),
                        );
                      });
                    },
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
                child: ReorderableSlotList(
                  children: slots,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: DefButton.tonal(
                  size: .small,
                  label: 'Add',
                  icon: Icons.add,
                  onPressed: () async {
                  WorkoutPart? part = await addNewSlot(context);
                  if (part == null) {
                    return;
                  }
                  setState(() {
                    slots.add(
                      _Slot.fromWorkoutPart(part),
                    );
                  });
                },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void save() {
    final workout = buildWorkoutFromSlots(
      name: 'New Workout',
      slots: slots.expand((e) => e.reportChildren()).toList(),
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

Future<WorkoutPart?> addNewSlot(BuildContext context) async {
  return await showModalBottomSheet(
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
              title: const Text('Rest'),
              onTap: () {
                Navigator.pop(
                  context,
                  Rest(90.s),
                );
              },
            ),
            ListTile(
              title: const Text('Work'),
              onTap: () {
                Navigator.pop(
                  context,
                  Work(90.s),
                );
              },
            ),
            ListTile(
              title: const Text('Group'),
              onTap: () {
                Navigator.pop(context, WorkoutPartGroup());
              },
            ),
          ],
        ),
      );
    },
  );
}

class DurationPicker extends StatefulWidget {
  final Duration? initialDuration;
  final ValueChanged<Duration>? onChanged;

  const DurationPicker({
    super.key,
    this.initialDuration,
    this.onChanged,
  });

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late Duration _duration;
  bool indeterminate = false;

  final _minutesController = TextEditingController();
  final _secondsController = TextEditingController();

  final _minutesFocus = FocusNode();
  final _secondsFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _duration = widget.initialDuration ?? Duration.zero;
    _syncControllers();

    _minutesFocus.addListener(_handleBlur);
    _secondsFocus.addListener(_handleBlur);
  }

  void _handleBlur() {
    if (!_minutesFocus.hasFocus && !_secondsFocus.hasFocus) {
      _fromTextFields();
    }
  }

  int _clamp(int value) => value.clamp(0, 59);

  void _syncControllers() {
    _minutesController.text = _clamp(
      _duration.inMinutes,
    ).toString().padLeft(2, '0');
    _secondsController.text = _clamp(
      _duration.inSeconds % 60,
    ).toString().padLeft(2, '0');
  }

  void _updateDuration(
    Duration newDuration, {
    bool fromTextFields = false,
  }) {
    bool syncControllers = !fromTextFields;

    if (newDuration.isNegative) return;

    final minutes = _clamp(newDuration.inMinutes);
    final seconds = _clamp(newDuration.inSeconds % 60);

    setState(() {
      if (minutes == 0 && seconds == 0) {
        _duration = 1.s;
        syncControllers = true;
      } else {
        _duration = Duration(minutes: minutes, seconds: seconds);
      }
    });

    if (syncControllers) {
      _syncControllers();
    }

    widget.onChanged?.call(_duration);
  }

  void _updateIndeterminate(final bool indeterminate) {
    setState(() {
      this.indeterminate = indeterminate;
    });
  }

  void _fromTextFields() {
    int minutes = int.tryParse(_minutesController.text) ?? 0;
    int seconds = int.tryParse(_secondsController.text) ?? 0;

    minutes = _clamp(minutes);
    seconds = _clamp(seconds);

    _minutesController.text = minutes.toString().padLeft(2, '0');
    _secondsController.text = seconds.toString().padLeft(2, '0');

    _minutesController.selection = TextSelection.collapsed(
      offset: _minutesController.text.length,
    );
    _secondsController.selection = TextSelection.collapsed(
      offset: _secondsController.text.length,
    );

    _updateDuration(
      Duration(minutes: minutes, seconds: seconds),
      fromTextFields: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      spacing: 4,
      children: [
        Disabled(
          disabled: indeterminate,
          child: Row(
            children: [
              DefButton.icon(
                size: .small,
                icon: Icons.remove,
                onPressed: () {
                  _updateDuration(
                    _duration - const Duration(seconds: 10),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: DefRadius.standard,
                  color: Colors.grey.shade200,
                ),
                width: 30,
                height: 24,
                child: TextField(
                  focusNode: _minutesFocus,
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  textAlign: TextAlign.center,
                  style: DefText.n.bold,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 20),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),
              ),
              Text(
                ':',
                style: DefText.n.bold,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: DefRadius.standard,
                  color: Colors.grey.shade200,
                ),
                width: 30,
                height: 24,
                child: TextField(
                  focusNode: _secondsFocus,
                  controller: _secondsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  textAlign: TextAlign.center,
                  style: DefText.n.bold,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 20),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),
              ),
              DefButton.icon(
                size: .small,
                icon: Icons.add,
                onPressed: () {
                  _updateDuration(
                    _duration + const Duration(seconds: 10),
                  );
                },
              ),
            ],
          ),
        ),
        DefButton.icon(
          size: .small,
          type: indeterminate ? .outlined : .flat,
          icon: Icons.all_inclusive,
          onPressed: () {
            _updateIndeterminate(!indeterminate);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    _minutesFocus.dispose();
    _secondsFocus.dispose();
    super.dispose();
  }
}
