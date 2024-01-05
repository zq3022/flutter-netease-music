import 'package:music_api/music_api.dart';
import 'package:netease_api/netease_api.dart';

extension ArtistItemMapper on ArtistItem {
  ArtistMini toArtist() {
    return ArtistMini(
      id: id,
      name: name,
      imageUrl: null,
    );
  }
}
