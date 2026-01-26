import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension TextStyleExtension on TextStyle {
  TextStyle fs(double? size) => copyWith(fontSize: size);
  TextStyle get xs => copyWith(fontSize: 10);
  TextStyle get s => copyWith(fontSize: 12);
  TextStyle get n => copyWith(fontSize: 14);
  TextStyle get m => copyWith(fontSize: 16);
  TextStyle get l => copyWith(fontSize: 18);
  TextStyle get xl => copyWith(fontSize: 20);

  TextStyle fw(int? weight) =>
      copyWith(fontWeight: FontWeight.values[(weight ?? 0).clamp(1, 9) - 1]);
  TextStyle get thin => copyWith(fontWeight: FontWeight.w100);
  TextStyle get extraLight => copyWith(fontWeight: FontWeight.w200);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get extraBold => copyWith(fontWeight: FontWeight.w800);
  TextStyle get black => copyWith(fontWeight: FontWeight.w900);
  TextStyle get it => copyWith(fontStyle: FontStyle.italic);

  TextStyle c(Color? color) => copyWith(color: color);
  TextStyle ls(double? letterSpacing) => copyWith(letterSpacing: letterSpacing);

  TextStyle lh(double? height) => copyWith(height: height);

  TextStyle get tabular => copyWith(
    fontFamily: 'Montserrat',
    letterSpacing: -0.15,
    fontFeatures: [
      const FontFeature.tabularFigures(),
    ],
  );

  TextStyle get monospace => copyWith(
    fontFamily: 'UbuntuMono',
  );

  TextStyle get ellipsis => copyWith(
    overflow: TextOverflow.ellipsis,
  );
}
