import 'package:evostream/utils/text_style_extension.dart';
import 'package:flutter/material.dart';

class DefText {
  static final TextStyle _ts = TextStyle();
  // static TextStyle get ts => _ts;

  /// 10 betűméret
  static TextStyle get xs => _ts.fs(10);

  /// 12 betűméret
  static TextStyle get s => _ts.fs(12);

  /// 14 betűméret
  static TextStyle get n => _ts.fs(14);

  /// 16 betűméret
  static TextStyle get m => _ts.fs(16);

  /// 18 betűméret
  static TextStyle get l => _ts.fs(18);

  /// 20 betűméret
  static TextStyle get xl => _ts.fs(20);

  static TextStyle get t1 => _ts.fs(28).fw(8);
  static TextStyle get t2 => xl.fw(8);
  // static TextStyle get t3 => l.fw(8);

  static TextStyle label(BuildContext context) => _ts.c(
    Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

class DefRadius {
  /// 4px sugarú lekerekítés
  static BorderRadius get zero => get(0);

  /// 4px sugarú lekerekítés
  static BorderRadius get small => get(4);

  /// 8px sugarú lekerekítés
  static BorderRadius get standard => get(8);

  /// 12px sugarú lekerekítés
  static BorderRadius get medium => get(12);

  /// 16px sugarú lekerekítés
  static BorderRadius get large => get(16);

  /// teljes lekerekítés
  static BorderRadius get circular => get(100_000);

  static BorderRadius top(BorderRadius radius) => BorderRadius.only(
    topLeft: radius.topLeft,
    topRight: radius.topRight,
  );

  static BorderRadius bottom(BorderRadius radius) => BorderRadius.only(
    bottomLeft: radius.bottomLeft,
    bottomRight: radius.bottomRight,
  );

  static BorderRadius left(BorderRadius radius) => BorderRadius.only(
    topLeft: radius.topLeft,
    bottomLeft: radius.bottomLeft,
  );

  static BorderRadius right(BorderRadius radius) => BorderRadius.only(
    topRight: radius.topRight,
    bottomRight: radius.bottomRight,
  );

  static BorderRadius get(double radius) => BorderRadius.circular(radius);
}

class DefDurations {
  /// 200 ms
  static Duration get short => const Duration(milliseconds: 200);

  /// 400 ms
  static Duration get medium => const Duration(milliseconds: 400);

  /// 500 ms
  static Duration get long => const Duration(milliseconds: 500);

  /// 800 ms
  static Duration get extraLong => const Duration(milliseconds: 800);
}
