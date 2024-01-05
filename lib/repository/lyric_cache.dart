import '../utils/cache/key_value_cache.dart';

class LyricCache implements Cache<String?> {
  LyricCache(String dir)
      : provider =
            FileCacheProvider(dir, maxSize: 20 * 1024 * 1024 /* 20 Mb */);

  final FileCacheProvider provider;

  @override
  Future<String?> get(CacheKey key) async {
    final file = provider.getFile(key);
    if (await file.exists()) {
      provider.touchFile(file);
      return file.readAsStringSync();
    }
    return null;
  }

  @override
  Future<bool> update(CacheKey key, String? t) async {
    if (t == null) return Future.value(false);
    var file = provider.getFile(key);

    if (file.existsSync()) {
      file.deleteSync();
    }

    file.createSync(recursive: true);
    file.writeAsStringSync(t);
    try {
      return file.exists();
    } finally {
      provider.checkSize();
    }
  }
}
