class LyricEntry {
  LyricEntry(this.line, this.position, this.duration)
      : timeStamp = getTimeStamp(position);

  final String timeStamp;
  final String? line;
  final int position;

  ///the duration of this line
  final int duration;

  static RegExp pattern = RegExp(r'\[\d{2}:\d{2}.\d{2,3}]');

  static int _stamp2int(final String stamp) {
    final indexOfColon = stamp.indexOf(':');
    final indexOfPoint = stamp.indexOf('.');

    final minute = int.parse(stamp.substring(1, indexOfColon));
    final second = int.parse(stamp.substring(indexOfColon + 1, indexOfPoint));
    int millisecond;
    if (stamp.length - indexOfPoint == 2) {
      millisecond =
          int.parse(stamp.substring(indexOfPoint + 1, stamp.length)) * 10;
    } else {
      millisecond =
          int.parse(stamp.substring(indexOfPoint + 1, stamp.length - 1));
    }
    return (((minute * 60) + second) * 1000) + millisecond;
  }

  ///build from a .lrc file line .such as: [11:44.100] what makes your beautiful
  static void inflate(String line, Map<int, String> map) {
    //TODO lyric info
    if (line.startsWith('[ti:')) {
    } else if (line.startsWith('[ar:')) {
    } else if (line.startsWith('[al:')) {
    } else if (line.startsWith('[au:')) {
    } else if (line.startsWith('[by:')) {
    } else {
      final stamps = pattern.allMatches(line);
      final content = line.split(pattern).last;
      for (final stamp in stamps) {
        final timeStamp = _stamp2int(stamp.group(0)!);
        map[timeStamp] = content;
      }
    }
  }

  @override
  String toString() {
    return 'LyricEntry{line: $line, timeStamp: $timeStamp}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricEntry &&
          runtimeType == other.runtimeType &&
          line == other.line &&
          timeStamp == other.timeStamp;

  @override
  int get hashCode => line.hashCode ^ timeStamp.hashCode;

  static String getTimeStamp(int milliseconds) {
    final seconds = (milliseconds / 1000).truncate();
    final minutes = (seconds / 60).truncate();

    final minutesStr = (minutes % 60).toString().padLeft(2, '0');
    final secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }
}
