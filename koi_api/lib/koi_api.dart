import 'package:async/src/result/result.dart';
import 'package:music_api/music_api.dart';

/// 基础接口
class KoiApi extends MusicApi {
  KoiApi(String dir);

  @override
  int get origin => 2;

  @override
  String get name => '锦鲤';

  @override
  String get package => 'koi_api';

  @override
  String get icon => 'assets/icon.ico';

  /// 转码
  String _escape2Html(String str) {
    return str
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"');
  }

  @override
  Future<Result<String>> getPlayUrl(int id, [int br = 320000]) {
    // TODO: implement getPlayUrl
    throw UnimplementedError();
  }

  @override
  Future<String?> lyric(int id) {
    // TODO: implement lyric
    throw UnimplementedError();
  }

  @override
  Future<PageResult<Track>> searchMusic(String keyword,
      {int limit = 20, int offset = 0}) {
    // TODO: implement searchMusic
    throw UnimplementedError();
  }
}
