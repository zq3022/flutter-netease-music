import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:koi_api/koi_api.dart';
import 'package:music_api/music_api.dart';
import 'package:netease_api/netease_api.dart' as netease_api;
import 'package:netease_api/search_type.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../repository.dart';
import 'data/login_qr_key_status.dart';
import 'data/search_result.dart';
import 'extensions/album_extension.dart';
import 'extensions/artist_extension.dart';
import 'extensions/cloud_track_extension.dart';
import 'extensions/fm_track_extension.dart';
import 'extensions/playlist_extension.dart';
import 'extensions/track_extension.dart';
import 'extensions/user_detail_extension.dart';
import 'lyric_cache.dart';

export 'package:netease_api/netease_api.dart'
    show CommentThreadId, CommentType, MusicCount, CellphoneExistenceCheck;

class NetworkRepository {
  NetworkRepository(this.cachePath)
      : _lyricCache = LyricCache(p.join(cachePath));

  static void onError(ErrorResult error) {
    if (error.error is netease_api.RequestError) {
      final requestError = error.error as netease_api.RequestError;
      if (requestError.code == netease_api.kCodeNeedLogin) {
        _onApiUnAuthorized.add(null);
        return;
      }
    }
  }

  static Future<void> initialize() async {
    var documentDir = (await getApplicationDocumentsDirectory()).path;
    if (Platform.isWindows || Platform.isLinux) {
      documentDir = p.join(documentDir, 'quiet');
    }
    final cookiePath = p.join(documentDir, 'cookie');
    final cachePath = p.join(documentDir, 'cache');

    /// 注册api
    musicApiContainer.regiester(KoiApi(onError: onError));
    musicApiContainer
        .regiester(netease_api.Repository(cookiePath, onError: onError));

    neteaseRepository = NetworkRepository(cachePath);
  }

  final String cachePath;

  static final _onApiUnAuthorized = StreamController<void>.broadcast();

  Stream<void> get onApiUnAuthorized => _onApiUnAuthorized.stream;

  final LyricCache _lyricCache;

  /// 检查是否需要更新
  /// 需要更新返回新的版本号，否则返回null
  /// [github] 0 github ， 1 自建minio， 2 腾讯cos
  Future<dynamic> checkUpdate(int github) {
    Map<int, String> map = {
      0: 'https://api.github.com/repos/inkroom/flutter-netease-music/releases/latest',
      1: 'https://temp1.inkroom.cn/temp/quiet/version.json',
      2: 'https://quiet-1252774288.cos.ap-chengdu.myqcloud.com/version.json'
    };
    return Dio().get(map[github]!).then((value) => value.data);
  }

  /// Fetch lyric by track id
  // Future<LyricContent?> lyric(Track id) {
  //   final key = CacheKey.fromString(
  //       id.id.toString() + id.extra); // 如果修改歌词文件缓存位置，注意调整导出功能
  //   return _lyricCache.get(key).then((value) {
  //     if (value != null) {
  //       return Future.value(LyricContent.from(value.toString()));
  //     }
  //     return musicApiContainer
  //         .getApi(id.origin)
  //         .then((value) => value.lyric(id));
  //   }).then((value) {
  //     if (value == null) return Future.error(LyricException(''));
  //     _lyricCache.update(key, value.toString());
  //     return value;
  //   });
  // }

  // Fetch lyric by track id
  Future<String?> lyric(int id) async {
    final lyricString = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.lyric(id));
    return lyricString;
  }

  Future<Result<List<String>>> searchHotWords() {
    return musicApiContainer.getApi(1).then((value) => value.searchHotWords());
  }

  ///search by keyword
  Future<Result<Map>> search(
    String? keyword,
    SearchType type, {
    int limit = 20,
    int offset = 0,
  }) =>
      musicApiContainer.getApi(1).then((value) =>
          (value as netease_api.Repository)
              .search(keyword, type, limit: limit, offset: offset));

  Future<SearchResult<List<Track>>> searchMusics(String keyword,
      {int limit = 20, int offset = 0, int origin = 1}) async {
    final ret = await musicApiContainer
        .getApi(origin)
        .then((musicApi) => musicApi.searchSongs(
              keyword,
              limit: limit,
              offset: offset,
            ));
    final result = await ret.asFuture;
    return SearchResult<List<Track>>(
      result: result.songs.map((e) => e.toTrack(e.privilege)).toList(),
      hasMore: result.hasMore,
      totalCount: result.songCount,
    );
  }

  Future<Result<List<String>>> searchSuggest(String? keyword) =>
      musicApiContainer
          .getApi(1)
          .then((musicApi) => musicApi.searchSuggest(keyword));

  ///edit playlist tracks
  ///true : succeed
  Future<bool> playlistTracksEdit(
    PlaylistOperation operation,
    int playlistId,
    List<int?> musicIds,
  ) =>
      musicApiContainer
          .getApi(1)
          .then((musicApi) => musicApi.playlistTracksEdit(
                operation,
                playlistId,
                musicIds,
              ));

  Future<bool> playlistSubscribe(int? id, {required bool subscribe}) =>
      musicApiContainer.getApi(1).then((value) =>
          (value as netease_api.Repository)
              .playlistSubscribe(id, subscribe: subscribe));

  Future<Result<Map>> getComments(
    netease_api.CommentThreadId commentThread, {
    int limit = 20,
    int offset = 0,
  }) =>
      musicApiContainer.getApi(1).then((musicApi) => musicApi.getComments(
            commentThread,
            limit: limit,
            offset: offset,
          ));

  // like track.
  Future<bool> like(int? musicId, {required bool like}) =>
      musicApiContainer.getApi(1).then((value) =>
          (value as netease_api.Repository).like(musicId, like: like));

  // get user licked tracks.
  Future<Result<List<int>>> likedList(int? userId) => musicApiContainer
      .getApi(1)
      .then((musicApi) => musicApi.likedList(userId));

  Future<Result<netease_api.MusicCount>> subCount() =>
      musicApiContainer.getApi(1).then((musicApi) => musicApi.subCount());

  Future<Result<netease_api.CellphoneExistenceCheck>> checkPhoneExist(
    String phone,
    String countryCode,
  ) =>
      musicApiContainer.getApi(0).then((musicApi) => musicApi.checkPhoneExist(
            phone,
            countryCode,
          ));

  Future<Result<List<PlaylistDetail>>> userPlaylist(
    int? userId, {
    int offset = 0,
    int limit = 1000,
  }) async {
    final ret = await musicApiContainer
        .getApi(0)
        .then((musicApi) => musicApi.userPlaylist(
              userId,
              offset: offset,
              limit: limit,
            ));
    if (ret.isError) {
      return ret.asError!;
    }
    final userPlayList = ret.asValue!.value;
    return Result.value(
      userPlayList.playlist.map((e) => e.toPlaylistDetail(const [])).toList(),
    );
  }

  Future<Result<PlaylistDetail>> playlistDetail(
    int id, {
    int s = 5,
  }) async {
    final ret = await musicApiContainer
        .getApi(0)
        .then((musicApi) => musicApi.playlistDetail(id, s: s));
    if (ret.isError) {
      return ret.asError!;
    }
    final value = ret.asValue!.value;
    return Result.value(value.playlist.toPlaylistDetail(value.privileges));
  }

  Future<Result<AlbumDetail>> albumDetail(int id) async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.albumDetail(id));
    if (ret.isError) {
      return ret.asError!;
    }
    final albumDetail = ret.asValue!.value;
    return Result.value(
      AlbumDetail(
        album: albumDetail.album.toAlbum(),
        tracks: albumDetail.songs.map((e) => e.toTrack(null)).toList(),
      ),
    );
  }

  Future<Result<netease_api.MusicVideoDetailResult>> mvDetail(int mvId) =>
      musicApiContainer.getApi(1).then((musicApi) => musicApi.mvDetail(mvId));

  Future<Result<ArtistDetail>> artist(int id) async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.artist(id));
    if (ret.isError) {
      return ret.asError!;
    }
    final artistDetail = ret.asValue!.value;
    return Result.value(
      ArtistDetail(
        artist: artistDetail.artist.toArtist(),
        hotSongs: artistDetail.hotSongs.map((e) => e.toTrack(null)).toList(),
        more: artistDetail.more,
      ),
    );
  }

  Future<Result<List<Album>>> artistAlbums(
    int artistId, {
    int limit = 10,
    int offset = 0,
  }) async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.artistAlbums(
              artistId,
              limit: limit,
              offset: offset,
            ));
    if (ret.isError) {
      return ret.asError!;
    }
    final albumList = ret.asValue!.value;
    return Result.value(albumList.map((e) => e.toAlbum()).toList());
  }

  // FIXME
  Future<Result<Map>> artistMvs(
    int artistId, {
    int limit = 20,
    int offset = 0,
  }) =>
      musicApiContainer.getApi(1).then((musicApi) => musicApi.artistMvs(
            artistId,
            limit: limit,
            offset: offset,
          ));

  // FIXME
  Future<Result<Map>> artistDesc(int artistId) => musicApiContainer
      .getApi(1)
      .then((musicApi) => musicApi.artistDesc(artistId));

  Future<Result<netease_api.TopListDetail>> topListDetail() =>
      musicApiContainer.getApi(1).then((musicApi) => musicApi.topListDetail());

  Future<Result<List<PlayRecord>>> getRecord(
    int userId,
    PlayRecordType type,
  ) async {
    final records = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.getRecord(userId, type));
    if (records.isError) {
      return records.asError!;
    }
    final record = records.asValue!.value;
    return Result.value(
      record
          .map(
            (e) => PlayRecord(
              playCount: e.playCount,
              score: e.score,
              song: e.song.toTrack(null),
            ),
          )
          .toList(),
    );
  }

  // FIXME
  Future<Result<List<Map>>> djSubList() =>
      musicApiContainer.getApi(1).then((musicApi) => musicApi.djSubList());

  Future<Result<List<Map>>> userDj(int? userId) async =>
      Result.error('not implement');

  Future<Result<List<Track>>> personalizedNewSong() async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.personalizedNewSong());
    if (ret.isError) {
      return ret.asError!;
    }
    final personalizedNewSong = ret.asValue!.value.result;
    return Result.value(
      personalizedNewSong.map((e) => e.song.toTrack(e.song.privilege)).toList(),
    );
  }

  Future<Result<List<RecommendedPlaylist>>> personalizedPlaylist({
    int limit = 30,
    int offset = 0,
  }) async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.personalizedPlaylist(
              limit: limit,
              offset: offset,
            ));
    if (ret.isError) {
      return ret.asError!;
    }
    final personalizedPlaylist = ret.asValue!.value.result;
    return Result.value(
      personalizedPlaylist
          .map(
            (e) => RecommendedPlaylist(
              id: e.id,
              name: e.name,
              copywriter: e.copywriter,
              picUrl: e.picUrl,
              playCount: e.playCount,
              trackCount: e.trackCount,
              alg: e.alg,
            ),
          )
          .toList(),
    );
  }

  Future<Result<List<Track>>> songDetails(List<int> ids) async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.songDetails(ids));
    if (ret.isError) {
      return ret.asError!;
    }
    final songDetails = ret.asValue!.value.songs;
    final privilegesMap = Map<int, netease_api.PrivilegesItem>.fromEntries(
      ret.asValue!.value.privileges.map((e) => MapEntry(e.id, e)),
    );
    return Result.value(
      songDetails.map((e) => e.toTrack(privilegesMap[e.id])).toList(),
    );
  }

  Future<bool> mvSubscribe(int? mvId, {required bool subscribe}) =>
      musicApiContainer.getApi(1).then((value) =>
          (value as netease_api.Repository)
              .mvSubscribe(mvId, subscribe: subscribe));

  Future<bool> refreshLogin() =>
      musicApiContainer.getApi(0).then((musicApi) => musicApi.refreshLogin());

  Future<void> logout() =>
      musicApiContainer.getApi(0).then((musicApi) => musicApi.logout());

  Future<Result<Map>> login(String? phone, String password) => musicApiContainer
      .getApi(0)
      .then((musicApi) => musicApi.login(phone, password));

  Future<Result<Map>> signUp(String? phone, String password) =>
      musicApiContainer
          .getApi(0)
          .then((musicApi) => musicApi.signUp(phone, password));

  Future<Result<User>> getUserDetail(int uid) async {
    final ret = await musicApiContainer
        .getApi(0)
        .then((musicApi) => musicApi.getUserDetail(uid));
    if (ret.isError) {
      return ret.asError!;
    }
    final userDetail = ret.asValue!.value;
    return Result.value(userDetail.toUser());
  }

  Future<Result<List<Track>>> recommendSongs() async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.recommendSongs());
    if (ret.isError) {
      return ret.asError!;
    }
    final recommendSongs = ret.asValue!.value.dailySongs;
    return Result.value(
      recommendSongs.map((e) => e.toTrack(e.privilege)).toList(),
    );
  }

  Future<Result<String>> getPlayUrl(int id, [int br = 320000]) =>
      musicApiContainer
          // .getApi(track.origin)
          // .then((value) => value.playUrl(track));
          .getApi(1)
          .then((musicApi) => musicApi.getPlayUrl(id, br));

  Future<Result<List<Track>>> getPersonalFmMusics() async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.getPersonalFmMusics());
    if (ret.isError) {
      return ret.asError!;
    }
    final personalFm = ret.asValue!.value.data;
    return Result.value(personalFm.map((e) => e.toTrack(e.privilege)).toList());
  }

  Future<CloudTracksDetail> getUserCloudTracks() async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.getUserCloudMusic());
    final value = await ret.asFuture;
    return CloudTracksDetail(
      maxSize: int.tryParse(value.maxSize) ?? 0,
      size: int.tryParse(value.size) ?? 0,
      trackCount: value.count,
      tracks: value.data.map((e) => e.toTrack()).toList(),
    );
  }

  Future<String> loginQrKey() async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.loginQrKey());
    final data = ret.asValue!.value;
    return data['unikey'];
  }

  Future<LoginQrKeyStatus> checkLoginQrKey(String key) async {
    final code = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.loginQrCheck(key));
    switch (code) {
      case 800:
        return LoginQrKeyStatus.expired;
      case 801:
        return LoginQrKeyStatus.waitingScan;
      case 802:
        return LoginQrKeyStatus.waitingConfirm;
      case 803:
        return LoginQrKeyStatus.confirmed;
    }
    throw Exception('unknown error');
  }

  Future<Map> getLoginStatus() =>
      musicApiContainer.getApi(1).then((musicApi) => musicApi.loginStatus());

  Future<List<Track>> playModeIntelligenceList({
    required int id,
    required int playlistId,
  }) async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((musicApi) => musicApi.playModeIntelligenceList(
              id: id,
              playlistId: playlistId,
            ));
    final list = await ret.asFuture;
    return list
        .map(
          (e) => e.songInfo.toTrack(
            null,
            isRecommend: e.recommended,
          ),
        )
        .toList();
  }
}
