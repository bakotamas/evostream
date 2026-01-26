// ignore_for_file: constant_identifier_names

enum DurationFormatType {
  s,
  ms,
  hm,
  hms,
  unpaddedHm,
  unpaddedHms,
}

extension DurationExtension on Duration {
  String format(DurationFormatType format) {
    String hours = inHours.toString();
    String minutes = inMinutes.remainder(60).toString();
    String seconds = inSeconds.remainder(60).toString();

    return switch (format) {
      .s => '$seconds"',
      .ms => '${minutes.padLeft(2, '0')}:${seconds.padLeft(2, '0')}',
      .hm => '${hours.padLeft(2, '0')}:${minutes.padLeft(2, '0')}',
      .hms =>
        '${hours.padLeft(2, '0')}:${minutes.padLeft(2, '0')}:${seconds.padLeft(2, '0')}',
      .unpaddedHm => '$hours:$minutes',
      .unpaddedHms => '$hours:$minutes:$seconds',
    };
  }

  String formatSecondsOrMs() {
    if (inSeconds >= 60) {
      return format(.ms);
    }
    return format(.s);
  }
}
