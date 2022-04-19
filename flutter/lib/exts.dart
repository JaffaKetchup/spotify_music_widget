extension DurationExts on Duration {
  String formatAsMinsSecs() =>
      (((toString().split(':')..removeAt(0)).join(':')).split('.')
        ..removeLast())[0];
}
