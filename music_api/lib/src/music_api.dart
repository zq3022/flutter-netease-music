import 'package:async/async.dart' show Result;

import 'page_result.dart';
import 'track.dart';

abstract class MusicApi {
  //  只需要实现几个简单的接口即可，

  /// [keyword] 关键字
  /// [offset] 偏移量
  /// [limit] 每页记录数
  ///
  Future<PageResult<Track>> searchMusic(
    String keyword, {
    int limit = 20,
    int offset = 0,
  });

  // // Future<Result<SearchResultSongs>> searchSongs(
  // Future<PageResult<Track>> searchSongs(
  //   String keyword, {
  //   int limit = 20,
  //   int offset = 0,
  // });

  /// 获取音乐播放url的接口
  // Future<Track> playUrl(Track track);
  Future<Result<String>> getPlayUrl(int id, [int br = 320000]);

  /// 获取歌词
  // Future<LyricContent?> lyric(Track track);
  Future<String?> lyric(int id);

  /// 获取唯一标志
  int get origin;

  /// 获取源name
  String get name;

  /// 获取包名，用于获取icon
  String get package;

//// icon 位置
  String get icon;
}
