import 'package:evostream/components/fade_hide.dart';
import 'package:evostream/components/shimmer.dart';
import 'package:evostream/utils/color_extension.dart';
import 'package:evostream/utils/global_utils.dart';
import 'package:evostream/utils/text_style_extension.dart';
import 'package:flutter/material.dart';

enum DefButtonType { filled, flat, surface, tonal, outlined }

enum DefButtonSize { small, medium, large, fab, custom }

class DefButton extends StatefulWidget {
  const DefButton({
    required this.label,
    super.key,
    this.onPressed,
    this.onLongPress,
    this.subtitle,
    this.icon,
    this.color,
    this.canvasColor,
    this.trailingIcon = false,
    this.size = DefButtonSize.medium,
    this.loading = false,
    this.radius,
    this.column = false,
    this.elevated = true,
    this.columnMaxLines = 2,
    this.selfLoading = false,
    this.type = DefButtonType.filled,
    this.child,
  });
  const DefButton.custom({
    required this.child,
    super.key,
    this.onPressed,
    this.onLongPress,
    this.color,
    this.canvasColor,
    this.loading = false,
    this.radius,
    this.elevated = true,
    this.selfLoading = false,
    this.type = DefButtonType.filled,
  }) : label = null,
       icon = null,
       subtitle = null,
       trailingIcon = false,
       column = false,
       columnMaxLines = 2,
       size = DefButtonSize.custom;
  const DefButton.icon({
    required this.icon,
    super.key,
    this.onPressed,
    this.onLongPress,
    this.color,
    this.canvasColor,
    this.size = DefButtonSize.medium,
    this.loading = false,
    this.radius,
    this.elevated = false,
    this.selfLoading = false,
    this.type = DefButtonType.flat,
  }) : subtitle = null,
       trailingIcon = false,
       label = null,
       column = false,
       columnMaxLines = 2,
       child = null;
  const DefButton.flat({
    required this.label,
    super.key,
    this.onPressed,
    this.onLongPress,
    this.subtitle,
    this.icon,
    this.color,
    this.canvasColor,
    this.trailingIcon = false,
    this.size = DefButtonSize.medium,
    this.loading = false,
    this.radius,
    this.column = false,
    this.columnMaxLines = 2,
    this.selfLoading = false,
  }) : type = DefButtonType.flat,
       elevated = false,
       child = null;
  const DefButton.outlined({
    required this.label,
    super.key,
    this.onPressed,
    this.onLongPress,
    this.subtitle,
    this.icon,
    this.color,
    this.canvasColor,
    this.trailingIcon = false,
    this.size = DefButtonSize.medium,
    this.loading = false,
    this.radius,
    this.column = false,
    this.columnMaxLines = 2,
    this.selfLoading = false,
  }) : type = DefButtonType.outlined,
       elevated = false,
       child = null;
  const DefButton.surface({
    required this.label,
    super.key,
    this.onPressed,
    this.onLongPress,
    this.subtitle,
    this.icon,
    this.color,
    this.canvasColor,
    this.trailingIcon = false,
    this.size = DefButtonSize.medium,
    this.loading = false,
    this.radius,
    this.column = false,
    this.columnMaxLines = 2,
    this.selfLoading = false,
  }) : type = DefButtonType.surface,
       elevated = true,
       child = null;
  const DefButton.tonal({
    required this.label,
    super.key,
    this.onPressed,
    this.onLongPress,
    this.subtitle,
    this.icon,
    this.color,
    this.canvasColor,
    this.trailingIcon = false,
    this.size = DefButtonSize.medium,
    this.loading = false,
    this.radius,
    this.column = false,
    this.columnMaxLines = 2,
    this.selfLoading = false,
  }) : type = DefButtonType.tonal,
       elevated = false,
       child = null;

  final IconData? icon;
  final String? label;
  final String? subtitle;
  final Function()? onPressed;
  final Function()? onLongPress;
  final bool elevated;
  final Color? color;
  final Color? canvasColor;
  final BorderRadius? radius;
  final DefButtonType type;
  final bool trailingIcon;
  final DefButtonSize size;
  final bool loading;
  final bool column;
  final int columnMaxLines;
  final bool selfLoading;
  final Widget? child;

  factory DefButton.floatingMapButton(
    BuildContext context, {
    required IconData icon,
    Function()? onPressed,
    Function()? onLongPress,
    DefButtonSize size = DefButtonSize.medium,
  }) {
    return DefButton.icon(
      icon: icon,
      onPressed: onPressed,
      onLongPress: onLongPress,
      color: Theme.of(context).colorScheme.primary,
      type: DefButtonType.surface,
      elevated: true,
      size: size,
    );
  }

  @override
  State<DefButton> createState() => _DefButtonState();
}

class _DefButtonState extends State<DefButton> {
  bool selfLoading = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    double buttonPadding;
    double textPadding;
    double? height;

    switch (widget.size) {
      case DefButtonSize.fab:
        buttonPadding = 16;
        textPadding = 8;
        height = 56;
      case DefButtonSize.large:
        buttonPadding = 16;
        textPadding = 8;
        height = 48;
      case DefButtonSize.small:
        buttonPadding = 10;
        textPadding = 6;
        height = 32;
      case DefButtonSize.custom:
        buttonPadding = 0;
        textPadding = 0;
        height = null;
      default:
        buttonPadding = 16;
        textPadding = 8;
        height = 40;
    }

    if (widget.column) {
      buttonPadding = 8;
      textPadding = 8;
      height = 96;
    }

    Color color = widget.color ?? scheme.primary;
    Color backgroundColor;
    Color foregroundColor;

    switch (widget.type) {
      case DefButtonType.flat:
      case DefButtonType.outlined:
        backgroundColor = widget.canvasColor ?? Colors.transparent;
        foregroundColor = color;
      case DefButtonType.surface:
        backgroundColor = widget.canvasColor ?? scheme.surfaceContainerLowest;
        foregroundColor = color;
      case DefButtonType.tonal:
        backgroundColor = color.withO(.1);
        foregroundColor = color;
      default:
        backgroundColor = color;
        foregroundColor = scheme.surface;
    }

    Widget iconWidget = const SizedBox();
    double iconSize = widget.size == DefButtonSize.small ? 20 : 24;
    if ((widget.loading || selfLoading) && widget.icon != null) {
      iconWidget = SizedBox.square(
        dimension: iconSize,
        child: Padding(
          padding: const .all(2),
          child: CircularProgressIndicator(
            strokeAlign: BorderSide.strokeAlignInside,
            strokeWidth: 2,
            color: foregroundColor,
          ),
        ),
      );
    } else if (widget.icon != null) {
      iconWidget = Icon(
        widget.icon,
        size: iconSize,
        color: foregroundColor,
      );
    }

    Widget textWidget = const SizedBox();
    double textSize = widget.column || widget.size == DefButtonSize.small
        ? 12
        : 14;
    if (widget.label != null) {
      textWidget = Padding(
        padding: widget.column
            ? const .only(top: 6)
            : .symmetric(horizontal: textPadding),
        child: Text(
          widget.label!,
          style: DefText.n.fw(6).fs(textSize).c(foregroundColor).ellipsis,
          maxLines: widget.column ? widget.columnMaxLines : 1,
          textAlign: TextAlign.center,
        ),
      );
    }

    Widget subtitleWidget = const SizedBox();
    if (widget.subtitle != null) {
      subtitleWidget = Padding(
        padding: const .only(top: 2),
        child: Text(
          widget.subtitle ?? '',
          style: DefText.s.fs(10).c(foregroundColor).ellipsis,
          maxLines: widget.column ? widget.columnMaxLines : 1,
          textAlign: TextAlign.center,
        ),
      );
    }

    List<Widget> children = [
      iconWidget,
      textWidget,
    ];

    Widget child = widget.column
        ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...children,
              subtitleWidget,
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: widget.trailingIcon
                ? children.reversed.toList()
                : children,
          );

    BorderSide border = widget.type == DefButtonType.outlined
        ? BorderSide(
            style: BorderStyle.solid,
            color: foregroundColor,
            width: 1,
          )
        : BorderSide.none;

    return Disabled(
      disabled: widget.onPressed == null,
      opacity: .5,
      child: Shimmer(
        ignoreWhenLoading: true,
        loading: widget.loading || selfLoading,
        child: SizedBox(
          height: height,
          width: widget.icon != null && widget.label == null ? height : null,
          child: Material(
            elevation: widget.elevated ? 8 : 0,
            clipBehavior: Clip.antiAlias,
            shadowColor: scheme.shadow,
            shape: RoundedRectangleBorder(
              borderRadius:
                  widget.radius ??
                  (widget.column ? DefRadius.medium : DefRadius.circular),
              side: border,
            ),
            color: backgroundColor,
            child: InkWell(
              splashColor: foregroundColor.withO(.2),
              highlightColor: foregroundColor.withO(.1),
              onTap: () async {
                if (widget.selfLoading) {
                  setState(() {
                    selfLoading = true;
                  });
                }
                if (widget.onPressed != null) {
                  await widget.onPressed!();
                }
                if (widget.selfLoading && mounted) {
                  setState(() {
                    selfLoading = false;
                  });
                }
              },
              onLongPress: widget.onLongPress,
              child:
                  widget.child ??
                  Padding(
                    padding: widget.label == null
                        ? .zero
                        : .symmetric(
                            horizontal: buttonPadding,
                          ),
                    child: child,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
