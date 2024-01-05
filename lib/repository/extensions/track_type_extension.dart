// https://github.com/Binaryify/NeteaseCloudMusicApi/issues/899#issuecomment-680002883
import 'package:common_utils/common_utils.dart';
import 'package:music_api/music_api.dart';

TrackType trackType({
  required int fee,
  required bool cs,
  required int st,
}) {
  if (st == -200) {
    return TrackType.noCopyright;
  }
  if (cs) {
    return TrackType.cloud;
  }
  switch (fee) {
    case 0:
    case 8:
      return TrackType.free;
    case 4:
      return TrackType.payAlbum;
    case 1:
      return TrackType.vip;
  }
  LogUtil.e('unknown fee: $fee');
  return TrackType.free;
}
