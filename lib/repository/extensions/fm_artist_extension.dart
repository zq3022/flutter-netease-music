import 'package:music_api/music_api.dart';
import 'package:netease_api/netease_api.dart';

extension FmArtistMapper on FmArtist {
  ArtistMini toArtist() => ArtistMini(
        id: id,
        name: name,
        imageUrl: picUrl,
      );
}
