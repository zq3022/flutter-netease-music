import 'dart:convert';
import 'lyric_entity.dart';

/// 歌词处理
///
class LyricContent {
  LyricContent.from(String text) {
    final List<String> lines = _kLineSplitter.convert(text);
    _lines.addAll(lines);
    final Map map = <int, String>{};
    for (final line in lines) {
      LyricEntry.inflate(line, map as Map<int, String>);
    }

    final List<int> keys = map.keys.toList() as List<int>..sort();
    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      _durations.add(key);
      int duration = _kDefaultLineDuration;
      if (i + 1 < keys.length) {
        duration = keys[i + 1] - key;
      }
      _lyricEntries.add(LyricEntry(map[key], key, duration));
    }
  }

  ///splitter lyric content to line
  static const LineSplitter _kLineSplitter = LineSplitter();

  //默认歌词持续时间
  static const int _kDefaultLineDuration = 5 * 1000;

  final List<int> _durations = [];
  final List<LyricEntry> _lyricEntries = [];
  final List<String> _lines = [];

  int get size => _durations.length;

  LyricEntry operator [](int index) {
    return _lyricEntries[index];
  }

  int _getTimeStamp(int index) {
    return _durations[index];
  }

  LyricEntry? getLineByTimeStamp(final int timeStamp, final int anchorLine) {
    if (size <= 0) {
      return null;
    }
    final line = findLineByTimeStamp(timeStamp, anchorLine);
    return this[line];
  }

  ///
  /// 拼接另一份歌词
  LyricContent contact(LyricContent other) {
    final List<int> durations = [];
    final List<LyricEntry> lyricEntries = [];
    final List<String> line = [];
    var i1 = 0;
    var i2 = 0;
    while (i1 < _durations.length && i2 < other._durations.length) {
      if (_durations[i1] == other._durations[i2]) {
        durations.add(_durations[i1]);
        if (_lyricEntries[i1].line != null &&
            other._lyricEntries[i2].line != null &&
            _lyricEntries[i1].line! != other._lyricEntries[i2].line) {
          line.add(_lines[i1] + "  " + other._lyricEntries[i2].line!);
          lyricEntries.add(LyricEntry(
              _lyricEntries[i1].line! + "  " + other._lyricEntries[i2].line!,
              _lyricEntries[i1].position,
              _lyricEntries[i1].duration));
        } else {
          lyricEntries.add(_lyricEntries[i1]);
          line.add(_lines[i1]);
        }
        i1++;
        i2++;
      } else if (_durations[i1] < other._durations[i2]) {
        durations.add(_durations[i1]);
        lyricEntries.add(_lyricEntries[i1]);
        line.add(_lines[i1]);
        i1++;
      } else {
        durations.add(_durations[i2]);
        lyricEntries.add(_lyricEntries[i2]);
        line.add(_lines[i2]);
        i2++;
      }
    }
    if (i1 < _durations.length) {
      durations.addAll(_durations.sublist(i1, _durations.length - 1));
      lyricEntries.addAll(_lyricEntries.sublist(i1, _lyricEntries.length - 1));
      line.addAll(_lines.sublist(i1));
    } else if (i2 < other._durations.length) {
      durations
          .addAll(other._durations.sublist(i2, other._durations.length - 1));
      lyricEntries.addAll(
          other._lyricEntries.sublist(i2, other._lyricEntries.length - 1));
      line.addAll(_lines.sublist(i2));
    }
    _durations.clear();
    _durations.addAll(durations);
    _lyricEntries.clear();
    _lyricEntries.addAll(lyricEntries);
    _lines.clear();
    _lines.addAll(line);
    return this;
  }

  ///
  ///根据时间戳来寻找匹配当前时刻的歌词
  ///
  ///@param timeStamp  歌词的时间戳(毫秒)
  ///@param anchorLine the start line to search
  ///@return index to getLyricEntry
  ///
  int findLineByTimeStamp(final int timeStamp, final int anchorLine) {
    int position = anchorLine;
    if (position < 0 || position > size - 1) {
      position = 0;
    }
    if (_getTimeStamp(position) > timeStamp) {
      // look forward
      // ignore: invariant_booleans
      while (_getTimeStamp(position) > timeStamp) {
        position--;
        if (position <= 0) {
          position = 0;
          break;
        }
      }
    } else {
      while (_getTimeStamp(position) < timeStamp) {
        position++;
        if (position <= size - 1 && _getTimeStamp(position) > timeStamp) {
          position--;
          break;
        }
        if (position >= size - 1) {
          position = size - 1;
          break;
        }
      }
    }
    return position;
  }

  @override
  String toString() {
    return _lines.join("\n");
  }
}
