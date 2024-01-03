import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'track.g.dart';

typedef Music = Track;

enum TrackType {
  free,
  payAlbum,
  vip,
  cloud,
  noCopyright,
}

@JsonSerializable()
class Track with EquatableMixin {
  Track({
    required this.id,
    required this.uri,
    required this.name,
    required this.artists,
    required this.album,
    required this.imageUrl,
    required this.duration,
    required this.type,
    this.flag = 0,
    this.file,
    this.mp3Url,
    this.extra = '',
    this.origin = -1,
    this.isRecommend = false,
  });

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  final int id;

  final String? uri;

  final String name;

  final List<ArtistMini> artists;

  final AlbumMini? album;

  final String? imageUrl;

  final Duration duration;

  final TrackType type;

  /// 音乐来源,值根据不同的音乐源插件决定，保证不重复即可
  final int origin;

  /// 本地存储的文件，播放时优先使用该地址
  String? file;

  /// 可以实际用于播放的音乐文件url
  String? mp3Url;

  /// 额外的数据，用于不同的插件扩展
  String extra;

  /// 歌曲标记，每一bit代表不同类型，类型用户自己决定
  int flag;

  final bool isRecommend;

  String get displaySubtitle {
    final artist = artists.map((artist) => artist.name).join('/');
    return '$artist - ${album?.name ?? ''}';
  }

  String get artistString {
    return artists.map((artist) => artist.name).join('/');
  }

  @override
  List<Object?> get props => [
        id,
        uri,
        name,
        artists,
        album,
        imageUrl,
        duration,
        type,
        file,
        origin,
        flag,
        isRecommend,
      ];

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}

@JsonSerializable()
class ArtistMini with EquatableMixin {
  ArtistMini({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory ArtistMini.fromJson(Map<String, dynamic> json) =>
      _$ArtistMiniFromJson(json);

  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, imageUrl];

  Map<String, dynamic> toJson() => _$ArtistMiniToJson(this);
}

@JsonSerializable()
class AlbumMini with EquatableMixin {
  AlbumMini({
    required this.id,
    required this.picUri,
    required this.name,
  });

  factory AlbumMini.fromJson(Map<String, dynamic> json) =>
      _$AlbumMiniFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'picUrl')
  final String? picUri;

  @JsonKey(name: 'name')
  final String name;

  @override
  List<Object?> get props => [id, picUri, name];

  Map<String, dynamic> toJson() => _$AlbumMiniToJson(this);
}
