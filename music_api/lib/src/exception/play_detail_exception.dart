import '../track.dart';
import 'music_exception.dart';

class PlayDetailException extends MusicException {
  PlayDetailException(String message, [Track? track]) : super(message, track);
}
