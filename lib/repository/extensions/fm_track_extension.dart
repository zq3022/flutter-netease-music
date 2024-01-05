import 'package:music_api/music_api.dart';
import 'package:netease_api/netease_api.dart';
import 'fm_album_extension.dart';
import 'fm_artist_extension.dart';
import 'track_type_extension.dart';

extension FmTrackMapper on FmTrackItem {
  Track toTrack(Privilege privilege) => Track(
        id: id,
        name: name,
        artists: artists.map((e) => e.toArtist()).toList(),
        album: album.toAlbum(),
        imageUrl: album.picUrl,
        uri: 'http://music.163.com/song/media/outer/url?id=$id.mp3',
        duration: Duration(milliseconds: duration),
        type: trackType(fee: privilege.fee, st: privilege.st, cs: privilege.cs),
        file: null,
        mp3Url: null,
        origin: 1,
      );
}
