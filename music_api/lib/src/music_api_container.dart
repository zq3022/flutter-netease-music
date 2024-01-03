import 'exception/register_exception.dart';
import 'exception/unsupport_origin_exception.dart';
import 'music_api.dart';

/// 负责管理api
class MusicApiContainer {
  factory MusicApiContainer() => _getInstance();
  MusicApiContainer._internal();

  static MusicApiContainer get instance => _getInstance();
  static final MusicApiContainer _instance = MusicApiContainer._internal();

  static MusicApiContainer _getInstance() {
    return _instance;
  }

  final List<MusicApi> _plugins = List.empty(growable: true);

  /// 注册
  void regiester(MusicApi api) {
    for (final s in _plugins) {
      if (s.origin == api.origin) {
        throw RegisterException('$api 注册失败');
      }
    }

    if (_plugins.contains(api)) {
      return;
    }
    _plugins.add(api);
  }

  Future<MusicApi> getApi(int origin) {
    for (final s in _plugins) {
      if (s.origin == origin) return Future.value(s);
    }
    return Future.error(UnsupportedOriginException);
  }

  MusicApi? getApiSync(int origin) {
    for (final s in _plugins) {
      if (s.origin == origin) return s;
    }
    return null;
  }

  List<MusicApi> get list => _plugins;
}
