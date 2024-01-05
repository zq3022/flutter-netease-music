import 'package:music_api/music_api.dart';
import 'package:netease_api/netease_api.dart';

extension AlbumItemMapper on AlbumItem {
  AlbumMini toAlbum() {
    return AlbumMini(
      id: id,
      name: name,
      picUri: picUrl,
    );
  }
}
