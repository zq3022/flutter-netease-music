import 'package:netease_api/netease_api.dart';

import '../data/user.dart';

extension UserDetailMapper on UserDetail {
  User toUser() {
    return User(
      userId: profile.userId,
      nickname: profile.nickname,
      avatarUrl: profile.avatarUrl,
      followers: profile.follows,
      followed: profile.followed,
      backgroundUrl: profile.backgroundUrl,
      createTime: createTime,
      description: profile.description,
      detailDescription: profile.detailDescription,
      playlistBeSubscribedCount: profile.playlistBeSubscribedCount,
      playlistCount: profile.playlistCount,
      allSubscribedCount: profile.allSubscribedCount,
      followedUsers: profile.followeds,
      vipType: profile.vipType,
      level: level,
      eventCount: profile.eventCount,
    );
  }
}
