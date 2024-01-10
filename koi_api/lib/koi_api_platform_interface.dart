import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'koi_api_method_channel.dart';

abstract class KoiApiPlatform extends PlatformInterface {
  /// Constructs a KoiApiPlatform.
  KoiApiPlatform() : super(token: _token);

  static final Object _token = Object();

  static KoiApiPlatform _instance = MethodChannelKoiApi();

  /// The default instance of [KoiApiPlatform] to use.
  ///
  /// Defaults to [MethodChannelKoiApi].
  static KoiApiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [KoiApiPlatform] when
  /// they register themselves.
  static set instance(KoiApiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
