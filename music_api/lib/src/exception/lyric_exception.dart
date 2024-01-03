import '../track.dart';
import 'music_exception.dart';

class LyricException extends MusicException {
  LyricException(String message, [Track? track]) : super(message, track);
}
