import 'package:evostream/components/circle_box.dart';
import 'package:evostream/components/def_button.dart';
import 'package:evostream/components/fade_hide.dart';
import 'package:evostream/models/workout/workout.dart';
import 'package:evostream/models/workout/workout_screen.dart';
import 'package:evostream/utils/color_extension.dart';
import 'package:evostream/utils/global_utils.dart';
import 'package:evostream/utils/integer_extension.dart';
import 'package:evostream/utils/text_style_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

sealed class Slot extends StatelessWidget {
  final Key slotKey;
  final ValueNotifier<WorkoutPart> content;
  final bool freezed;

  const Slot({
    required this.slotKey,
    required this.content,
    this.freezed = false,
    super.key,
  });

  List<WorkoutPart> reportChildren();

  factory Slot.fromWorkoutPart(
    WorkoutPart part, {
    bool freezed = false,
  }) {
    if (part is SimpleWorkoutPart) {
      return SimpleSlot(
        slotKey: UniqueKey(),
        content: ValueNotifier(part),
      );
    }
    if (part is WorkoutPartGroup) {
      return GroupSlot(
        slotKey: UniqueKey(),
        content: ValueNotifier(part),
        freezed: freezed,
        children: List.empty(growable: true),
      );
    }
    throw Exception('Wrong part type: ${part.runtimeType}');
  }
}

class SimpleSlot extends Slot {
  const SimpleSlot({
    required super.slotKey,
    required super.content,
    super.freezed = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final part = content.value as SimpleWorkoutPart;
    final c = part.getColor();
    return SizedBox(
      height: 70,
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          if (freezed) const SizedBox(width: 4),
          Padding(
            padding: const .symmetric(vertical: 8),
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                borderRadius: DefRadius.circular,
                color: c,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const .all(4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: DefRadius.standard,
                  color: c.withLightness(90),
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: .centerLeft,
                        child: Padding(
                          padding: const .symmetric(horizontal: 8),
                          child: Text(
                            part.getName().toUpperCase(),
                            style: DefText.n.black.c(
                              c.withLightness(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                    DurationPicker(
                      color: c,
                      initialDuration: part.duration,
                      onChanged: (duration, indeterminate) {
                        content.value = part.copyWith(
                          duration: indeterminate ? Duration.zero : duration,
                        );
                      },
                    ),
                  ],
                ),
              ),
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

class GroupSlot extends Slot {
  const GroupSlot({
    required super.slotKey,
    required super.content,
    required this.children,
    super.freezed = false,
    super.key,
  });

  final List<Slot> children;

  @override
  Widget build(BuildContext context) {
    final group = content.value as WorkoutPartGroup;
    return StatefulBuilder(
      builder: (context, setState) {
        return DecoratedBox(
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
                padding: const .symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Group'.toUpperCase(),
                  style: DefText.n.extraBold.c(Colors.grey.shade700),
                ),
              ),
              Padding(
                padding: const .only(right: 2),
                child: ReorderableSlotList(
                  freezed: freezed,
                  children: children,
                ),
              ),
              Padding(
                padding: const .all(8),
                child: Row(
                  children: [
                    if (!freezed)
                      DefButton.tonal(
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
                              Slot.fromWorkoutPart(part),
                            );
                          });
                        },
                      ),
                    const Spacer(),
                    RepeatPicker(
                      initialRepeat: group.repeat,
                      onChanged: (repeat) {
                        content.value = group.copyWith(
                          repeat: repeat,
                        );
                      },
                    ),
                  ],
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
      const WorkoutPartGroupEnd(),
    ];
  }
}

class ReorderableSlotList extends StatefulWidget {
  const ReorderableSlotList({
    required this.children,
    this.freezed = false,
    super.key,
  });

  final bool freezed;
  final List<Slot> children;

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
        final buttonColor = switch (child) {
          SimpleSlot simpleSlot =>
            (simpleSlot.content.value as SimpleWorkoutPart)
                .getColor()
                .withLightness(20),
          GroupSlot _ => Colors.grey.shade700,
        };
        return Container(
          key: child.slotKey,
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: .start,
                children: [
                  if (!widget.freezed)
                    Padding(
                      padding: const .symmetric(vertical: 6),
                      child: ReorderableDragStartListener(
                        key: ValueKey(child.slotKey),
                        index: index,
                        child: const Icon(
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
              if (!widget.freezed)
                Align(
                  alignment: .topRight,
                  child: Padding(
                    padding: .only(
                      right: child is SimpleSlot ? 4 : 8,
                      top: child is SimpleSlot ? 4 : 0,
                    ),
                    child: DefButton.icon(
                      icon: Icons.close,
                      size: .small,
                      onPressed: () {
                        setState(() {
                          widget.children.removeAt(index);
                        });
                      },
                      color: buttonColor,
                    ),
                  ),
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

class WorkoutEditorWidget extends StatefulWidget {
  const WorkoutEditorWidget({
    this.slotsPreset,
    super.key,
  });

  final List<Slot>? slotsPreset;

  @override
  State<WorkoutEditorWidget> createState() => _WorkoutEditorWidgetState();
}

class _WorkoutEditorWidgetState extends State<WorkoutEditorWidget> {
  late final List<Slot> slots = widget.slotsPreset ?? [];
  late final bool freezed = widget.slotsPreset != null;

  final ValueNotifier<WorkoutPart> prepareNotifier = ValueNotifier(
    Prepare(5.s),
  );
  final ValueNotifier<WorkoutPart> finishNotifier = ValueNotifier(
    const Finish(),
  );

  final Key prepareKey = UniqueKey();
  final Key finishKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    Widget list = Column(
      children: [
        if (!freezed)
          Row(
            crossAxisAlignment: .start,
            children: [
              const Padding(
                padding: .symmetric(
                  vertical: 6,
                ),
                child: Opacity(
                  opacity: .2,
                  child: Icon(
                    Icons.drag_indicator,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: SimpleSlot(
                  slotKey: prepareKey,
                  content: prepareNotifier,
                ),
              ),
            ],
          ),
        ReorderableSlotList(
          freezed: freezed,
          children: slots,
        ),
        if (!freezed)
          Padding(
            padding: const .all(16),
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
                    Slot.fromWorkoutPart(part),
                  );
                });
              },
            ),
          ),
        if (!freezed)
          Row(
            crossAxisAlignment: .start,
            children: [
              const Padding(
                padding: .symmetric(
                  vertical: 6,
                ),
                child: Opacity(
                  opacity: .2,
                  child: Icon(
                    Icons.drag_indicator,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: SimpleSlot(
                  slotKey: finishKey,
                  content: finishNotifier,
                ),
              ),
            ],
          ),
      ],
    );
    Widget controls = Padding(
      padding: const .all(8),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          if (!freezed) ...[
            DefButton.flat(
              onPressed: Navigator.of(context).pop,
              label: 'Cancel',
            ),
          ],
          const Spacer(),
          DefButton(
            onPressed: start,
            label: 'Start',
          ),
        ],
      ),
    );

    if (freezed) {
      return Column(
        children: [
          list,
          controls,
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: DefButton.icon(
            icon: Icons.arrow_back,
            onPressed: Navigator.of(context).pop,
          ),
        ),
        title: Text(
          'New workout',
          style: DefText.m,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const .all(4),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: list,
                ),
              ),
              controls,
            ],
          ),
        ),
      ),
    );
  }

  void start() {
    final workout = Workout(
      name: 'New Workout',
      parts: [
        if (!freezed) prepareNotifier.value,
        ...slots.expand((e) => e.reportChildren()),
        if (!freezed) finishNotifier.value,
      ],
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return WorkoutScreen(
            workout: workout,
          );
        },
      ),
    );
  }
}

Future<WorkoutPart?> addNewSlot(BuildContext context) async {
  return await showModalBottomSheet(
    context: context,
    builder: (context) {
      return Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              [
                Rest(90.s),
                Work(90.s),
                const WorkoutPartGroup(),
              ].map(
                (e) {
                  final color = switch (e) {
                    SimpleWorkoutPart part => part.getColor(),
                    _ => Colors.grey,
                  };
                  return ListTile(
                    contentPadding: const .symmetric(horizontal: 8),
                    title: Text(e.getName()),
                    leading: SizedBox.square(
                      dimension: 36,
                      child: Center(
                        child: CircleBox(
                          size: 18,
                          color: color.withLightness(90),
                          child: Center(
                            child: CircleBox(
                              size: 12,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context, e);
                    },
                  );
                },
              ).toList(),
        ),
      );
    },
  );
}

class DurationPicker extends StatefulWidget {
  final Duration? initialDuration;
  final Function(Duration, bool)? onChanged;
  final Color color;

  const DurationPicker({
    required this.color,
    this.initialDuration,
    this.onChanged,
    super.key,
  });

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late Duration _duration;
  late bool _indeterminate = widget.initialDuration == null;

  final _minutesController = TextEditingController();
  final _secondsController = TextEditingController();

  final _minutesFocus = FocusNode();
  final _secondsFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _duration = widget.initialDuration ?? 5.s;
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

    widget.onChanged?.call(_duration, _indeterminate);
  }

  void _updateIndeterminate(final bool indeterminate) {
    setState(() {
      _indeterminate = indeterminate;
    });

    widget.onChanged?.call(_duration, _indeterminate);
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
    Color textColor = widget.color.withLightness(20);
    Color filedColor = widget.color.withLightness(80);

    return Row(
      mainAxisAlignment: .spaceBetween,
      spacing: 4,
      children: [
        Disabled(
          disabled: _indeterminate,
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
                color: textColor,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: DefRadius.standard,
                  color: filedColor,
                ),
                width: 30,
                height: 24,
                child: Stack(
                  alignment: .center,
                  children: [
                    AnimatedOpacity(
                      duration: 300.ms,
                      opacity: _indeterminate ? 0 : 1,
                      child: TextField(
                        focusNode: _minutesFocus,
                        controller: _minutesController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        textAlign: .center,
                        textAlignVertical: .center,
                        style: DefText.n.bold.tabular.c(
                          textColor,
                        ),
                        decoration: _inputDeco,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const .fromLTRB(1,0,1,3),
                child: Text(
                  ':',
                  style: DefText.n.bold.c(textColor),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: DefRadius.standard,
                  color: filedColor,
                ),
                width: 30,
                height: 24,
                child: AnimatedOpacity(
                  duration: 300.ms,
                  opacity: _indeterminate ? 0 : 1,
                  child: TextField(
                    focusNode: _secondsFocus,
                    controller: _secondsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    textAlign: .center,
                    textAlignVertical: .center,
                    style: DefText.n.bold.tabular.c(
                      textColor,
                    ),
                    decoration: _inputDeco,
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
                color: textColor,
              ),
            ],
          ),
        ),
        DefButton.icon(
          size: .small,
          type: _indeterminate ? .outlined : .flat,
          icon: Icons.all_inclusive,
          onPressed: () {
            _updateIndeterminate(!_indeterminate);
          },
          color: textColor,
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

class RepeatPicker extends StatefulWidget {
  final int? initialRepeat;
  final ValueChanged<int>? onChanged;

  const RepeatPicker({
    super.key,
    this.initialRepeat,
    this.onChanged,
  });

  @override
  State<RepeatPicker> createState() => _RepeatPickerState();
}

class _RepeatPickerState extends State<RepeatPicker> {
  late int _repeat;

  final _repeatController = TextEditingController();
  final _repeatFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _repeat = widget.initialRepeat ?? 1;
    _syncControllers();

    _repeatFocus.addListener(_handleBlur);
  }

  void _handleBlur() {
    if (!_repeatFocus.hasFocus) {
      _fromTextFields();
    }
  }

  int _clamp(int value) => value.clamp(0, 999);

  void _syncControllers() {
    _repeatController.text = _clamp(_repeat).toString();
  }

  void _updateRepeat(
    int newRepeat, {
    bool fromTextFields = false,
  }) {
    bool syncControllers = !fromTextFields;

    if (newRepeat.isNegative) return;

    final repeat = _clamp(newRepeat);

    setState(() {
      if (repeat == 0) {
        _repeat = 1;
        syncControllers = true;
      } else {
        _repeat = repeat;
      }
    });

    if (syncControllers) {
      _syncControllers();
    }

    widget.onChanged?.call(_repeat);
  }

  void _fromTextFields() {
    int repeat = int.tryParse(_repeatController.text) ?? 0;

    _repeatController.text = repeat.toString();

    _repeatController.selection = TextSelection.collapsed(
      offset: _repeatController.text.length,
    );

    _updateRepeat(
      repeat,
      fromTextFields: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.grey.shade700;
    Color filedColor = Colors.grey.shade200;

    return Row(
      children: [
        DefButton.icon(
          size: .small,
          icon: Icons.remove,
          onPressed: () {
            _updateRepeat(_repeat - 1);
          },
          color: textColor,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: DefRadius.standard,
            color: filedColor,
          ),
          width: 50,
          height: 24,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: _repeatFocus,
                  controller: _repeatController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  textAlign: TextAlign.right,
                  textAlignVertical: .center,
                  style: DefText.n.bold.tabular.c(
                    textColor,
                  ),
                  decoration: _inputDeco,
                ),
              ),
              Padding(
                padding: const .fromLTRB(0, 0, 6, 1),
                child: Text(
                  'x',
                  style: DefText.n.bold.c(textColor),
                ),
              ),
            ],
          ),
        ),

        DefButton.icon(
          size: .small,
          icon: Icons.add,
          onPressed: () {
            _updateRepeat(_repeat + 1);
          },
          color: textColor,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _repeatController.dispose();
    _repeatFocus.dispose();
    super.dispose();
  }
}

const _inputDeco = InputDecoration(
  border: _inputBorder,
  errorBorder: _inputBorder,
  focusedBorder: _inputBorder,
  focusedErrorBorder: _inputBorder,
  enabledBorder: _inputBorder,
  disabledBorder: _inputBorder,
  contentPadding: EdgeInsets.zero,
  // floatingLabelBehavior: FloatingLabelBehavior.never,
);

const _inputBorder = OutlineInputBorder(
  borderSide: BorderSide(
    color: Colors.transparent,
    style: BorderStyle.none,
    width: 0,
  ),
);
