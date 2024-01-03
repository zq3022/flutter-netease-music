import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:koi_api/koi_api.dart';
import 'package:music_api/music_api.dart';
import 'package:netease_api/netease_api.dart' as netease_api;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../repository.dart';
import '../utils/cache/key_value_cache.dart';
import 'data/login_qr_key_status.dart';
import 'data/search_result.dart';

export 'package:netease_api/netease_api.dart'
    show
        SearchType,
        PlaylistOperation,
        CommentThreadId,
        CommentType,
        MusicCount,
        CellphoneExistenceCheck,
        PlayRecordType;

class NetworkRepository {
  NetworkRepository(this.cachePath)
      : _lyricCache = _LyricCache(p.join(cachePath));

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
    musicApiContainer.regiester(KoiApi(cookiePath));
    musicApiContainer
        .regiester(netease_api.Repository(cookiePath, onError: onError));

    neteaseRepository = NetworkRepository(cachePath);
  }

  final String cachePath;

  static final _onApiUnAuthorized = StreamController<void>.broadcast();

  Stream<void> get onApiUnAuthorized => _onApiUnAuthorized.stream;

  final _LyricCache _lyricCache;

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
        .then((value) => (value as netease_api.Repository).lyric(id));
    return lyricString;
  }

  Future<Result<List<String>>> searchHotWords() {
    return musicApiContainer
        .getApi(1)
        .then((value) => (value as netease_api.Repository).searchHotWords());
  }

  ///search by keyword
  Future<Result<Map>> search(
    String? keyword,
    netease_api.SearchType type, {
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
        .then((value) => (value as netease_api.Repository).searchSongs(
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
      musicApiContainer.getApi(1).then(
          (value) => (value as netease_api.Repository).searchSuggest(keyword));

  ///edit playlist tracks
  ///true : succeed
  Future<bool> playlistTracksEdit(
    netease_api.PlaylistOperation operation,
    int playlistId,
    List<int?> musicIds,
  ) =>
      musicApiContainer
          .getApi(1)
          .then((value) => (value as netease_api.Repository).playlistTracksEdit(
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
      musicApiContainer
          .getApi(1)
          .then((value) => (value as netease_api.Repository).getComments(
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
      .then((value) => (value as netease_api.Repository).likedList(userId));

  Future<Result<netease_api.MusicCount>> subCount() => musicApiContainer
      .getApi(1)
      .then((value) => (value as netease_api.Repository).subCount());

  Future<Result<netease_api.CellphoneExistenceCheck>> checkPhoneExist(
    String phone,
    String countryCode,
  ) =>
      musicApiContainer
          .getApi(1)
          .then((value) => (value as netease_api.Repository).checkPhoneExist(
                phone,
                countryCode,
              ));

  Future<Result<List<PlaylistDetail>>> userPlaylist(
    int? userId, {
    int offset = 0,
    int limit = 1000,
  }) async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((value) => (value as netease_api.Repository).userPlaylist(
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
    final ret = await musicApiContainer.getApi(1).then(
        (value) => (value as netease_api.Repository).playlistDetail(id, s: s));
    if (ret.isError) {
      return ret.asError!;
    }
    final value = ret.asValue!.value;
    return Result.value(value.playlist.toPlaylistDetail(value.privileges));
  }

  Future<Result<AlbumDetail>> albumDetail(int id) async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((value) => (value as netease_api.Repository).albumDetail(id));
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
      musicApiContainer
          .getApi(1)
          .then((value) => (value as netease_api.Repository).mvDetail(mvId));

  Future<Result<ArtistDetail>> artist(int id) async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((value) => (value as netease_api.Repository).artist(id));
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
        .then((value) => (value as netease_api.Repository).artistAlbums(
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
      musicApiContainer
          .getApi(1)
          .then((value) => (value as netease_api.Repository).artistMvs(
                artistId,
                limit: limit,
                offset: offset,
              ));

  // FIXME
  Future<Result<Map>> artistDesc(int artistId) => musicApiContainer
      .getApi(1)
      .then((value) => (value as netease_api.Repository).artistDesc(artistId));

  Future<Result<netease_api.TopListDetail>> topListDetail() => musicApiContainer
      .getApi(1)
      .then((value) => (value as netease_api.Repository).topListDetail());

  Future<Result<List<PlayRecord>>> getRecord(
    int userId,
    netease_api.PlayRecordType type,
  ) async {
    final records = await musicApiContainer.getApi(1).then(
        (value) => (value as netease_api.Repository).getRecord(userId, type));
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
  Future<Result<List<Map>>> djSubList() => musicApiContainer
      .getApi(1)
      .then((value) => (value as netease_api.Repository).djSubList());

  Future<Result<List<Map>>> userDj(int? userId) async =>
      Result.error('not implement');

  Future<Result<List<Track>>> personalizedNewSong() async {
    final ret = await musicApiContainer.getApi(1).then(
        (value) => (value as netease_api.Repository).personalizedNewSong());
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
        .then((value) => (value as netease_api.Repository).personalizedPlaylist(
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
        .then((value) => (value as netease_api.Repository).songDetails(ids));
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

  Future<bool> refreshLogin() => musicApiContainer
      .getApi(1)
      .then((value) => (value as netease_api.Repository).refreshLogin());

  Future<void> logout() => musicApiContainer
      .getApi(1)
      .then((value) => (value as netease_api.Repository).logout());

  // FIXME
  Future<Result<Map>> login(String? phone, String password) =>
      musicApiContainer.getApi(1).then(
          (value) => (value as netease_api.Repository).login(phone, password));

  Future<Result<User>> getUserDetail(int uid) async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((value) => (value as netease_api.Repository).getUserDetail(uid));
    if (ret.isError) {
      return ret.asError!;
    }
    final userDetail = ret.asValue!.value;
    return Result.value(userDetail.toUser());
  }

  Future<Result<List<Track>>> recommendSongs() async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((value) => (value as netease_api.Repository).recommendSongs());
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
          .then(
              (value) => (value as netease_api.Repository).getPlayUrl(id, br));

  Future<Result<List<Track>>> getPersonalFmMusics() async {
    final ret = await musicApiContainer.getApi(1).then(
        (value) => (value as netease_api.Repository).getPersonalFmMusics());
    if (ret.isError) {
      return ret.asError!;
    }
    final personalFm = ret.asValue!.value.data;
    return Result.value(personalFm.map((e) => e.toTrack(e.privilege)).toList());
  }

  Future<CloudTracksDetail> getUserCloudTracks() async {
    final ret = await musicApiContainer
        .getApi(1)
        .then((value) => (value as netease_api.Repository).getUserCloudMusic());
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
        .then((value) => (value as netease_api.Repository).loginQrKey());
    final data = ret.asValue!.value;
    return data['unikey'];
  }

  Future<LoginQrKeyStatus> checkLoginQrKey(String key) async {
    final code = await musicApiContainer
        .getApi(1)
        .then((value) => (value as netease_api.Repository).loginQrCheck(key));
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

  Future<Map> getLoginStatus() => musicApiContainer
      .getApi(1)
      .then((value) => (value as netease_api.Repository).loginStatus());

  Future<List<Track>> playModeIntelligenceList({
    required int id,
    required int playlistId,
  }) async {
    final ret = await musicApiContainer.getApi(1).then(
        (value) => (value as netease_api.Repository).playModeIntelligenceList(
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

// https://github.com/Binaryify/NeteaseCloudMusicApi/issues/899#issuecomment-680002883
TrackType _trackType({
  required int fee,
  required bool cs,
  required int st,
}) {
  if (st == -200) {
    return TrackType.noCopyright;
  }
  if (cs) {
    return TrackType.cloud;
  }
  switch (fee) {
    case 0:
    case 8:
      return TrackType.free;
    case 4:
      return TrackType.payAlbum;
    case 1:
      return TrackType.vip;
  }
  debugPrint('unknown fee: $fee');
  return TrackType.free;
}

extension _CloudTrackMapper on netease_api.CloudSongItem {
  Track toTrack() {
    final album = AlbumMini(
      id: simpleSong.al.id,
      picUri: simpleSong.al.picUrl,
      name: simpleSong.al.name ?? this.album,
    );
    ArtistMini mapArtist(netease_api.SimpleSongArtistItem item) {
      return ArtistMini(
        id: item.id,
        name: item.name ?? artist,
        imageUrl: '',
      );
    }

    return Track(
      id: songId,
      name: songName,
      album: album,
      duration: Duration(milliseconds: simpleSong.dt),
      type: _trackType(fee: simpleSong.fee, cs: true, st: simpleSong.st),
      artists: simpleSong.ar.map(mapArtist).toList(),
      uri: '',
      imageUrl: album.picUri,
      file: null,
      mp3Url: null,
      origin: 1,
    );
  }
}

extension _FmTrackMapper on netease_api.FmTrackItem {
  Track toTrack(netease_api.Privilege privilege) => Track(
        id: id,
        name: name,
        artists: artists.map((e) => e.toArtist()).toList(),
        album: album.toAlbum(),
        imageUrl: album.picUrl,
        uri: 'http://music.163.com/song/media/outer/url?id=$id.mp3',
        duration: Duration(milliseconds: duration),
        type:
            _trackType(fee: privilege.fee, st: privilege.st, cs: privilege.cs),
        file: null,
        mp3Url: null,
        origin: 1,
      );
}

extension _FmArtistMapper on netease_api.FmArtist {
  ArtistMini toArtist() => ArtistMini(
        id: id,
        name: name,
        imageUrl: picUrl,
      );
}

extension _FmAlbumMapper on netease_api.FmAlbum {
  AlbumMini toAlbum() => AlbumMini(
        id: id,
        name: name,
        picUri: picUrl,
      );
}

extension _PlayListMapper on netease_api.Playlist {
  PlaylistDetail toPlaylistDetail(List<netease_api.PrivilegesItem> privileges) {
    assert(coverImgUrl.isNotEmpty, 'coverImgUrl is empty');
    final privilegesMap = Map<int, netease_api.PrivilegesItem>.fromEntries(
      privileges.map((e) => MapEntry(e.id, e)),
    );
    return PlaylistDetail(
      id: id,
      name: name,
      coverUrl: coverImgUrl,
      trackCount: trackCount,
      playCount: playCount,
      subscribedCount: subscribedCount,
      creator: creator.toUser(),
      description: description,
      subscribed: subscribed,
      tracks: tracks.map((e) => e.toTrack(privilegesMap[e.id])).toList(),
      commentCount: commentCount,
      shareCount: shareCount,
      trackUpdateTime: trackUpdateTime,
      trackIds: trackIds.map((e) => e.id).toList(),
      createTime: DateTime.fromMillisecondsSinceEpoch(createTime),
      isMyFavorite: specialType == 5,
    );
  }
}

extension _TrackMapper on netease_api.TracksItem {
  Track toTrack(
    netease_api.PrivilegesItem? privilege, {
    bool isRecommend = false,
  }) {
    final p = privilege ?? this.privilege;
    final album = al.id == 0
        ? AlbumMini(id: 0, name: pc?.album ?? '-', picUri: al.picUrl)
        : al.toAlbum();
    final artists = ar.map((e) => e.toArtist()).toList();
    if (artists.isEmpty || artists.first.id == 0) {
      artists.clear();
      artists.add(
        ArtistMini(
          id: 0,
          name: pc?.artist ?? '-',
          imageUrl: artists.firstOrNull?.imageUrl,
        ),
      );
    }
    return Track(
      id: id,
      name: name,
      artists: artists,
      album: album,
      imageUrl: al.picUrl,
      uri: 'http://music.163.com/song/media/outer/url?id=$id.mp3',
      duration: Duration(milliseconds: dt),
      type: _trackType(
        fee: p?.fee ?? fee,
        cs: p?.cs ?? false,
        st: p?.st ?? st,
      ),
      isRecommend: isRecommend,
      file: null,
      mp3Url: null,
      origin: 1,

      ///默认为网易云的
    );
  }
}

extension _ArtistItemMapper on netease_api.ArtistItem {
  ArtistMini toArtist() {
    return ArtistMini(
      id: id,
      name: name,
      imageUrl: null,
    );
  }
}

extension _ArtistMapper on netease_api.Artist {
  Artist toArtist() {
    return Artist(
      id: id,
      name: name,
      picUrl: picUrl,
      briefDesc: briefDesc,
      mvSize: mvSize,
      albumSize: albumSize,
      followed: followed,
      musicSize: musicSize,
      publishTime: publishTime,
      image1v1Url: img1v1Url,
      alias: alias,
    );
  }
}

extension _AlbumItemMapper on netease_api.AlbumItem {
  AlbumMini toAlbum() {
    return AlbumMini(
      id: id,
      name: name,
      picUri: picUrl,
    );
  }
}

extension _AlbumMapper on netease_api.Album {
  Album toAlbum() {
    return Album(
      id: id,
      name: name,
      description: description,
      briefDesc: briefDesc,
      publishTime: DateTime.fromMillisecondsSinceEpoch(publishTime),
      paid: paid,
      artist: ArtistMini(
        id: artist.id,
        name: artist.name,
        imageUrl: artist.picUrl,
      ),
      shareCount: info.shareCount,
      commentCount: info.commentCount,
      likedCount: info.likedCount,
      liked: info.liked,
      onSale: onSale,
      company: company,
      picUrl: picUrl,
      size: size,
    );
  }
}

extension _UserMapper on netease_api.Creator {
  User toUser() {
    return User(
      userId: userId,
      nickname: nickname,
      avatarUrl: avatarUrl,
      followers: 0,
      followed: followed,
      backgroundUrl: backgroundUrl,
      createTime: 0,
      description: description,
      detailDescription: detailDescription,
      playlistBeSubscribedCount: 0,
      playlistCount: 0,
      allSubscribedCount: 0,
      followedUsers: 0,
      vipType: vipType,
      level: 0,
      eventCount: 0,
    );
  }
}

extension _UserDetailMapper on netease_api.UserDetail {
  User toUser() {
    return User(
      userId: profile.userId,
      nickname: profile.nickname,
      avatarUrl: profile.avatarUrl,
      followers: profile.follows,
      followed: profile.followed,
      backgroundUrl: profile.backgroundUrl,
      createTime: createTime,
      description: profile.description,
      detailDescription: profile.detailDescription,
      playlistBeSubscribedCount: profile.playlistBeSubscribedCount,
      playlistCount: profile.playlistCount,
      allSubscribedCount: profile.allSubscribedCount,
      followedUsers: profile.followeds,
      vipType: profile.vipType,
      level: level,
      eventCount: profile.eventCount,
    );
  }
}

class _LyricCache implements Cache<String?> {
  _LyricCache(String dir)
      : provider =
            FileCacheProvider(dir, maxSize: 20 * 1024 * 1024 /* 20 Mb */);

  final FileCacheProvider provider;

  @override
  Future<String?> get(CacheKey key) async {
    final file = provider.getFile(key);
    if (await file.exists()) {
      provider.touchFile(file);
      return file.readAsStringSync();
    }
    return null;
  }

  @override
  Future<bool> update(CacheKey key, String? t) async {
    if (t == null) return Future.value(false);
    var file = provider.getFile(key);

    if (file.existsSync()) {
      file.deleteSync();
    }

    file.createSync(recursive: true);
    file.writeAsStringSync(t);
    try {
      return file.exists();
    } finally {
      provider.checkSize();
    }
  }
}
