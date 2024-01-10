import 'dart:async';

import 'package:async/async.dart' show Result, ErrorResult;
import 'package:common_utils/common_utils.dart';
import 'package:music_api/music_api.dart';
import 'package:netease_api/netease_api.dart';
import 'package:netease_api/search_type.dart';

import 'dio_util/dio_util.dart';

class KoiApi extends MusicApi {
  KoiApi({this.onError});
  @override
  int get origin => 0;

  @override
  String get name => '锦鲤';

  @override
  String get package => 'koi_api';

  @override
  String get icon => 'assets/icon.ico';

  @override
  final OnRequestError? onError;

  /// 转码
  String _escape2Html(String str) {
    return str
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"');
  }

  ///使用手机号码登录
  @override
  Future<Result<Map>> login(String? phone, String password) async {
    final result = await doRequest(
      'login',
      null,
      {'mobile': phone, 'password': password},
    );
    LogUtil.e('koi_api.login::result::${result.asValue!.value}');
    final json = result.asValue!.value;
    final userId = json['data']['userId'] as int;
    LogUtil.e('koi_api.login::userId::$userId');
    return Result.value({
      'code': 200,
      'account': {'id': userId},
    });
  }

  @override
  Future<Result<Map>> loginQrKey() {
    return doRequest('/login/qr/key');
  }

  /// 800: qrcode is expired
  /// 801: wait for qrcode to be scanned
  /// 802: qrcode is waiting for approval
  /// 803: qrcode is approved
  @override
  Future<int> loginQrCheck(String key) async {
    // try {
    //   final ret =
    //       await (await doRequest('/login/qr/check', {'key': key})).asFuture;
    //   LogUtil.e('login qr check: $ret');
    // } on RequestError catch (error) {
    //   if (error.code == 803) {
    //     await _saveCookies(error.answer.cookie);
    //   }
    //   return error.code;
    // }
    throw Exception('unknown error');
  }

  ///刷新登陆状态
  ///返回结果：true 正常登陆状态
  ///         false 需要重新登陆
  @override
  Future<bool> refreshLogin() async {
    final result = await doRequest('/login/refresh');
    return result.isValue;
  }

  @override
  Future<Map> loginStatus() async {
    final result = await doRequest('/login/status');
    return result.asFuture;
  }

  ///登出,删除本地cookie信息
  @override
  Future<void> logout() async {
    //删除cookie
    // await _cookieJar.future.then((v) => v.deleteAll());
  }

  ///PlayListDetail 中的 tracks 都是空数据
  @override
  Future<Result<UserPlayList>> userPlaylist(
    int? userId, {
    int offset = 0,
    int limit = 1000,
  }) async {
    final response = await doRequest(
      '/user/playlist',
      {'offset': offset, 'uid': userId, 'limit': limit},
    );
    return _map(response, (result) => UserPlayList.fromJson(result));
  }

  ///create new playlist by [name]
  @override
  Future<Result<PlayListDetail>?> createPlaylist(
    String? name, {
    bool privacy = false,
  }) async {
    final response = await doRequest(
      '/playlist/create',
      {'name': name, 'privacy': privacy ? 10 : null},
    );
    return _map(
      response,
      (result) => PlayListDetail.fromJson(result['playlist']),
    );
  }

  ///根据歌单id获取歌单详情，包括歌曲
  ///
  /// [s] 歌单最近的 s 个收藏者
  @override
  Future<Result<PlayListDetail>> playlistDetail(int id, {int s = 5}) async {
    final response = await doRequest('/playlist/detail', {'id': '$id', 's': s});
    return _map(response, (t) => PlayListDetail.fromJson(t));
  }

  ///id 歌单id
  ///return true if action success
  @override
  Future<bool> playlistSubscribe(int? id, {required bool subscribe}) async {
    final response = await doRequest(
      '/playlist/subscribe',
      {'id': id, 't': subscribe ? 1 : 2},
    );
    return response.isValue;
  }

  ///根据专辑详细信息
  @override
  Future<Result<AlbumDetail>> albumDetail(int id) async {
    final response = await doRequest('/album', {'id': id});
    return _map(response, (t) => AlbumDetail.fromJson(t));
  }

  ///推荐歌单
  @override
  Future<Result<Personalized>> personalizedPlaylist({
    int limit = 30,
    int offset = 0,
  }) async {
    final response = await doRequest(
      '/personalized',
      {'limit': limit, 'offset': offset, 'total': true, 'n': 1000},
    );
    return _map(response, (t) => Personalized.fromJson(t));
  }

  /// 推荐的新歌（10首）
  @override
  Future<Result<PersonalizedNewSong>> personalizedNewSong() async {
    final response = await doRequest('/personalized/newsong');
    return _map(response, (t) => PersonalizedNewSong.fromJson(t));
  }

  /// 榜单摘要
  @override
  Future<Result<TopListDetail>> topListDetail() async {
    final response = await doRequest('/toplist/detail');
    return _map(response, (t) => TopListDetail.fromJson(t));
  }

  ///推荐歌曲，需要登陆
  @override
  Future<Result<DailyRecommendSongs>> recommendSongs() async {
    final response = await doRequest('/recommend/songs');
    return _map(response, (t) => DailyRecommendSongs.fromJson(t['data']));
  }

  //根据音乐id获取歌词
  @override
  Future<String?> lyric(int id) async {
    final result = await doRequest('/lyric', {'id': id});
    if (result.isError) {
      return Future.error(result.asError!.error);
    }
    final Map? lyc = result.asValue!.value['lrc'];
    if (lyc == null) {
      return null;
    }
    return lyc['lyric'];
  }

  // ///根据音乐id获取歌词
  // @override
  // Future<LyricContent?> lyric(Track track) {
  //   return doRequest('/lyric', {'id': track.id}).then((value) {
  //     final Map? lyc = value.asValue?.value['lrc'];
  //     final Map? tlyc = value.asValue?.value['tlyric'];
  //     if (lyc == null) {
  //       return null;
  //     }
  //     String? res = lyc['lyric'];
  //     String? tres;
  //     if (tlyc != null && res != null && (tres = tlyc['lyric']) != null) {
  //       // 有中文歌词，尝试合并

  //       final ly = LyricContent.from(res);
  //       final tly = LyricContent.from(tres!);

  //       return ly.contact(tly);
  //     }

  //     return res == null ? null : LyricContent.from(res);
  //   });
  // }

  ///获取搜索热词
  @override
  Future<Result<List<String>>> searchHotWords() async {
    final result = await doRequest('/search/hot', {'type': 1111});
    return _map(result, (t) {
      final List hots = (t['result'] as Map)['hots'];
      return hots.cast<Map<String, dynamic>>().map((map) {
        return map['first'] as String;
      }).toList();
    });
  }

  ///search by keyword
  @override
  Future<Result<Map>> search(
    String? keyword,
    SearchType type, {
    int limit = 20,
    int offset = 0,
  }) {
    return doRequest('/search/cloud', {
      'keywords': keyword,
      'type': type.type,
      'limit': limit,
      'offset': offset,
    });
  }

  @override
  Future<Result<SearchResultSongs>> searchSongs(
    String keyword, {
    int limit = 20,
    int offset = 0,
  }) async {
    final result =
        await search(keyword, SearchType.song, limit: limit, offset: offset);
    return result.map((t) => SearchResultSongs.fromJson(t['result']));
  }

  // @override
  // Future<PageResult<Track>> searchMusic(
  //   String keyword, {
  //   int limit = 20,
  //   int offset = 0,
  // }) async {
  //   final result =
  //       await search(keyword, SearchType.song, limit: limit, offset: offset);
  //   final r = result.map((t) => SearchResultSongs.fromJson(t['result']));

  //   if (r.isError) {
  //     return Future.error(r.asError!.error);
  //   }

  //   return Future.value(PageResult(
  //       data:
  //           r.asValue!.value.songs.map((e) => e.toTrack(e.privilege)).toList(),
  //       total: r.asValue!.value.songCount,
  //       hasMore: r.asValue!.value.hasMore));
  // }

  ///搜索建议
  ///返回搜索建议列表，结果一定不会为null
  @override
  Future<Result<List<String>>> searchSuggest(String? keyword) async {
    if (keyword == null || keyword.isEmpty || keyword.trim().isEmpty) {
      return Result.value(const []);
    }
    final response = await doRequest(
      'https://music.163.com/weapi/search/suggest/keyword',
      {'s': keyword.trim()},
    );
    if (response.isError) {
      return Result.value(const []);
    }
    return _map(response, (dynamic t) {
      final match =
          (response.asValue!.value['result']['allMatch'] as List?)?.cast();
      if (match == null) {
        return [];
      }
      return match.map((m) => m['keyword']).cast<String>().toList();
    });
  }

  ///check music is available
  @override
  Future<bool> checkMusic(int id) async {
    final result = await doRequest(
      'https://music.163.com/weapi/song/enhance/player/url',
      {'ids': '[$id]', 'br': 999000},
    );
    return result.isValue && result.asValue!.value['data'][0]['code'] == 200;
  }

  // @override
  // Future<Track> playUrl(Track track) async {
  //   final result = await doRequest('/song/url', {'id': track.id});
  //   if (result.isError) return Future.error(result.asError!.error);

  //   final l = result.asValue!.value['data'] as List;
  //   if (l.first['url'] == null) {
  //     return Future.error(PlayDetailException('fail', track));
  //   }
  //   track.mp3Url = l.first['url'] as String;
  //   return Future.value(track);
  // }

  @override
  Future<Result<String>> getPlayUrl(int id, [int br = 320000]) async {
    final result = await doRequest('/song/url', {'id': id, 'br': br});
    return _map(result, (dynamic result) {
      final data = result['data'] as List;
      if (data.isEmpty) {
        throw Exception('we can not get realtime play url: data is empty');
      }
      final url = data.first['url'] as String;
      if (url.isEmpty) {
        throw Exception('we can not get realtime play url: URL is null');
      }
      return url;
    });
  }

  @override
  Future<Result<SongDetail>> songDetails(List<int> ids) async {
    final result = await doRequest('/song/detail', {'ids': ids.join(',')});
    return _map(result, (result) => SongDetail.fromJson(result));
  }

  ///edit playlist tracks
  ///true : succeed
  @override
  Future<bool> playlistTracksEdit(
    PlaylistOperation operation,
    int playlistId,
    List<int?> musicIds,
  ) async {
    assert(musicIds.isNotEmpty);

    final result = await doRequest('/playlist/tracks', {
      'op': operation == PlaylistOperation.add ? 'add' : 'del',
      'pid': playlistId,
      'tracks': musicIds.join(','),
    });
    return result.isValue;
  }

  ///update playlist name and description
  @override
  Future<bool> updatePlaylist({
    required int id,
    required String name,
    required String description,
  }) async {
    final response = await doRequest('/playlist/update', {
      'id': id,
      'name': name,
      'desc': description,
    });
    return _map(response, (dynamic t) {
      return true;
    }).isValue;
  }

  ///获取歌手信息和单曲
  @override
  Future<Result<ArtistDetail>> artist(int artistId) async {
    final result = await doRequest('/artists', {'id': artistId});
    return _map(result, (t) => ArtistDetail.fromJson(t));
  }

  ///获取歌手的专辑列表
  @override
  Future<Result<List<Album>>> artistAlbums(
    int artistId, {
    int limit = 10,
    int offset = 0,
  }) async {
    final result = await doRequest('/artist/album', {
      'id': artistId,
      'limit': limit,
      'offset': offset,
      'total': true,
    });
    return _map(result, (t) {
      final hotAlbums = t['hotAlbums'] as List;
      return hotAlbums
          .cast<Map<String, dynamic>>()
          .map((e) => Album.fromJson(e))
          .toList();
    });
  }

  ///获取歌手的MV列表
  @override
  Future<Result<Map>> artistMvs(
    int artistId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return doRequest('/artist/mv', {'id': artistId});
  }

  ///获取歌手介绍
  @override
  Future<Result<Map>> artistDesc(int artistId) async {
    return doRequest('/artist/desc', {'id': artistId});
  }

  ///get comments
  @override
  Future<Result<Map>> getComments(
    CommentThreadId commentThread, {
    int limit = 20,
    int offset = 0,
  }) async {
    return doRequest(
      '/comment/${commentThread.typePath}',
      {'id': commentThread.id, 'limit': limit, 'offset': offset},
    );
  }

  ///给歌曲加红心
  @override
  Future<bool> like(int? musicId, {required bool like}) async {
    final response = await doRequest('/like', {'id': musicId, 'like': like});
    return response.isValue;
  }

  ///获取用户红心歌曲id列表
  @override
  Future<Result<List<int>>> likedList(int? userId) async {
    final response = await doRequest('/likelist', {'uid': userId});
    return _map(response, (dynamic t) {
      return (t['ids'] as List).cast();
    });
  }

  ///获取用户信息 , 歌单，收藏，mv, dj 数量
  @override
  Future<Result<MusicCount>> subCount() {
    return doRequest('/user/subcount')
        .map((value) => MusicCount.fromJson(value));
  }

  ///获取用户创建的电台
  @override
  Future<Result<List<Map>>?> userDj(int? userId) async {
    final response =
        await doRequest('/user/dj', {'uid': userId, 'limit': 30, 'offset': 0});
    return _map(response, (dynamic t) {
      return (t['programs'] as List).cast();
    });
  }

  ///登陆后调用此接口 , 可获取订阅的电台列表
  @override
  Future<Result<List<Map>>> djSubList() async {
    return _map(await doRequest('/dj/sublist'), (dynamic t) {
      return (t['djRadios'] as List).cast();
    });
  }

  ///获取对应 MV 数据 , 数据包含 mv 名字 , 歌手 , 发布时间 , mv 视频地址等数据
  @override
  Future<Result<MusicVideoDetailResult>> mvDetail(int mvId) {
    return doRequest('/mv/detail', {'mvid': mvId})
        .map((json) => MusicVideoDetailResult.fromJson(json));
  }

  ///调用此接口,可收藏 MV
  @override
  Future<bool> mvSubscribe(int? mvId, {required bool subscribe}) async {
    final result =
        await doRequest('/mv/sub', {'id': mvId, 't': subscribe ? '1' : '0'});
    return result.isValue;
  }

  /// 获取用户播放记录
  @override
  Future<Result<List<PlayRecord>>> getRecord(
    int? uid,
    PlayRecordType type,
  ) async {
    final result =
        await doRequest('/user/record', {'uid': uid, 'type': type.index});
    return result.map((value) {
      final records = (value[type.value] as List).cast<Map<String, dynamic>>();
      return records.map((json) => PlayRecord.fromJson(json)).toList();
    });
  }

  ///获取用户详情
  @override
  Future<Result<UserDetail>> getUserDetail(int uid) async {
    final result = await doRequest('userDetail');
    return _map(result, (t) => UserDetail.fromJson(t));
  }

  ///
  /// 获取私人 FM 推荐歌曲。一次两首歌曲。
  ///
  @override
  Future<Result<PersonalFm>> getPersonalFmMusics() async {
    final result = await doRequest('/personal_fm');
    return _map(result, (t) => PersonalFm.fromJson(t));
  }

  @override
  Future<Result<CloudMusicDetail>> getUserCloudMusic() async {
    final result = await doRequest(
      '/user/cloud',
      {'limit': 200},
    );
    return result.map((value) => CloudMusicDetail.fromJson(value));
  }

  @override
  Future<Result<CellphoneExistenceCheck>> checkPhoneExist(
    String phone,
    String countryCode,
  ) async {
    // final result = await doRequest(
    //   '/cellphone/existence/check',
    //   {'phone': phone, 'countrycode': countryCode},
    // );
    // if (result.isError) return result.asError!;
    final value = CellphoneExistenceCheck.fromJson(
        {'exist': 1, 'nickname': '111qzh', 'hasPassword': true});
    return Result.value(value);
  }

  @override
  Future<Result<List<IntelligenceRecommend>>> playModeIntelligenceList({
    required int id,
    required int playlistId,
  }) async {
    final result = await doRequest(
      '/playmode/intelligence/list',
      {'id': id, 'pid': playlistId},
    );
    return _map(result, (t) => t['data'] as List).map((value) {
      return value.map((e) => IntelligenceRecommend.fromJson(e)).toList();
    });
  }

  ///[pathKey] request path
  ///[param] parameter
  Future<Result<Map<String, dynamic>>> doRequest(
    String pathKey, [
    Map<String, dynamic>? params,
    data,
  ]) async {
    Map<String, dynamic> result;
    LogUtil.e('koi_api.doRequest::>>>>>>>>>>>>>>>>$pathKey, $params, $data');
    try {
      result = await DioUtil().request(
        pathKey,
        params: params,
        data: data,
      );
      LogUtil.e('koi_api.doRequest::result::$result');
    } catch (e, stacktrace) {
      LogUtil.e('koi_api.doRequest::errorCatch: $e \n $stacktrace');
      final result = ErrorResult(e, stacktrace);
      onError?.call(result);
      return result;
    }
    if (result['code'] == 401) {
      final error = ErrorResult(
        RequestError(
          code: kCodeNeedLogin,
          message: '需要登录才能访问哦~',
          answer: Answer(body: result),
        ),
      );
      onError?.call(error);
      return error;
    } else if (result['code'] != 0) {
      final error = ErrorResult(
        RequestError(
          code: result['code'],
          message: result['msg'] ?? result['message'] ?? '请求失败了~',
          answer: Answer(body: result),
        ),
      );
      onError?.call(error);
      return error;
    }
    return Result.value(result);
  }
}

///map a result to any other
Result<R> _map<R>(
  Result<Map<String, dynamic>> source,
  R Function(Map<String, dynamic> t) f,
) {
  if (source.isError) return source.asError!;
  try {
    return Result.value(f(source.asValue!.value));
  } catch (e, s) {
    return Result.error(e, s);
  }
}
