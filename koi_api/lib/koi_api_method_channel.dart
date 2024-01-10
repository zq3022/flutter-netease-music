import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'koi_api_platform_interface.dart';

/// An implementation of [KoiApiPlatform] that uses method channels.
class MethodChannelKoiApi extends KoiApiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('koi_api');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
