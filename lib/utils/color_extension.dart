import 'package:flutter/material.dart';
import 'package:material_color_utilities/hct/hct.dart';

extension ColorExtension on Color {
  Color darken([int amount = 10]) {
    // final oklabBolor = OklabColor.fromColor(this);
    // return OklabColor(
    //   oklabBolor.l - amount / 100,
    //   oklabBolor.a,
    //   oklabBolor.b,
    // ).toColor();

    final hctColor = Hct.fromInt(toInt());
    return Color(
      Hct.from(
        hctColor.hue,
        hctColor.chroma,
        hctColor.tone - amount,
      ).toInt(),
    );
  }

  Color lighten([int amount = 10]) {
    // final oklabBolor = OklabColor.fromColor(this);
    // return OklabColor(
    //   oklabBolor.l + amount / 100,
    //   oklabBolor.a,
    //   oklabBolor.b,
    // ).toColor();

    final hctColor = Hct.fromInt(toInt());
    return Color(
      Hct.from(
        hctColor.hue,
        hctColor.chroma,
        hctColor.tone + amount,
      ).toInt(),
    );
  }

  Color withLightness(int lightness) {
    // final oklabBolor = OklabColor.fromColor(this);
    // return OklabColor(
    //   lightness / 100,
    //   oklabBolor.a,
    //   oklabBolor.b,
    // ).toColor();

    final hctColor = Hct.fromInt(toInt());
    return Color(
      Hct.from(
        hctColor.hue,
        hctColor.chroma,
        lightness.toDouble(),
      ).toInt(),
    );
  }

  bool get isDark {
    return computeLuminance() < 0.5;
  }

  bool get isLight {
    return computeLuminance() >= 0.5;
  }

  Color withO(double opacity) {
    return withValues(
      alpha: opacity.clamp(0, 1),
    );
  }

  int toInt() {
    int toInt8(double x) {
      return (x * 255.0).round() & 0xff;
    }

    return toInt8(a) << 24 | toInt8(r) << 16 | toInt8(g) << 8 | toInt8(b) << 0;
  }

  String toHexString({bool includeAlpha = false}) {
    String hexValue = [r, g, b, if (includeAlpha) a]
        .map((v) => (v * 255).round().toRadixString(16).padLeft(2, '0'))
        .toList()
        .join();

    return '#$hexValue';
  }
}
