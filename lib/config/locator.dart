import 'package:fplayground/service/audio_player.dart';
import 'package:get_it/get_it.dart';

void setupLocator() {
  GetIt.I.registerSingleton<AudioPlayerController>(AudioPlayerController());
}
