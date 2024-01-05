import 'package:music_api/music_api.dart';
import 'package:netease_api/netease_api.dart';
import 'album_item_extension.dart';
import 'artist_item_extension.dart';

import 'track_type_extension.dart';

extension TrackMapper on TracksItem {
  Track toTrack(
    PrivilegesItem? privilege, {
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
      type: trackType(
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
