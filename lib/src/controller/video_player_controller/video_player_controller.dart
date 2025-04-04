import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';

part 'video_player_controller.g.dart';

@riverpod
class VideoPlayerService extends _$VideoPlayerService {
  @override
  Raw<VideoPlayerController> build(String assetPath) {
    debugPrint('Controller: videoPlayService is called with assetPath: $assetPath');
    final VideoPlayerController controller = VideoPlayerController.networkUrl(Uri.parse(assetPath));

    ref.onDispose(() async {
      debugPrint('Controller: videoPlayService is disposed');
      await controller.dispose();
    });

    return controller;
  }

  Future<void> initializeControllerAndProvider() async {
    debugPrint('Controller: videoPlayService controller and provider are initialized');
    await state.initialize().then((_) => state.play());
    debugPrint('Controller: videoPlayService controller is initialized');
    state.addListener(_videoPlayerListener);
  }

  void _videoPlayerListener() {
    if (state.value.isInitialized && state.value.position == state.value.duration) {
      debugPrint('Controller: videoPlayService video has ended');
      // Handle video end event here
    }
  }
}
