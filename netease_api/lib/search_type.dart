import 'package:async/async.dart';
import 'package:netease_music_api/netease_cloud_music.dart' show debugPrint;

///enum for NeteaseRepository.search param type
class SearchType {
  const SearchType._(this.type);

  final int type;

  static const SearchType song = SearchType._(1);
  static const SearchType album = SearchType._(10);
  static const SearchType artist = SearchType._(100);
  static const SearchType playlist = SearchType._(1000);
  static const SearchType user = SearchType._(1002);
  static const SearchType mv = SearchType._(1004);
  static const SearchType lyric = SearchType._(1006);
  static const SearchType dj = SearchType._(1009);
  static const SearchType video = SearchType._(1014);
}

enum PlaylistOperation { add, remove }

enum PlayRecordType {
  allData,
  weekData,
}

extension PlayRecordTypeExtension on PlayRecordType {
  String get value {
    switch (this) {
      case PlayRecordType.allData:
        return 'allData';
      case PlayRecordType.weekData:
        return 'weekData';
    }
  }
}

extension ResultMapExtension<T> on Result<T> {
  Result<R> map<R>(R Function(T value) transform) {
    if (isError) return asError!;
    try {
      return Result.value(transform(asValue!.value));
    } catch (e, s) {
      debugPrint('error to transform: ${asValue!.value}');
      return Result.error(e, s);
    }
  }
}

extension FutureMapExtension<T> on Future<Result<T>> {
  Future<Result<R>> map<R>(R Function(T value) transform) {
    return then((value) => value.map(transform));
  }
}

typedef OnRequestError = void Function(ErrorResult error);
