import 'package:netease_api/netease_api.dart';

import '../data/playlist_detail.dart';
import 'track_extension.dart';
import 'user_extension.dart';

extension PlayListMapper on Playlist {
  PlaylistDetail toPlaylistDetail(List<PrivilegesItem> privileges) {
    assert(coverImgUrl.isNotEmpty, 'coverImgUrl is empty');
    final privilegesMap = Map<int, PrivilegesItem>.fromEntries(
      privileges.map((e) => MapEntry(e.id, e)),
    );
    return PlaylistDetail(
      id: id,
      name: name,
      coverUrl: coverImgUrl,
      trackCount: trackCount,
      playCount: playCount,
      subscribedCount: subscribedCount,
      creator: creator.toUser(),
      description: description,
      subscribed: subscribed,
      tracks: tracks.map((e) => e.toTrack(privilegesMap[e.id])).toList(),
      commentCount: commentCount,
      shareCount: shareCount,
      trackUpdateTime: trackUpdateTime,
      trackIds: trackIds.map((e) => e.id).toList(),
      createTime: DateTime.fromMillisecondsSinceEpoch(createTime),
      isMyFavorite: specialType == 5,
    );
  }
}
