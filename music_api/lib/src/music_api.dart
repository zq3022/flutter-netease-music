import 'dart:async';
import 'dart:io';

import 'package:async/async.dart' show Result;
import 'package:netease_api/netease_api.dart';
import 'package:netease_api/search_type.dart';

abstract class MusicApi {
  // MusicApi(String cookiePath, {this.onError}) {
  //   // scheduleMicrotask(() async {
  //   //   PersistCookieJar? cookieJar;
  //   //   try {
  //   //     cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));
  //   //   } catch (e) {
  //   //     debugPrint('error: can not create persist cookie jar');
  //   //   }
  //   //   _cookieJar.complete(cookieJar);
  //   // });
  // }

  /// 获取唯一标志
  int get origin;

  /// 获取源name
  String get name => 'KoiApi';

  /// 获取包名，用于获取icon
  String get package => 'music_api';

  /// icon 位置
  String get icon => 'assets/icon.ico';

  // final Completer<PersistCookieJar> _cookieJar = Completer();

  // final OnRequestError? onError;

  // Future<List<Cookie>> _loadCookies() async {
  //   final jar = await _cookieJar.future;
  //   final uri = Uri.parse('http://music.163.com');
  //   return jar.loadForRequest(uri);
  // }

  // Future<void> _saveCookies(List<Cookie> cookies) async {
  //   final jar = await _cookieJar.future;
  //   await jar.saveFromResponse(Uri.parse('http://music.163.com'), cookies);
  // }

  ///使用手机号码登录
  Future<Result<Map>> login(String? phone, String password);

  Future<Result<Map>> loginQrKey();

  /// 800: qrcode is expired
  /// 801: wait for qrcode to be scanned
  /// 802: qrcode is waiting for approval
  /// 803: qrcode is approved
  Future<int> loginQrCheck(String key);

  ///刷新登陆状态
  ///返回结果：true 正常登陆状态
  ///         false 需要重新登陆
  Future<bool> refreshLogin();

  Future<Map> loginStatus();

  ///登出,删除本地cookie信息
  Future<void> logout();

  ///PlayListDetail 中的 tracks 都是空数据
  Future<Result<UserPlayList>> userPlaylist(
    int? userId, {
    int offset = 0,
    int limit = 1000,
  });

  ///create new playlist by [name]
  Future<Result<PlayListDetail>?> createPlaylist(
    String? name, {
    bool privacy = false,
  });

  ///根据歌单id获取歌单详情，包括歌曲
  ///
  /// [s] 歌单最近的 s 个收藏者
  Future<Result<PlayListDetail>> playlistDetail(int id, {int s = 5});

  ///id 歌单id
  ///return true if action success
  Future<bool> playlistSubscribe(int? id, {required bool subscribe});

  ///根据专辑详细信息
  Future<Result<AlbumDetail>> albumDetail(int id);

  ///推荐歌单
  Future<Result<Personalized>> personalizedPlaylist({
    int limit = 30,
    int offset = 0,
  });

  /// 推荐的新歌（10首）
  Future<Result<PersonalizedNewSong>> personalizedNewSong();

  /// 榜单摘要
  Future<Result<TopListDetail>> topListDetail();

  ///推荐歌曲，需要登陆
  Future<Result<DailyRecommendSongs>> recommendSongs();

  //根据音乐id获取歌词
  Future<String?> lyric(int id);

  ///获取搜索热词
  Future<Result<List<String>>> searchHotWords();

  ///search by keyword
  Future<Result<Map>> search(
    String? keyword,
    SearchType type, {
    int limit = 20,
    int offset = 0,
  });

  ///获取搜索歌曲
  Future<Result<SearchResultSongs>> searchSongs(
    String keyword, {
    int limit = 20,
    int offset = 0,
  });

  ///搜索建议
  ///返回搜索建议列表，结果一定不会为null
  Future<Result<List<String>>> searchSuggest(String? keyword);

  ///check music is available
  Future<bool> checkMusic(int id);

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
  Future<Result<String>> getPlayUrl(int id, [int br = 320000]);

  Future<Result<SongDetail>> songDetails(List<int> ids);

  ///edit playlist tracks
  ///true : succeed
  Future<bool> playlistTracksEdit(
    PlaylistOperation operation,
    int playlistId,
    List<int?> musicIds,
  );

  ///update playlist name and description
  Future<bool> updatePlaylist({
    required int id,
    required String name,
    required String description,
  });

  ///获取歌手信息和单曲
  Future<Result<ArtistDetail>> artist(int artistId);

  ///获取歌手的专辑列表
  Future<Result<List<Album>>> artistAlbums(
    int artistId, {
    int limit = 10,
    int offset = 0,
  });

  ///获取歌手的MV列表
  Future<Result<Map>> artistMvs(
    int artistId, {
    int limit = 20,
    int offset = 0,
  });

  ///获取歌手介绍
  Future<Result<Map>> artistDesc(int artistId);

  ///get comments
  Future<Result<Map>> getComments(
    CommentThreadId commentThread, {
    int limit = 20,
    int offset = 0,
  });

  ///给歌曲加红心
  Future<bool> like(int? musicId, {required bool like});

  ///获取用户红心歌曲id列表
  Future<Result<List<int>>> likedList(int? userId);

  ///获取用户信息 , 歌单，收藏，mv, dj 数量
  Future<Result<MusicCount>> subCount();

  ///获取用户创建的电台
  Future<Result<List<Map>>?> userDj(int? userId);

  ///登陆后调用此接口 , 可获取订阅的电台列表
  Future<Result<List<Map>>> djSubList();

  ///获取对应 MV 数据 , 数据包含 mv 名字 , 歌手 , 发布时间 , mv 视频地址等数据
  Future<Result<MusicVideoDetailResult>> mvDetail(int mvId);

  ///调用此接口,可收藏 MV
  Future<bool> mvSubscribe(int? mvId, {required bool subscribe});

  /// 获取用户播放记录
  Future<Result<List<PlayRecord>>> getRecord(
    int? uid,
    PlayRecordType type,
  );

  ///获取用户详情
  Future<Result<UserDetail>> getUserDetail(int uid);

  /// 获取私人 FM 推荐歌曲。一次两首歌曲。
  Future<Result<PersonalFm>> getPersonalFmMusics();

  Future<Result<CloudMusicDetail>> getUserCloudMusic();

  Future<Result<CellphoneExistenceCheck>> checkPhoneExist(
    String phone,
    String countryCode,
  );

  Future<Result<List<IntelligenceRecommend>>> playModeIntelligenceList({
    required int id,
    required int playlistId,
  });
}
