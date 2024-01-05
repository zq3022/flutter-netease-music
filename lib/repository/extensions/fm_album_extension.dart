import 'package:music_api/music_api.dart';
import 'package:netease_api/netease_api.dart';

extension FmAlbumMapper on FmAlbum {
  AlbumMini toAlbum() => AlbumMini(
        id: id,
        name: name,
        picUri: picUrl,
      );
}
