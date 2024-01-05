import 'package:common_utils/common_utils.dart';
import 'package:music_api/music_api.dart';

import '../../netease_api.dart';

// https://github.com/Binaryify/NeteaseCloudMusicApi/issues/899#issuecomment-680002883
TrackType trackType({
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
  LogUtil.e('unknown fee: $fee');
  return TrackType.free;
}

extension TrackMapper on TracksItem {
  Track toTrack(PrivilegesItem? privilege, int origin) {
    final p = privilege ?? this.privilege;
    return Track(
      id: id,
      name: name,
      artists: ar.map((e) => e.toArtist()).toList(),
      album: al.toAlbum(),
      imageUrl: al.picUrl,
      uri: 'http://music.163.com/song/media/outer/url?id=$id.mp3',
      duration: Duration(milliseconds: dt),
      type: trackType(
        fee: p?.fee ?? fee,
        cs: p?.cs ?? false,
        st: p?.st ?? st,
      ),
      file: null,
      mp3Url: null,
      origin: origin,
    );
  }
}

extension ArtistItemMapper on ArtistItem {
  ArtistMini toArtist() {
    return ArtistMini(
      id: id,
      name: name,
      imageUrl: null,
    );
  }
}

extension AlbumItemMapper on AlbumItem {
  AlbumMini toAlbum() {
    return AlbumMini(
      id: id,
      name: name,
      picUri: picUrl,
    );
  }
}
