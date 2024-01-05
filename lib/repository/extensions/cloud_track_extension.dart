import 'package:music_api/music_api.dart';
import 'package:netease_api/netease_api.dart';

import 'track_type_extension.dart';

extension CloudTrackMapper on CloudSongItem {
  Track toTrack() {
    final album = AlbumMini(
      id: simpleSong.al.id,
      picUri: simpleSong.al.picUrl,
      name: simpleSong.al.name ?? this.album,
    );
    ArtistMini mapArtist(SimpleSongArtistItem item) {
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
      type: trackType(fee: simpleSong.fee, cs: true, st: simpleSong.st),
      artists: simpleSong.ar.map(mapArtist).toList(),
      uri: '',
      imageUrl: album.picUri,
      file: null,
      mp3Url: null,
      origin: 1,
    );
  }
}
