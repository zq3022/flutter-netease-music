// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Track _$TrackFromJson(Map<String, dynamic> json) => Track(
      id: json['id'] as int,
      uri: json['uri'] as String?,
      name: json['name'] as String,
      artists: (json['artists'] as List<dynamic>)
          .map((e) => ArtistMini.fromJson(e as Map<String, dynamic>))
          .toList(),
      album: json['album'] == null
          ? null
          : AlbumMini.fromJson(json['album'] as Map<String, dynamic>),
      imageUrl: json['imageUrl'] as String?,
      duration: Duration(microseconds: json['duration'] as int),
      type: $enumDecode(_$TrackTypeEnumMap, json['type']),
      flag: json['flag'] as int? ?? 0,
      file: json['file'] as String?,
      mp3Url: json['mp3Url'] as String?,
      extra: json['extra'] as String? ?? '',
      origin: json['origin'] as int? ?? -1,
      isRecommend: json['isRecommend'] as bool? ?? false,
    );

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'id': instance.id,
      'uri': instance.uri,
      'name': instance.name,
      'artists': instance.artists,
      'album': instance.album,
      'imageUrl': instance.imageUrl,
      'duration': instance.duration.inMicroseconds,
      'type': _$TrackTypeEnumMap[instance.type]!,
      'origin': instance.origin,
      'file': instance.file,
      'mp3Url': instance.mp3Url,
      'extra': instance.extra,
      'flag': instance.flag,
      'isRecommend': instance.isRecommend,
    };

const _$TrackTypeEnumMap = {
  TrackType.free: 'free',
  TrackType.payAlbum: 'payAlbum',
  TrackType.vip: 'vip',
  TrackType.cloud: 'cloud',
  TrackType.noCopyright: 'noCopyright',
};

ArtistMini _$ArtistMiniFromJson(Map<String, dynamic> json) => ArtistMini(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ArtistMiniToJson(ArtistMini instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
    };

AlbumMini _$AlbumMiniFromJson(Map<String, dynamic> json) => AlbumMini(
      id: json['id'] as int,
      picUri: json['picUrl'] as String?,
      name: json['name'] as String,
    );

Map<String, dynamic> _$AlbumMiniToJson(AlbumMini instance) => <String, dynamic>{
      'id': instance.id,
      'picUrl': instance.picUri,
      'name': instance.name,
    };
