import 'music_exception.dart';

/// 部分api可能不支持某项功能
class UnsupportedException extends MusicException {
  UnsupportedException(String message) : super(message);
}
