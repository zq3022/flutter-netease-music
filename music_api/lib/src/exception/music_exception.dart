import '../track.dart';

/// 定义一些错误异常来使用
class MusicException implements Exception {
  const MusicException(this.message, [this.track]);

  final String message;

  final Track? track;

  @override
  String toString() =>
      'MusicException: $message ${track == null ? "" : track!.toString()}';
}
