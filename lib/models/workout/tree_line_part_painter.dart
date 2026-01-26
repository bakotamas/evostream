import 'dart:math' as math;

import 'package:flutter/material.dart';

enum TreeLineType { line, node, endNode, groupNode }

class TreeLinePainter extends CustomPainter {
  final TreeLineType type;
  final Color? color;
  final double strokeWidth;

  TreeLinePainter({
    required this.type,
    this.color,
    this.strokeWidth = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.grey.shade700
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    if (type == .line || type == .node) {
      canvas.drawLine(
        Offset(w / 2, 0),
        Offset(w / 2, h),
        paint,
      );
    }

    if (type == .endNode) {
      canvas.drawLine(
        Offset(w / 2, 0),
        Offset(w / 2, h / 4),
        paint,
      );
    }

    if (type == .groupNode) {
      canvas.drawLine(
        Offset(w / 2, 3 * h / 4),
        Offset(w / 2, h),
        paint,
      );
    }

    if (type == .node || type == .endNode) {
      canvas.drawArc(
        Rect.fromLTWH(w / 2, 0, w, h / 2),
        math.pi,
        -math.pi / 2,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TreeLinePainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
